import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../core/auth/auth_session.dart';
import '../../core/errors/app_failure.dart';
import '../../domain/models/address.dart';
import '../../domain/models/order.dart';
import '../../domain/models/product.dart';
import '../../domain/payment/payment_service.dart';
import '../repositories/repositories.dart';

Backend createSupabaseBackend(SupabaseClient client) => Backend(
      auth: SupabaseAuthRepository(client),
      catalog: SupabaseCatalogRepository(client),
      cart: SupabaseCartRepository(client),
      wishlist: SupabaseWishlistRepository(client),
      orders: SupabaseOrderRepository(client),
      profile: SupabaseProfileRepository(client),
      payment: DemoPaymentService(client),
    );

Future<T> _guard<T>(Future<T> Function() run) async {
  try {
    return await run();
  } on AppFailure {
    rethrow;
  } on AuthException catch (e) {
    throw AppFailure(e.message);
  } on PostgrestException catch (e) {
    if (e.code == '42501') throw const AppFailure('Please sign in to continue', requiresAuth: true);
    throw AppFailure(e.message);
  } on StorageException catch (e) {
    throw AppFailure(e.message);
  } catch (e) {
    final s = e.toString();
    if (s.contains('SocketException') || s.contains('ClientException') || s.contains('Failed host lookup')) {
      throw const AppFailure('Network error. Check your connection and try again.');
    }
    throw const AppFailure('Something went wrong. Please try again.');
  }
}

String _uid(SupabaseClient c) {
  final id = c.auth.currentUser?.id;
  if (id == null) throw const AppFailure('Please sign in to continue', requiresAuth: true);
  return id;
}

String? _webRedirect(String path) => kIsWeb ? '${Uri.base.origin}$path' : null;

class SupabaseAuthRepository implements AuthRepository {
  SupabaseAuthRepository(this._c);
  final SupabaseClient _c;

  static AuthSession? _toSession(User? u) {
    if (u == null) return null;
    final email = u.email ?? '';
    final meta = u.userMetadata ?? const {};
    final name = (meta['full_name'] as String?)?.trim();
    return AuthSession(
      userId: u.id,
      email: email,
      displayName: (name == null || name.isEmpty) ? email.split('@').first : name,
      phone: meta['phone'] as String?,
    );
  }

  @override
  AuthSession? get currentSession => _toSession(_c.auth.currentSession?.user);

  @override
  Stream<AuthEvent> get events => _c.auth.onAuthStateChange.map(
        (s) => AuthEvent(
          _toSession(s.session?.user),
          passwordRecovery: s.event == AuthChangeEvent.passwordRecovery,
        ),
      );

  @override
  Future<void> signIn({required String email, required String password}) => _guard(() async {
        await _c.auth.signInWithPassword(email: email.trim(), password: password);
      });

  @override
  Future<bool> signUp({
    required String name,
    required String email,
    required String password,
    String? phone,
  }) =>
      _guard(() async {
        final res = await _c.auth.signUp(
          email: email.trim(),
          password: password,
          data: {'full_name': name.trim(), if ((phone ?? '').trim().isNotEmpty) 'phone': phone!.trim()},
          emailRedirectTo: _webRedirect('/home'),
        );
        if (res.session != null) return false;
        try {
          await _c.auth.signInWithPassword(email: email.trim(), password: password);
          return false;
        } on AuthException {
          return true;
        }
      });

  @override
  Future<void> signOut() => _guard(() => _c.auth.signOut());

  @override
  Future<void> sendPasswordReset(String email) =>
      _guard(() => _c.auth.resetPasswordForEmail(email.trim(), redirectTo: _webRedirect('/reset-password')));

  @override
  Future<void> updatePassword(String password) =>
      _guard(() => _c.auth.updateUser(UserAttributes(password: password)));

  @override
  Future<void> signInWithProvider(SocialProvider provider) => _guard(() async {
        await _c.auth.signInWithOAuth(
          provider == SocialProvider.google ? OAuthProvider.google : OAuthProvider.apple,
          redirectTo: _webRedirect('/home'),
        );
      });
}

class SupabaseCatalogRepository implements CatalogRepository {
  SupabaseCatalogRepository(this._c);
  final SupabaseClient _c;

  @override
  Future<List<String>> fetchCategories() => _guard(() async {
        final rows = await _c.from('categories').select('name').order('sort_order');
        return [for (final r in rows) r['name'] as String];
      });

  @override
  Future<List<Product>> fetchProducts() => _guard(() async {
        final rows = await _c
            .from('products')
            .select('id,name,description,material,price_cents,rating,image_path,stock,categories(name)')
            .eq('is_active', true)
            .order('sort_order');
        return rows.map(Product.fromMap).toList();
      });
}

class SupabaseCartRepository implements CartRepository {
  SupabaseCartRepository(this._c);
  final SupabaseClient _c;
  String? _cartId;
  String? _cartOwner;

  Future<String> _ensureCart() async {
    final uid = _uid(_c);
    if (_cartId != null && _cartOwner == uid) return _cartId!;
    final existing = await _c.from('carts').select('id').eq('user_id', uid).maybeSingle();
    final row = existing ?? await _c.from('carts').insert({'user_id': uid}).select('id').single();
    _cartOwner = uid;
    return _cartId = row['id'] as String;
  }

  @override
  Future<List<CartLine>> fetch() => _guard(() async {
        final cartId = await _ensureCart();
        final rows = await _c.from('cart_items').select('product_id,quantity').eq('cart_id', cartId).order('created_at');
        return [
          for (final r in rows) (productId: r['product_id'] as String, quantity: (r['quantity'] as num).toInt()),
        ];
      });

  @override
  Future<void> setQuantity(String productId, int quantity) => _guard(() async {
        final cartId = await _ensureCart();
        await _c.from('cart_items').upsert(
          {'cart_id': cartId, 'product_id': productId, 'quantity': quantity},
          onConflict: 'cart_id,product_id',
        );
      });

  @override
  Future<void> remove(String productId) => _guard(() async {
        final cartId = await _ensureCart();
        await _c.from('cart_items').delete().eq('cart_id', cartId).eq('product_id', productId);
      });
}

class SupabaseWishlistRepository implements WishlistRepository {
  SupabaseWishlistRepository(this._c);
  final SupabaseClient _c;

  @override
  Future<List<String>> fetch() => _guard(() async {
        final rows = await _c.from('wishlists').select('product_id').eq('user_id', _uid(_c)).order('created_at');
        return [for (final r in rows) r['product_id'] as String];
      });

  @override
  Future<void> add(String productId) => _guard(() async {
        await _c.from('wishlists').upsert({'user_id': _uid(_c), 'product_id': productId}, ignoreDuplicates: true);
      });

  @override
  Future<void> remove(String productId) => _guard(() async {
        await _c.from('wishlists').delete().eq('user_id', _uid(_c)).eq('product_id', productId);
      });
}

class SupabaseOrderRepository implements OrderRepository {
  SupabaseOrderRepository(this._c);
  final SupabaseClient _c;

  @override
  Future<List<Order>> fetchOrders() => _guard(() async {
        final rows = await _c
            .from('orders')
            .select('*, order_items(*)')
            .eq('user_id', _uid(_c))
            .order('created_at', ascending: false);
        return rows.map(Order.fromMap).toList();
      });
}

class SupabaseProfileRepository implements ProfileRepository {
  SupabaseProfileRepository(this._c);
  final SupabaseClient _c;

  @override
  Future<UserProfile> fetchProfile() => _guard(() async {
        final row = await _c.from('profiles').select().eq('id', _uid(_c)).maybeSingle();
        if (row == null) throw const AppFailure('Profile not found. Try signing out and in again.');
        return UserProfile.fromMap(row);
      });

  @override
  Future<void> updateProfile({required String fullName, String? phone}) => _guard(() async {
        await _c.from('profiles').update({
          'full_name': fullName.trim(),
          'phone': (phone ?? '').trim().isEmpty ? null : phone!.trim(),
          'updated_at': DateTime.now().toUtc().toIso8601String(),
        }).eq('id', _uid(_c));
        await _c.auth.updateUser(UserAttributes(data: {'full_name': fullName.trim()}));
      });

  @override
  Future<String> uploadAvatar(Uint8List bytes, String extension) => _guard(() async {
        final uid = _uid(_c);
        final ext = extension.toLowerCase() == 'jpg' ? 'jpeg' : extension.toLowerCase();
        if (!const {'jpeg', 'png', 'webp'}.contains(ext)) {
          throw const AppFailure('Please choose a JPG, PNG or WebP image');
        }
        if (bytes.lengthInBytes > 2 * 1024 * 1024) throw const AppFailure('Image must be under 2 MB');
        final path = '$uid/avatar_${DateTime.now().millisecondsSinceEpoch}.$ext';
        await _c.storage.from('avatars').uploadBinary(
              path,
              bytes,
              fileOptions: FileOptions(contentType: 'image/$ext', upsert: true),
            );
        final url = _c.storage.from('avatars').getPublicUrl(path);
        await _c.from('profiles').update({'avatar_url': url}).eq('id', uid);
        return url;
      });

  @override
  Future<List<Address>> fetchAddresses() => _guard(() async {
        final rows = await _c
            .from('addresses')
            .select()
            .eq('user_id', _uid(_c))
            .order('is_default', ascending: false)
            .order('created_at');
        return rows.map(Address.fromMap).toList();
      });

  @override
  Future<Address> saveAddress(Address address) => _guard(() async {
        final uid = _uid(_c);
        final data = address.toMap();
        final Map<String, dynamic> row;
        if (address.id == null) {
          final hasAny = (await _c.from('addresses').select('id').eq('user_id', uid).limit(1)).isNotEmpty;
          row = await _c
              .from('addresses')
              .insert({...data, 'user_id': uid, 'is_default': !hasAny})
              .select()
              .single();
        } else {
          row = await _c.from('addresses').update(data).eq('id', address.id!).eq('user_id', uid).select().single();
        }
        return Address.fromMap(row);
      });

  @override
  Future<void> deleteAddress(String id) => _guard(() async {
        await _c.from('addresses').delete().eq('id', id).eq('user_id', _uid(_c));
      });

  @override
  Future<void> setDefaultAddress(String id) => _guard(() async {
        final uid = _uid(_c);
        await _c.from('addresses').update({'is_default': false}).eq('user_id', uid).eq('is_default', true);
        await _c.from('addresses').update({'is_default': true}).eq('id', id).eq('user_id', uid);
      });
}

/// Development-only payment: the server marks orders `payment_mode = demo`,
/// `payment_status = demo_completed`; nothing is charged and stock is untouched.
class DemoPaymentService implements PaymentService {
  DemoPaymentService(this._c);
  final SupabaseClient _c;

  static const info = PaymentMethodInfo(
    id: 'demo',
    label: 'Demo Payment',
    description: 'Test mode — no real money is charged and no card details are collected.',
    isDemo: true,
  );

  @override
  PaymentMethodInfo get method => info;

  @override
  Future<String> placeOrder({required String addressId}) => _guard(() async {
        _uid(_c);
        final id = await _c.rpc('place_demo_order', params: {'p_address_id': addressId});
        return id as String;
      });
}
