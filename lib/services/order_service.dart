import 'package:uuid/uuid.dart';
import '../database/db_helper.dart';
import '../models/order.dart';
import '../models/product.dart';
import '../models/transaction.dart';
import 'wallet_service.dart';
import 'product_service.dart';
import 'settings_service.dart';

class OrderService {
  static const _uuid = Uuid();
  final _wallet = WalletService();
  final _products = ProductService();
  final _settings = SettingsService();

  /// Buys [product] for [buyerId]: debits buyer, escrows funds mentally as
  /// "pending" (credited to seller immediately minus commission — simple
  /// offline model; swap for a hold/release flow once a backend exists).
  Future<Order> purchase({required Product product, required String buyerId}) async {
    if (product.sellerId == buyerId) {
      throw Exception('Нельзя купить собственный товар');
    }
    final db = await DBHelper.instance.database;
    final commissionPercent = await _settings.getCommissionPercent();
    final sellerCut = product.price * (1 - commissionPercent / 100);

    final order = Order(
      id: _uuid.v4(),
      productId: product.id,
      buyerId: buyerId,
      sellerId: product.sellerId,
      price: product.price,
      status: OrderStatus.active,
      createdAt: DateTime.now(),
    );

    await db.transaction((txn) async {
      await txn.insert('orders', order.toMap());
    });

    await _wallet.applyTransaction(
      userId: buyerId,
      type: TxType.purchase,
      amount: -product.price,
      note: 'Покупка: ${product.title}',
    );
    await _wallet.applyTransaction(
      userId: product.sellerId,
      type: TxType.sale,
      amount: sellerCut,
      note: 'Продажа: ${product.title}',
    );
    await _products.setStatus(product.id, ProductStatus.sold);
    return order;
  }

  Future<List<Order>> listForUser(String userId) async {
    final db = await DBHelper.instance.database;
    final rows = await db.query(
      'orders',
      where: 'buyerId = ? OR sellerId = ?',
      whereArgs: [userId, userId],
      orderBy: 'createdAt DESC',
    );
    return rows.map((r) => Order.fromMap(r)).toList();
  }

  Future<List<Order>> listAllForAdmin() async {
    final db = await DBHelper.instance.database;
    final rows = await db.query('orders', orderBy: 'createdAt DESC');
    return rows.map((r) => Order.fromMap(r)).toList();
  }

  Future<void> fileDispute(String orderId, String reason) async {
    final db = await DBHelper.instance.database;
    await db.update(
      'orders',
      {'status': OrderStatus.disputed.name, 'disputeReason': reason},
      where: 'id = ?',
      whereArgs: [orderId],
    );
  }

  Future<void> markCompleted(String orderId) async {
    final db = await DBHelper.instance.database;
    await db.update('orders', {'status': OrderStatus.completed.name}, where: 'id = ?', whereArgs: [orderId]);
  }

  /// Admin-only: refunds the buyer from the seller's balance and marks the order refunded.
  Future<void> refund(String orderId) async {
    final db = await DBHelper.instance.database;
    final rows = await db.query('orders', where: 'id = ?', whereArgs: [orderId]);
    if (rows.isEmpty) throw Exception('Order not found');
    final order = Order.fromMap(rows.first);

    await _wallet.applyTransaction(
      userId: order.sellerId,
      type: TxType.refund,
      amount: -order.price,
      note: 'Возврат по заказу ${order.id}',
    );
    await _wallet.applyTransaction(
      userId: order.buyerId,
      type: TxType.refund,
      amount: order.price,
      note: 'Возврат по заказу ${order.id}',
    );
    await db.update('orders', {'status': OrderStatus.refunded.name}, where: 'id = ?', whereArgs: [orderId]);
  }
}
