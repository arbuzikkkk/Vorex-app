import 'package:uuid/uuid.dart';
import '../database/db_helper.dart';
import '../models/product.dart';

class ProductService {
  static const _uuid = Uuid();

  Future<Product> createProduct({
    required String sellerId,
    required String title,
    required String description,
    required double price,
    required String category,
    required List<String> photoPaths,
  }) async {
    final product = Product(
      id: _uuid.v4(),
      sellerId: sellerId,
      title: title,
      description: description,
      price: price,
      category: category,
      photoPaths: photoPaths.take(10).toList(),
      status: ProductStatus.active,
      createdAt: DateTime.now(),
    );
    final db = await DBHelper.instance.database;
    await db.insert('products', product.toMap());
    return product;
  }

  Future<List<Product>> listActive({String? category, String? query}) async {
    final db = await DBHelper.instance.database;
    final where = <String>['status = ?'];
    final args = <Object?>['active'];
    if (category != null && category.isNotEmpty && category != 'Все') {
      where.add('category = ?');
      args.add(category);
    }
    if (query != null && query.trim().isNotEmpty) {
      where.add('title LIKE ?');
      args.add('%${query.trim()}%');
    }
    final rows = await db.query(
      'products',
      where: where.join(' AND '),
      whereArgs: args,
      orderBy: 'createdAt DESC',
    );
    return rows.map((r) => Product.fromMap(r)).toList();
  }

  Future<List<Product>> listBySeller(String sellerId) async {
    final db = await DBHelper.instance.database;
    final rows = await db.query('products', where: 'sellerId = ?', whereArgs: [sellerId], orderBy: 'createdAt DESC');
    return rows.map((r) => Product.fromMap(r)).toList();
  }

  Future<List<Product>> listAllForAdmin() async {
    final db = await DBHelper.instance.database;
    final rows = await db.query('products', orderBy: 'createdAt DESC');
    return rows.map((r) => Product.fromMap(r)).toList();
  }

  Future<void> setStatus(String productId, ProductStatus status) async {
    final db = await DBHelper.instance.database;
    await db.update('products', {'status': status.name}, where: 'id = ?', whereArgs: [productId]);
  }

  Future<void> deleteProduct(String productId) async {
    final db = await DBHelper.instance.database;
    await db.delete('products', where: 'id = ?', whereArgs: [productId]);
  }
}
