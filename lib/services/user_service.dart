import '../database/db_helper.dart';
import '../models/user.dart';

class UserService {
  Future<List<AppUser>> listAll() async {
    final db = await DBHelper.instance.database;
    final rows = await db.query('users', orderBy: 'createdAt DESC');
    return rows.map((r) => AppUser.fromMap(r)).toList();
  }

  Future<void> setBanned(String userId, bool banned) async {
    final db = await DBHelper.instance.database;
    await db.update('users', {'isBanned': banned ? 1 : 0}, where: 'id = ?', whereArgs: [userId]);
  }

  Future<AppUser?> byId(String userId) async {
    final db = await DBHelper.instance.database;
    final rows = await db.query('users', where: 'id = ?', whereArgs: [userId]);
    if (rows.isEmpty) return null;
    return AppUser.fromMap(rows.first);
  }
}
