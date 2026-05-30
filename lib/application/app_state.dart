import 'package:flutter/foundation.dart';

import '../core/errors/app_failure.dart';
import '../data/repositories/repositories.dart';
import '../domain/models/address.dart';
import '../domain/models/cart_item.dart';
import '../domain/models/order.dart';
import '../domain/models/product.dart';
import '../domain/payment/payment_service.dart';

/// App-wide catalog plus per-user cart, wishlist, orders, profile and addresses.
/// Mutations are optimistic and rolled back if the backend rejects them.
class AppState extends ChangeNotifier {
  AppState(this._backend);

  static const int maxQuantityPerItem = 10;

  final Backend _backend;

  List<Product> _products = const [];
  List<String> _categories = const ['All'];
  bool _catalogLoading = false;
  bool _catalogLoaded = false;
  String? _catalogError;

  String? _userId;
  bool _userLoading = false;
  String? _userError;
  final List<CartItem> _cart = [];
  final List<String> _wishlistIds = [];
  List<Order> _orders = const [];
  UserProfile? _profile;
  List<Address> _addresses = const [];

  PaymentMethodInfo get paymentMethod => _backend.payment.method;

  List<Product> get products => _products;
  List<String> get categories => _categories;
  bool get catalogLoading => _catalogLoading;
  bool get catalogLoaded => _catalogLoaded;
  String? get catalogError => _catalogError;

  bool get userLoading => _userLoading;
  String? get userError => _userError;
  List<CartItem> get cart => List.unmodifiable(_cart);
  List<Product> get wishlist => [
        for (final id in _wishlistIds)
          if (productById(id) case final p?) p,
      ];
  List<Order> get orders => _orders;
  UserProfile? get profile => _profile;
  List<Address> get addresses => _addresses;
  Address? get defaultAddress =>
      _addresses.where((a) => a.isDefault).firstOrNull ?? _addresses.firstOrNull;

  int get cartSubtotalCents => _cart.fold(0, (s, i) => s + i.product.priceCents * i.quantity);
  double get cartTotal => cartSubtotalCents / 100;
  int get cartCount => _cart.fold(0, (n, i) => n + i.quantity);

  Product? productById(String id) {
    for (final p in _products) {
      if (p.id == id) return p;
    }
    return null;
  }

  Order? orderById(String id) {
    for (final o in _orders) {
      if (o.id == id) return o;
    }
    return null;
  }

  bool isInWishlist(String productId) => _wishlistIds.contains(productId);
  int quantityInCart(String productId) =>
      _cart.where((e) => e.product.id == productId).firstOrNull?.quantity ?? 0;

  // ---------------------------------------------------------------- catalog

  Future<void> loadCatalog() async {
    if (_catalogLoading) return;
    _catalogLoading = true;
    _catalogError = null;
    notifyListeners();
    try {
      final results = await Future.wait([
        _backend.catalog.fetchCategories(),
        _backend.catalog.fetchProducts(),
      ]);
      _categories = ['All', ...results[0] as List<String>];
      _products = results[1] as List<Product>;
      _catalogLoaded = true;
      _rebuildCart(null);
    } on AppFailure catch (e) {
      _catalogError = e.message;
    } catch (_) {
      _catalogError = 'Could not load products.';
    } finally {
      _catalogLoading = false;
      notifyListeners();
    }
  }

  // ---------------------------------------------------------------- session

  /// Called whenever the authenticated user changes; isolates per-user data.
  Future<void> setUser(String? userId) async {
    if (userId == _userId) return;
    _userId = userId;
    _cart.clear();
    _wishlistIds.clear();
    _orders = const [];
    _profile = null;
    _addresses = const [];
    _userError = null;
    _pendingCart = null;
    notifyListeners();
    if (userId != null) await refreshUserData();
  }

  List<CartLine>? _pendingCart;

  void _rebuildCart(List<CartLine>? lines) {
    lines ??= _pendingCart;
    if (lines == null) return;
    _pendingCart = lines;
    _cart
      ..clear()
      ..addAll([
        for (final l in lines)
          if (productById(l.productId) case final p?) CartItem(product: p, quantity: l.quantity),
      ]);
  }

  Future<void> refreshUserData() async {
    final uid = _userId;
    if (uid == null) return;
    _userLoading = true;
    _userError = null;
    notifyListeners();
    try {
      if (!_catalogLoaded) await loadCatalog();
      final r = await Future.wait([
        _backend.cart.fetch(),
        _backend.wishlist.fetch(),
        _backend.orders.fetchOrders(),
        _backend.profile.fetchProfile(),
        _backend.profile.fetchAddresses(),
      ]);
      if (uid != _userId) return;
      _rebuildCart(r[0] as List<CartLine>);
      _wishlistIds
        ..clear()
        ..addAll(r[1] as List<String>);
      _orders = r[2] as List<Order>;
      _profile = r[3] as UserProfile;
      _addresses = r[4] as List<Address>;
    } on AppFailure catch (e) {
      if (uid == _userId) _userError = e.message;
    } finally {
      if (uid == _userId) {
        _userLoading = false;
        notifyListeners();
      }
    }
  }

  void _requireUser() {
    if (_userId == null) {
      throw const AppFailure('Please sign in to continue', requiresAuth: true);
    }
  }

  Future<void> _optimistic(void Function() apply, Future<void> Function() persist) async {
    final cartBefore = List<CartItem>.from(_cart);
    final wishBefore = List<String>.from(_wishlistIds);
    apply();
    notifyListeners();
    try {
      await persist();
      _pendingCart = [for (final i in _cart) (productId: i.product.id, quantity: i.quantity)];
    } catch (_) {
      _cart
        ..clear()
        ..addAll(cartBefore);
      _wishlistIds
        ..clear()
        ..addAll(wishBefore);
      notifyListeners();
      rethrow;
    }
  }

  // ---------------------------------------------------------------- cart

  void _validateQuantity(Product p, int qty) {
    if (!p.inStock) throw AppFailure('${p.name} is out of stock');
    if (qty > p.stock) throw AppFailure('Only ${p.stock} of ${p.name} available');
    if (qty > maxQuantityPerItem) throw const AppFailure('Maximum $maxQuantityPerItem per item');
  }

  Future<void> addToCart(Product product, {int quantity = 1}) async {
    _requireUser();
    if (quantity < 1) throw const AppFailure('Quantity must be at least 1');
    final next = quantityInCart(product.id) + quantity;
    _validateQuantity(product, next);
    await _optimistic(() => _setLocalQuantity(product, next), () => _backend.cart.setQuantity(product.id, next));
  }

  Future<void> updateCartQuantity(String productId, int quantity) async {
    _requireUser();
    if (quantity <= 0) return removeFromCart(productId);
    final product = productById(productId);
    if (product == null) throw const AppFailure('This product is no longer available');
    _validateQuantity(product, quantity);
    await _optimistic(
      () => _setLocalQuantity(product, quantity),
      () => _backend.cart.setQuantity(productId, quantity),
    );
  }

  Future<void> removeFromCart(String productId) async {
    _requireUser();
    await _optimistic(
      () => _cart.removeWhere((e) => e.product.id == productId),
      () => _backend.cart.remove(productId),
    );
  }

  void _setLocalQuantity(Product product, int qty) {
    final idx = _cart.indexWhere((e) => e.product.id == product.id);
    if (idx >= 0) {
      _cart[idx] = _cart[idx].copyWith(quantity: qty);
    } else {
      _cart.add(CartItem(product: product, quantity: qty));
    }
  }

  // ---------------------------------------------------------------- wishlist

  Future<void> toggleWishlist(Product product) async {
    _requireUser();
    if (isInWishlist(product.id)) {
      await _optimistic(() => _wishlistIds.remove(product.id), () => _backend.wishlist.remove(product.id));
    } else {
      await _optimistic(() => _wishlistIds.add(product.id), () => _backend.wishlist.add(product.id));
    }
  }

  // ---------------------------------------------------------------- orders

  /// Places an order through the configured [PaymentService]; returns the order id.
  Future<String> placeOrder({required String addressId}) async {
    _requireUser();
    if (_cart.isEmpty) throw const AppFailure('Your cart is empty');
    final id = await _backend.payment.placeOrder(addressId: addressId);
    _cart.clear();
    _pendingCart = const [];
    notifyListeners();
    await reloadOrders();
    return id;
  }

  Future<void> reloadOrders() async {
    _requireUser();
    _orders = await _backend.orders.fetchOrders();
    notifyListeners();
  }

  // ---------------------------------------------------------------- profile

  Future<void> updateProfile({required String fullName, String? phone}) async {
    _requireUser();
    await _backend.profile.updateProfile(fullName: fullName, phone: phone);
    _profile = await _backend.profile.fetchProfile();
    notifyListeners();
  }

  Future<void> uploadAvatar(Uint8List bytes, String extension) async {
    _requireUser();
    await _backend.profile.uploadAvatar(bytes, extension);
    _profile = await _backend.profile.fetchProfile();
    notifyListeners();
  }

  Future<Address> saveAddress(Address address) async {
    _requireUser();
    final saved = await _backend.profile.saveAddress(address);
    await _reloadAddresses();
    return saved;
  }

  Future<void> deleteAddress(String id) async {
    _requireUser();
    await _backend.profile.deleteAddress(id);
    await _reloadAddresses();
  }

  Future<void> setDefaultAddress(String id) async {
    _requireUser();
    await _backend.profile.setDefaultAddress(id);
    await _reloadAddresses();
  }

  Future<void> _reloadAddresses() async {
    _addresses = await _backend.profile.fetchAddresses();
    notifyListeners();
  }
}
