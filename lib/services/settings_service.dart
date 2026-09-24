import '../database/db_helper.dart';

class SettingsService {
  Future<double> getCommissionPercent() async {
    final db = await DBHelper.instance.database;
    final rows = await db.query('app_settings', where: 'key = ?', whereArgs: ['commission_percent']);
    if (rows.isEmpty) return 5;
    return double.tryParse(rows.first['value'] as String) ?? 5;
  }

  Future<void> setCommissionPercent(double value) async {
    final db = await DBHelper.instance.database;
    await db.update('app_settings', {'value': value.toString()}, where: 'key = ?', whereArgs: ['commission_percent']);
  }

  Future<Map<String, double>> profitStats() async {
    final db = await DBHelper.instance.database;
    final orders = await db.query('orders');
    double totalVolume = 0;
    final commission = await getCommissionPercent();
    for (final o in orders) {
      totalVolume += (o['price'] as num).toDouble();
    }
    return {
      'totalVolume': totalVolume,
      'estimatedCommissionRevenue': totalVolume * commission / 100,
      'orderCount': orders.length.toDouble(),
    };
  }
}
