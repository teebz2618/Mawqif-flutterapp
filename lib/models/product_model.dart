class Product {
  final String id;
  final String name;
  final double price;
  final String category;
  final List<String> sizes;
  final String imageUrl;

  Product({
    required this.id,
    required this.name,
    required this.price,
    required this.category,
    required this.sizes,
    required this.imageUrl,
  });

  factory Product.fromMap(Map<String, dynamic> map, String documentId) {
    return Product(
      id: documentId,
      name: map['name'] ?? '',
      price: (map['price'] ?? 0).toDouble(),
      category: map['category'] ?? '',
      sizes: List<String>.from(map['sizes'] ?? []),
      imageUrl: map['imageUrl'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'price': price,
      'category': category,
      'sizes': sizes,
      'imageUrl': imageUrl,
    };
  }
}
