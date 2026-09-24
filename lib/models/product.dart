enum ProductStatus { active, sold, pending, removed }

class Product {
  final String id;
  final String sellerId;
  String title;
  String description;
  double price;
  String category;
  List<String> photoPaths; // local file paths, up to 10
  ProductStatus status;
  final DateTime createdAt;

  Product({
    required this.id,
    required this.sellerId,
    required this.title,
    required this.description,
    required this.price,
    required this.category,
    this.photoPaths = const [],
    this.status = ProductStatus.pending,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() => {
        'id': id,
        'sellerId': sellerId,
        'title': title,
        'description': description,
        'price': price,
        'category': category,
        'photoPaths': photoPaths.join('|'),
        'status': status.name,
        'createdAt': createdAt.toIso8601String(),
      };

  factory Product.fromMap(Map<String, dynamic> m) => Product(
        id: m['id'] as String,
        sellerId: m['sellerId'] as String,
        title: m['title'] as String,
        description: m['description'] as String,
        price: (m['price'] as num).toDouble(),
        category: m['category'] as String,
        photoPaths: (m['photoPaths'] as String).isEmpty
            ? []
            : (m['photoPaths'] as String).split('|'),
        status: ProductStatus.values.firstWhere((s) => s.name == m['status']),
        createdAt: DateTime.parse(m['createdAt'] as String),
      );
}
