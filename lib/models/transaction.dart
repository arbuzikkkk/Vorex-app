enum TxType { topup, purchase, sale, refund, adminAdjustment }

class WalletTransaction {
  final String id;
  final String userId;
  final TxType type;
  final double amount; // positive = credit, negative = debit
  final String note;
  final DateTime createdAt;

  WalletTransaction({
    required this.id,
    required this.userId,
    required this.type,
    required this.amount,
    required this.note,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() => {
        'id': id,
        'userId': userId,
        'type': type.name,
        'amount': amount,
        'note': note,
        'createdAt': createdAt.toIso8601String(),
      };

  factory WalletTransaction.fromMap(Map<String, dynamic> m) => WalletTransaction(
        id: m['id'] as String,
        userId: m['userId'] as String,
        type: TxType.values.firstWhere((t) => t.name == m['type']),
        amount: (m['amount'] as num).toDouble(),
        note: m['note'] as String,
        createdAt: DateTime.parse(m['createdAt'] as String),
      );
}
