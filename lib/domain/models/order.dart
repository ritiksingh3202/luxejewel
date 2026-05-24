import 'cart_item.dart';

enum OrderStatus { pending, delivered, cancelled }

class Order {
  const Order({
    required this.id,
    required this.date,
    required this.items,
    required this.total,
    required this.status,
    this.address,
    this.paymentMethod,
  });

  final String id;
  final String date;
  final List<CartItem> items;
  final double total;
  final OrderStatus status;
  final String? address;
  final String? paymentMethod;
}
