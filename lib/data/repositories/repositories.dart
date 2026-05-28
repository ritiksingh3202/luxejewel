import 'dart:typed_data';

import '../../core/auth/auth_session.dart';
import '../../domain/models/address.dart';
import '../../domain/models/order.dart';
import '../../domain/models/product.dart';
import '../../domain/payment/payment_service.dart';

enum SocialProvider { google, apple }

class AuthEvent {
  const AuthEvent(this.session, {this.passwordRecovery = false});

  final AuthSession? session;
  final bool passwordRecovery;
}

abstract class AuthRepository {
  AuthSession? get currentSession;
  Stream<AuthEvent> get events;
  Future<void> signIn({required String email, required String password});

  /// Returns `true` when the account must be verified by email before signing in.
  Future<bool> signUp({
    required String name,
    required String email,
    required String password,
    String? phone,
  });
  Future<void> signOut();
  Future<void> sendPasswordReset(String email);
  Future<void> updatePassword(String password);
  Future<void> signInWithProvider(SocialProvider provider);
}

abstract class CatalogRepository {
  Future<List<String>> fetchCategories();
  Future<List<Product>> fetchProducts();
}

typedef CartLine = ({String productId, int quantity});

abstract class CartRepository {
  Future<List<CartLine>> fetch();
  Future<void> setQuantity(String productId, int quantity);
  Future<void> remove(String productId);
}

abstract class WishlistRepository {
  Future<List<String>> fetch();
  Future<void> add(String productId);
  Future<void> remove(String productId);
}

abstract class OrderRepository {
  Future<List<Order>> fetchOrders();
}

abstract class ProfileRepository {
  Future<UserProfile> fetchProfile();
  Future<void> updateProfile({required String fullName, String? phone});
  Future<String> uploadAvatar(Uint8List bytes, String extension);
  Future<List<Address>> fetchAddresses();
  Future<Address> saveAddress(Address address);
  Future<void> deleteAddress(String id);
  Future<void> setDefaultAddress(String id);
}

/// All backend dependencies, injectable for tests.
class Backend {
  const Backend({
    required this.auth,
    required this.catalog,
    required this.cart,
    required this.wishlist,
    required this.orders,
    required this.profile,
    required this.payment,
  });

  final AuthRepository auth;
  final CatalogRepository catalog;
  final CartRepository cart;
  final WishlistRepository wishlist;
  final OrderRepository orders;
  final ProfileRepository profile;
  final PaymentService payment;
}
