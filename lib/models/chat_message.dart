class ChatMessage {
  final String id;
  final String orderId;
  final String senderId;
  final String text;
  final DateTime createdAt;

  ChatMessage({
    required this.id,
    required this.orderId,
    required this.senderId,
    required this.text,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() => {
        'id': id,
        'orderId': orderId,
        'senderId': senderId,
        'text': text,
        'createdAt': createdAt.toIso8601String(),
      };

  factory ChatMessage.fromMap(Map<String, dynamic> m) => ChatMessage(
        id: m['id'] as String,
        orderId: m['orderId'] as String,
        senderId: m['senderId'] as String,
        text: m['text'] as String,
        createdAt: DateTime.parse(m['createdAt'] as String),
      );
}
