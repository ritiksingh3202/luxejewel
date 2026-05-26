class Product {
  const Product({
    required this.id,
    required this.name,
    required this.priceCents,
    required this.image,
    required this.category,
    required this.rating,
    required this.description,
    this.material,
    this.stock = 0,
  });

  final String id;
  final String name;
  final int priceCents;
  final String image;
  final String category;
  final double rating;
  final String description;
  final String? material;
  final int stock;

  double get price => priceCents / 100;
  bool get inStock => stock > 0;

  factory Product.fromMap(Map<String, dynamic> m) {
    final category = m['categories'];
    return Product(
      id: m['id'] as String,
      name: m['name'] as String,
      priceCents: (m['price_cents'] as num).toInt(),
      image: (m['image_path'] as String?) ?? '',
      category: category is Map ? (category['name'] as String? ?? '') : '',
      rating: (m['rating'] as num?)?.toDouble() ?? 0,
      description: (m['description'] as String?) ?? '',
      material: m['material'] as String?,
      stock: (m['stock'] as num?)?.toInt() ?? 0,
    );
  }
}
