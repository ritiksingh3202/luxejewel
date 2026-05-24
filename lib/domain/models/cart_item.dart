import 'product.dart';

class CartItem {
  const CartItem({
    required this.product,
    required this.quantity,
  });

  final Product product;
  final int quantity;

  String get id => product.id;
  String get name => product.name;
  double get price => product.price;
  String get image => product.image;

  CartItem copyWith({int? quantity}) {
    return CartItem(
      product: product,
      quantity: quantity ?? this.quantity,
    );
  }
}
