class AppUser {
  final String id;
  final String username;
  final String passwordHash;
  double balance;
  bool isAdmin;
  bool isBanned;
  final DateTime createdAt;

  AppUser({
    required this.id,
    required this.username,
    required this.passwordHash,
    this.balance = 0,
    this.isAdmin = false,
    this.isBanned = false,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() => {
        'id': id,
        'username': username,
        'passwordHash': passwordHash,
        'balance': balance,
        'isAdmin': isAdmin ? 1 : 0,
        'isBanned': isBanned ? 1 : 0,
        'createdAt': createdAt.toIso8601String(),
      };

  factory AppUser.fromMap(Map<String, dynamic> m) => AppUser(
        id: m['id'] as String,
        username: m['username'] as String,
        passwordHash: m['passwordHash'] as String,
        balance: (m['balance'] as num).toDouble(),
        isAdmin: (m['isAdmin'] as int) == 1,
        isBanned: (m['isBanned'] as int) == 1,
        createdAt: DateTime.parse(m['createdAt'] as String),
      );
}
