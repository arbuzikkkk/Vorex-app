import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:uuid/uuid.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../database/db_helper.dart';
import '../models/user.dart';

class AuthService {
  static const _uuid = Uuid();
  static const _sessionKey = 'vorex_session_user_id';

  String _hash(String raw) => sha256.convert(utf8.encode(raw)).toString();

  Future<AppUser?> register(String username, String password) async {
    final db = await DBHelper.instance.database;
    final existing = await db.query('users', where: 'username = ?', whereArgs: [username]);
    if (existing.isNotEmpty) return null; // username taken

    final user = AppUser(
      id: _uuid.v4(),
      username: username,
      passwordHash: _hash(password),
      balance: 0,
      createdAt: DateTime.now(),
    );
    await db.insert('users', user.toMap());
    await _setSession(user.id);
    return user;
  }

  Future<AppUser?> login(String username, String password) async {
    final db = await DBHelper.instance.database;
    final rows = await db.query('users', where: 'username = ?', whereArgs: [username]);
    if (rows.isEmpty) return null;
    final user = AppUser.fromMap(rows.first);
    if (user.passwordHash != _hash(password)) return null;
    if (user.isBanned) return null;
    await _setSession(user.id);
    return user;
  }

  Future<void> _setSession(String userId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_sessionKey, userId);
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_sessionKey);
  }

  Future<AppUser?> currentUser() async {
    final prefs = await SharedPreferences.getInstance();
    final id = prefs.getString(_sessionKey);
    if (id == null) return null;
    final db = await DBHelper.instance.database;
    final rows = await db.query('users', where: 'id = ?', whereArgs: [id]);
    if (rows.isEmpty) return null;
    return AppUser.fromMap(rows.first);
  }
}
