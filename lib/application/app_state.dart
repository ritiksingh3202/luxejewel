import 'package:flutter/foundation.dart';

import '../data/repositories/catalog_repository.dart';
import '../domain/models/cart_item.dart';
import '../domain/models/order.dart';
import '../domain/models/product.dart';
import '../domain/pricing/checkout_pricing.dart';

/// App-wide cart, wishlist, and orders (React `AppContext` equivalent).
class AppState extends ChangeNotifier {
  AppState({CatalogRepository? catalog})
      : _catalog = catalog ?? InMemoryCatalogRepository();

  final CatalogRepository _catalog;

  final List<CartItem> _cart = [];
  final List<Product> _wishlist = [];
  final List<Order> _orders = [];

  List<CartItem> get cart => List.unmodifiable(_cart);
  List<Product> get wishlist => List.unmodifiable(_wishlist);
  List<Order> get orders => List.unmodifiable(_orders);

  double get cartTotal {
    var sum = 0.0;
    for (final i in _cart) {
      sum += i.product.price * i.quantity;
    }
    return sum;
  }

  int get cartCount {
    var n = 0;
    for (final i in _cart) {
      n += i.quantity;
    }
    return n;
  }

  CatalogRepository get catalog => _catalog;

  void addToCart(Product product) {
    final idx = _cart.indexWhere((e) => e.product.id == product.id);
    if (idx >= 0) {
      final existing = _cart[idx];
      _cart[idx] = existing.copyWith(quantity: existing.quantity + 1);
    } else {
      _cart.add(CartItem(product: product, quantity: 1));
    }
    notifyListeners();
  }

  void removeFromCart(String productId) {
    _cart.removeWhere((e) => e.product.id == productId);
    notifyListeners();
  }

  void updateCartQuantity(String productId, int quantity) {
    if (quantity <= 0) {
      removeFromCart(productId);
      return;
    }
    final idx = _cart.indexWhere((e) => e.product.id == productId);
    if (idx < 0) return;
    _cart[idx] = _cart[idx].copyWith(quantity: quantity);
    notifyListeners();
  }

  void toggleWishlist(Product product) {
    final exists = _wishlist.any((p) => p.id == product.id);
    if (exists) {
      _wishlist.removeWhere((p) => p.id == product.id);
    } else {
      _wishlist.add(product);
    }
    notifyListeners();
  }

  bool isInWishlist(String productId) => _wishlist.any((p) => p.id == productId);

  void clearCart() {
    _cart.clear();
    notifyListeners();
  }

  /// Persists order with **grand total** (subtotal + shipping + tax) to match checkout UI.
  void placeOrder({
    required String address,
    required String paymentMethod,
  }) {
    if (_cart.isEmpty) return;
    final subtotal = cartTotal;
    final total = CheckoutPricing.grandTotal(subtotal);
    final order = Order(
      id: 'ORD${DateTime.now().millisecondsSinceEpoch}',
      date: _formatDate(DateTime.now()),
      items: List<CartItem>.from(_cart),
      total: total,
      status: OrderStatus.pending,
      address: address,
      paymentMethod: paymentMethod,
    );
    _orders.insert(0, order);
    clearCart();
  }

  static String _formatDate(DateTime d) {
    return '${d.month}/${d.day}/${d.year}';
  }
}
