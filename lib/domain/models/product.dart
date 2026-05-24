class Product {
  const Product({
    required this.id,
    required this.name,
    required this.price,
    required this.image,
    required this.category,
    required this.rating,
    required this.description,
    this.material,
  });

  final String id;
  final String name;
  final double price;
  final String image;
  final String category;
  final double rating;
  final String description;
  final String? material;

  Product copyWith({double? price, double? rating}) {
    return Product(
      id: id,
      name: name,
      price: price ?? this.price,
      image: image,
      category: category,
      rating: rating ?? this.rating,
      description: description,
      material: material,
    );
  }
}
