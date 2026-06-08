import 'package:flutter_test/flutter_test.dart';
import 'package:luxe_jewel/application/app_state.dart';
import 'package:luxe_jewel/core/auth/auth_controller.dart';
import 'package:luxe_jewel/core/errors/app_failure.dart';
import 'package:luxe_jewel/domain/models/address.dart';

import 'fakes.dart';

const _address = Address(
  fullName: 'Test User',
  phone: '+1 555 000 1234',
  line1: '1 Main St',
  city: 'New York',
  postalCode: '10001',
);

void main() {
  late FakeStore store;
  late FakeAuth authRepo;
  late AuthController auth;
  late AppState app;

  Future<void> signIn() async {
    await auth.signIn(email: 'test@example.com', password: 'Passw0rd1');
    await app.setUser(auth.session!.userId);
  }

  setUp(() async {
    store = FakeStore();
    authRepo = FakeAuth(store);
    auth = AuthController(authRepo);
    app = AppState(fakeBackend(store, auth: authRepo));
    await app.loadCatalog();
  });

  group('auth', () {
    test('wrong password surfaces a readable error and stays signed out', () async {
      await expectLater(
        auth.signIn(email: 'test@example.com', password: 'nope'),
        throwsA(isA<AppFailure>().having((e) => e.message, 'message', 'Invalid login credentials')),
      );
      expect(auth.isSignedIn, isFalse);
    });

    test('sign in / sign out toggles session', () async {
      await signIn();
      expect(auth.isSignedIn, isTrue);
      await auth.signOut();
      expect(auth.isSignedIn, isFalse);
    });
  });

  group('catalog', () {
    test('loads products and categories', () {
      expect(app.products, hasLength(3));
      expect(app.categories.first, 'All');
      expect(app.catalogError, isNull);
    });

    test('exposes error state when loading fails', () async {
      store.catalogFails = true;
      final fresh = AppState(fakeBackend(store));
      await fresh.loadCatalog();
      expect(fresh.catalogError, contains('Network error'));
      expect(fresh.products, isEmpty);
    });
  });

  group('cart', () {
    test('guest cannot add to cart', () async {
      await expectLater(
        app.addToCart(testProducts[0]),
        throwsA(isA<AppFailure>().having((e) => e.requiresAuth, 'requiresAuth', isTrue)),
      );
    });

    test('add, update, remove and totals', () async {
      await signIn();
      await app.addToCart(testProducts[0]);
      await app.addToCart(testProducts[1], quantity: 2);
      expect(app.cartCount, 3);
      expect(app.cartSubtotalCents, 249900 + 2 * 189900);
      await app.updateCartQuantity('p1', 2);
      expect(app.quantityInCart('p1'), 2);
      await app.removeFromCart('p2');
      expect(app.cart.map((e) => e.product.id), ['p1']);
    });

    test('rejects quantities above stock and out-of-stock items', () async {
      await signIn();
      expect(() => app.addToCart(testProducts[0], quantity: 4), throwsA(isA<AppFailure>()));
      expect(() => app.addToCart(testProducts[2]), throwsA(isA<AppFailure>()));
      expect(app.cart, isEmpty);
    });

    test('rolls back optimistic update when the server rejects it', () async {
      await signIn();
      store.cartWritesFail = true;
      await expectLater(app.addToCart(testProducts[1]), throwsA(isA<AppFailure>()));
      expect(app.cart, isEmpty);
    });

    test('cart restores after "refresh" and is isolated per user', () async {
      await signIn();
      await app.addToCart(testProducts[1]);
      final reloaded = AppState(fakeBackend(store, auth: authRepo));
      await reloaded.loadCatalog();
      await reloaded.setUser(auth.session!.userId);
      expect(reloaded.cartCount, 1);

      await auth.signOut();
      await app.setUser(null);
      expect(app.cart, isEmpty);
      expect(app.wishlist, isEmpty);
    });
  });

  test('wishlist persists across app instances', () async {
    await signIn();
    await app.toggleWishlist(testProducts[0]);
    expect(app.isInWishlist('p1'), isTrue);

    final reloaded = AppState(fakeBackend(store, auth: authRepo));
    await reloaded.setUser(auth.session!.userId);
    expect(reloaded.wishlist.map((p) => p.id), ['p1']);

    await reloaded.toggleWishlist(testProducts[0]);
    expect(store.wishlists[auth.session!.userId], isEmpty);
  });

  group('demo checkout', () {
    test('creates a demo order with server-computed totals and clears cart', () async {
      await signIn();
      await app.addToCart(testProducts[1], quantity: 2);
      final address = await app.saveAddress(_address);
      final orderId = await app.placeOrder(addressId: address.id!);

      final order = app.orderById(orderId)!;
      expect(order.isDemo, isTrue);
      expect(order.paymentStatus, 'demo_completed');
      expect(order.totalCents, 379800 + 5000 + 30384);
      expect(order.itemCount, 2);
      expect(app.cart, isEmpty);
      expect(store.carts[auth.session!.userId], isEmpty);
    });

    test('empty cart cannot be ordered', () async {
      await signIn();
      final address = await app.saveAddress(_address);
      expect(() => app.placeOrder(addressId: address.id!), throwsA(isA<AppFailure>()));
    });
  });
}
