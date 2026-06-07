import 'dart:async';
import 'dart:typed_data';

import 'package:luxe_jewel/core/auth/auth_session.dart';
import 'package:luxe_jewel/core/errors/app_failure.dart';
import 'package:luxe_jewel/data/repositories/repositories.dart';
import 'package:luxe_jewel/domain/models/address.dart';
import 'package:luxe_jewel/domain/models/order.dart';
import 'package:luxe_jewel/domain/models/product.dart';
import 'package:luxe_jewel/domain/payment/payment_service.dart';
import 'package:luxe_jewel/domain/pricing/checkout_pricing.dart';

const testProducts = [
  Product(
    id: 'p1',
    name: 'Diamond Solitaire Ring',
    priceCents: 249900,
    image: 'assets/images/products/product_1.jpg',
    category: 'Rings',
    rating: 4.8,
    description: 'Solitaire ring',
    material: '18K White Gold',
    stock: 3,
  ),
  Product(
    id: 'p2',
    name: 'Gold Pearl Necklace',
    priceCents: 189900,
    image: 'assets/images/products/product_2.jpg',
    category: 'Necklaces',
    rating: 4.9,
    description: 'Pearl necklace',
    stock: 10,
  ),
  Product(
    id: 'p3',
    name: 'Charm Bracelet',
    priceCents: 179900,
    image: 'assets/images/products/product_8.jpg',
    category: 'Bracelets',
    rating: 4.7,
    description: 'Sold out bracelet',
    stock: 0,
  ),
];

/// Shared in-memory "database" so data survives across AppState instances (like a refresh).
class FakeStore {
  final users = <String, String>{'test@example.com': 'Passw0rd1'};
  final carts = <String, Map<String, int>>{};
  final wishlists = <String, List<String>>{};
  final orders = <String, List<Order>>{};
  final addresses = <String, List<Address>>{};
  final profiles = <String, UserProfile>{};
  bool catalogFails = false;
  bool cartWritesFail = false;
}

class FakeAuth implements AuthRepository {
  FakeAuth(this.store);
  final FakeStore store;
  final _events = StreamController<AuthEvent>.broadcast();
  AuthSession? _session;

  String get uid => _session?.userId ?? (throw const AppFailure('Please sign in', requiresAuth: true));

  @override
  AuthSession? get currentSession => _session;

  @override
  Stream<AuthEvent> get events => _events.stream;

  void _setSession(String email) {
    _session = AuthSession(userId: 'u-$email', email: email, displayName: email.split('@').first);
    store.profiles.putIfAbsent(_session!.userId, () => UserProfile(id: _session!.userId, fullName: 'Test User'));
    _events.add(AuthEvent(_session));
  }

  @override
  Future<void> signIn({required String email, required String password}) async {
    if (store.users[email.trim()] != password) throw const AppFailure('Invalid login credentials');
    _setSession(email.trim());
  }

  @override
  Future<bool> signUp({required String name, required String email, required String password, String? phone}) async {
    if (store.users.containsKey(email)) throw const AppFailure('User already registered');
    store.users[email] = password;
    _setSession(email);
    return false;
  }

  @override
  Future<void> signOut() async {
    _session = null;
    _events.add(const AuthEvent(null));
  }

  @override
  Future<void> sendPasswordReset(String email) async {}

  @override
  Future<void> updatePassword(String password) async {}

  @override
  Future<void> signInWithProvider(SocialProvider provider) async =>
      throw const AppFailure('Provider not configured');
}

class FakeCatalog implements CatalogRepository {
  FakeCatalog(this.store);
  final FakeStore store;

  @override
  Future<List<String>> fetchCategories() async {
    if (store.catalogFails) throw const AppFailure('Network error. Check your connection and try again.');
    return ['Rings', 'Necklaces', 'Earrings', 'Bracelets'];
  }

  @override
  Future<List<Product>> fetchProducts() async {
    if (store.catalogFails) throw const AppFailure('Network error. Check your connection and try again.');
    return testProducts;
  }
}

class FakeCart implements CartRepository {
  FakeCart(this.store, this.auth);
  final FakeStore store;
  final FakeAuth auth;

  @override
  Future<List<CartLine>> fetch() async =>
      [for (final e in (store.carts[auth.uid] ?? {}).entries) (productId: e.key, quantity: e.value)];

  @override
  Future<void> setQuantity(String productId, int quantity) async {
    if (store.cartWritesFail) throw const AppFailure('Only 1 left in stock');
    (store.carts[auth.uid] ??= {})[productId] = quantity;
  }

  @override
  Future<void> remove(String productId) async => store.carts[auth.uid]?.remove(productId);
}

class FakeWishlist implements WishlistRepository {
  FakeWishlist(this.store, this.auth);
  final FakeStore store;
  final FakeAuth auth;

  @override
  Future<List<String>> fetch() async => List.of(store.wishlists[auth.uid] ?? const []);

  @override
  Future<void> add(String productId) async => (store.wishlists[auth.uid] ??= []).add(productId);

  @override
  Future<void> remove(String productId) async => store.wishlists[auth.uid]?.remove(productId);
}

class FakeOrders implements OrderRepository {
  FakeOrders(this.store, this.auth);
  final FakeStore store;
  final FakeAuth auth;

  @override
  Future<List<Order>> fetchOrders() async => List.of(store.orders[auth.uid] ?? const []);
}

class FakeProfile implements ProfileRepository {
  FakeProfile(this.store, this.auth);
  final FakeStore store;
  final FakeAuth auth;

  @override
  Future<UserProfile> fetchProfile() async => store.profiles[auth.uid]!;

  @override
  Future<void> updateProfile({required String fullName, String? phone}) async =>
      store.profiles[auth.uid] = UserProfile(id: auth.uid, fullName: fullName, phone: phone);

  @override
  Future<String> uploadAvatar(Uint8List bytes, String extension) async => 'https://example.com/a.png';

  @override
  Future<List<Address>> fetchAddresses() async => List.of(store.addresses[auth.uid] ?? const []);

  @override
  Future<Address> saveAddress(Address address) async {
    final list = store.addresses[auth.uid] ??= [];
    final saved = address.copyWith(id: address.id ?? 'a${list.length + 1}', isDefault: list.isEmpty);
    list.add(saved);
    return saved;
  }

  @override
  Future<void> deleteAddress(String id) async => store.addresses[auth.uid]?.removeWhere((a) => a.id == id);

  @override
  Future<void> setDefaultAddress(String id) async {}
}

/// Mirrors the SQL `place_demo_order`: server-side pricing, demo flags, cart cleared.
class FakeDemoPayment implements PaymentService {
  FakeDemoPayment(this.store, this.auth);
  final FakeStore store;
  final FakeAuth auth;

  @override
  PaymentMethodInfo get method =>
      const PaymentMethodInfo(id: 'demo', label: 'Demo Payment', description: 'Test mode', isDemo: true);

  @override
  Future<String> placeOrder({required String addressId}) async {
    final uid = auth.uid;
    final address = (store.addresses[uid] ?? const <Address>[]).where((a) => a.id == addressId).firstOrNull;
    if (address == null) throw const AppFailure('Shipping address not found');
    final cart = store.carts[uid] ?? {};
    if (cart.isEmpty) throw const AppFailure('Your cart is empty');
    final lines = [
      for (final e in cart.entries)
        () {
          final p = testProducts.firstWhere((p) => p.id == e.key);
          return OrderLine(
            productId: p.id,
            name: p.name,
            image: p.image,
            unitPriceCents: p.priceCents,
            quantity: e.value,
          );
        }(),
    ];
    final subtotal = lines.fold(0, (s, l) => s + l.unitPriceCents * l.quantity);
    final id = 'o${(store.orders[uid]?.length ?? 0) + 1}';
    (store.orders[uid] ??= []).insert(
      0,
      Order(
        id: id,
        orderNumber: 'DEMO-$id',
        createdAt: DateTime(2026, 1, 1),
        lines: lines,
        subtotalCents: subtotal,
        shippingCents: CheckoutPricing.shippingCents(subtotal),
        taxCents: CheckoutPricing.taxCents(subtotal),
        totalCents: CheckoutPricing.grandTotalCents(subtotal),
        status: 'placed',
        paymentMode: 'demo',
        paymentStatus: 'demo_completed',
        shippingAddress: address.toMap(),
      ),
    );
    cart.clear();
    return id;
  }
}

Backend fakeBackend(FakeStore store, {FakeAuth? auth}) {
  final a = auth ?? FakeAuth(store);
  return Backend(
    auth: a,
    catalog: FakeCatalog(store),
    cart: FakeCart(store, a),
    wishlist: FakeWishlist(store, a),
    orders: FakeOrders(store, a),
    profile: FakeProfile(store, a),
    payment: FakeDemoPayment(store, a),
  );
}
