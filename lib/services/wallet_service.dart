import 'package:uuid/uuid.dart';
import '../database/db_helper.dart';
import '../models/transaction.dart';

class WalletService {
  static const _uuid = Uuid();

  /// Credits or debits a user's balance and records the transaction atomically.
  Future<void> applyTransaction({
    required String userId,
    required TxType type,
    required double amount,
    required String note,
  }) async {
    final db = await DBHelper.instance.database;
    await db.transaction((txn) async {
      final rows = await txn.query('users', where: 'id = ?', whereArgs: [userId]);
      if (rows.isEmpty) throw Exception('User not found');
      final currentBalance = (rows.first['balance'] as num).toDouble();
      final newBalance = currentBalance + amount;
      if (newBalance < 0) throw Exception('Insufficient balance');

      await txn.update('users', {'balance': newBalance}, where: 'id = ?', whereArgs: [userId]);
      await txn.insert('wallet_transactions', {
        'id': _uuid.v4(),
        'userId': userId,
        'type': type.name,
        'amount': amount,
        'note': note,
        'createdAt': DateTime.now().toIso8601String(),
      });
    });
  }

  Future<List<WalletTransaction>> history(String userId) async {
    final db = await DBHelper.instance.database;
    final rows = await db.query(
      'wallet_transactions',
      where: 'userId = ?',
      whereArgs: [userId],
      orderBy: 'createdAt DESC',
    );
    return rows.map((r) => WalletTransaction.fromMap(r)).toList();
  }

  Future<double> getBalance(String userId) async {
    final db = await DBHelper.instance.database;
    final rows = await db.query('users', columns: ['balance'], where: 'id = ?', whereArgs: [userId]);
    if (rows.isEmpty) return 0;
    return (rows.first['balance'] as num).toDouble();
  }
}
