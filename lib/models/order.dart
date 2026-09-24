enum OrderStatus { active, completed, disputed, refunded, cancelled }

class Order {
  final String id;
  final String productId;
  final String buyerId;
  final String sellerId;
  final double price;
  OrderStatus status;
  String? disputeReason;
  final DateTime createdAt;

  Order({
    required this.id,
    required this.productId,
    required this.buyerId,
    required this.sellerId,
    required this.price,
    this.status = OrderStatus.active,
    this.disputeReason,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() => {
        'id': id,
        'productId': productId,
        'buyerId': buyerId,
        'sellerId': sellerId,
        'price': price,
        'status': status.name,
        'disputeReason': disputeReason,
        'createdAt': createdAt.toIso8601String(),
      };

  factory Order.fromMap(Map<String, dynamic> m) => Order(
        id: m['id'] as String,
        productId: m['productId'] as String,
        buyerId: m['buyerId'] as String,
        sellerId: m['sellerId'] as String,
        price: (m['price'] as num).toDouble(),
        status: OrderStatus.values.firstWhere((s) => s.name == m['status']),
        disputeReason: m['disputeReason'] as String?,
        createdAt: DateTime.parse(m['createdAt'] as String),
      );
}
