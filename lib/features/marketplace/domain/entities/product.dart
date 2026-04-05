class Product {
  final String id;
  final String sellerId;
  final String title;
  final String description;
  final double price;
  final String category;
  final List<String> imageUrls;
  final DateTime postedAt;

  const Product({
    required this.id,
    required this.sellerId,
    required this.title,
    required this.description,
    required this.price,
    required this.category,
    this.imageUrls = const [],
    required this.postedAt,
  });
}
