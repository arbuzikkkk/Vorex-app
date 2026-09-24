import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

/// Central SQLite gateway for VOREX. Fully offline; ready to be swapped
/// for a remote API layer later (services/ already isolate DB access).
class DBHelper {
  DBHelper._internal();
  static final DBHelper instance = DBHelper._internal();
  static Database? _db;

  Future<Database> get database async {
    _db ??= await _initDb();
    return _db!;
  }

  Future<Database> _initDb() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'vorex.db');
    return openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE users (
        id TEXT PRIMARY KEY,
        username TEXT UNIQUE NOT NULL,
        passwordHash TEXT NOT NULL,
        balance REAL NOT NULL DEFAULT 0,
        isAdmin INTEGER NOT NULL DEFAULT 0,
        isBanned INTEGER NOT NULL DEFAULT 0,
        createdAt TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE products (
        id TEXT PRIMARY KEY,
        sellerId TEXT NOT NULL,
        title TEXT NOT NULL,
        description TEXT NOT NULL,
        price REAL NOT NULL,
        category TEXT NOT NULL,
        photoPaths TEXT NOT NULL DEFAULT '',
        status TEXT NOT NULL,
        createdAt TEXT NOT NULL,
        FOREIGN KEY (sellerId) REFERENCES users (id)
      )
    ''');

    await db.execute('''
      CREATE TABLE orders (
        id TEXT PRIMARY KEY,
        productId TEXT NOT NULL,
        buyerId TEXT NOT NULL,
        sellerId TEXT NOT NULL,
        price REAL NOT NULL,
        status TEXT NOT NULL,
        disputeReason TEXT,
        createdAt TEXT NOT NULL,
        FOREIGN KEY (productId) REFERENCES products (id)
      )
    ''');

    await db.execute('''
      CREATE TABLE wallet_transactions (
        id TEXT PRIMARY KEY,
        userId TEXT NOT NULL,
        type TEXT NOT NULL,
        amount REAL NOT NULL,
        note TEXT NOT NULL,
        createdAt TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE chat_messages (
        id TEXT PRIMARY KEY,
        orderId TEXT NOT NULL,
        senderId TEXT NOT NULL,
        text TEXT NOT NULL,
        createdAt TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE app_settings (
        key TEXT PRIMARY KEY,
        value TEXT NOT NULL
      )
    ''');
    // Default commission rate: 5%
    await db.insert('app_settings', {'key': 'commission_percent', 'value': '5'});

    // Bootstrap admin account so the secret admin login has something to
    // authenticate against on first run. CHANGE THIS PASSWORD before
    // shipping — see README "Первый запуск".
    // passwordHash is sha256("admin123")
    await db.insert('users', {
      'id': 'admin-seed-0001',
      'username': 'admin',
      'passwordHash': '240be518fabd2724ddb6f04eeb1da5967448d7e831c08c8fa822809f74c720a9',
      'balance': 0,
      'isAdmin': 1,
      'isBanned': 0,
      'createdAt': DateTime.now().toIso8601String(),
    });
  }

  Future<void> close() async {
    final db = _db;
    if (db != null) {
      await db.close();
      _db = null;
    }
  }
}
