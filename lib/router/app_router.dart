import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../core/auth/auth_controller.dart';
import '../features/auth/forgot_password_screen.dart';
import '../features/auth/login_screen.dart';
import '../features/auth/reset_password_screen.dart';
import '../features/auth/signup_screen.dart';
import '../features/cart/cart_screen.dart';
import '../features/checkout/checkout_screen.dart';
import '../features/home/home_screen.dart';
import '../features/misc/not_found_screen.dart';
import '../features/onboarding/onboarding_screen.dart';
import '../features/orders/order_detail_screen.dart';
import '../features/orders/order_success_screen.dart';
import '../features/orders/orders_screen.dart';
import '../features/product/product_detail_screen.dart';
import '../features/product/products_screen.dart';
import '../features/profile/addresses_screen.dart';
import '../features/profile/edit_profile_screen.dart';
import '../features/profile/help_screen.dart';
import '../features/profile/profile_screen.dart';
import '../features/profile/settings_screen.dart';
import '../features/splash/splash_screen.dart';
import '../features/wishlist/wishlist_screen.dart';
import '../shell/luxe_shell.dart';

final GlobalKey<NavigatorState> rootNavigatorKey = GlobalKey<NavigatorState>();

const _protectedPrefixes = [
  '/cart',
  '/wishlist',
  '/profile',
  '/checkout',
  '/orders',
  '/order-success',
  '/addresses',
  '/settings',
];
const _guestOnly = ['/login', '/signup', '/forgot-password'];

bool isProtectedPath(String path) =>
    _protectedPrefixes.any((p) => path == p || path.startsWith('$p/'));

/// Pure redirect rules, exposed for tests.
String? resolveRedirect({
  required Uri uri,
  required bool signedIn,
  required bool passwordRecovery,
}) {
  final path = uri.path;
  if (path == '/' || path.isEmpty) return '/splash';
  if (passwordRecovery && path != '/reset-password') return '/reset-password';
  if (!signedIn && isProtectedPath(path)) {
    return '/login?from=${Uri.encodeComponent(uri.toString())}';
  }
  if (!signedIn && path == '/reset-password') return '/forgot-password';
  if (signedIn && _guestOnly.contains(path)) {
    final from = uri.queryParameters['from'];
    final safe = from != null && from.startsWith('/') && !from.startsWith('//');
    return safe ? from : '/home';
  }
  return null;
}

NoTransitionPage<void> _tab(Widget child) => NoTransitionPage<void>(child: child);

GoRouter createAppRouter(AuthController auth) {
  return GoRouter(
    navigatorKey: rootNavigatorKey,
    initialLocation: '/splash',
    refreshListenable: auth,
    redirect: (context, state) => resolveRedirect(
      uri: state.uri,
      signedIn: auth.isSignedIn,
      passwordRecovery: auth.passwordRecovery,
    ),
    errorBuilder: (context, state) => NotFoundScreen(location: state.uri.toString()),
    routes: [
      GoRoute(path: '/splash', builder: (_, __) => const SplashScreen()),
      GoRoute(path: '/onboarding', builder: (_, __) => const OnboardingScreen()),
      GoRoute(path: '/login', builder: (_, __) => const LoginScreen()),
      GoRoute(path: '/signup', builder: (_, __) => const SignupScreen()),
      GoRoute(path: '/forgot-password', builder: (_, __) => const ForgotPasswordScreen()),
      GoRoute(path: '/reset-password', builder: (_, __) => const ResetPasswordScreen()),
      ShellRoute(
        builder: (context, state, child) => LuxeShell(child: child),
        routes: [
          GoRoute(path: '/home', pageBuilder: (_, __) => _tab(const HomeScreen())),
          GoRoute(
            path: '/products',
            pageBuilder: (_, state) => _tab(ProductsScreen(initialQuery: state.uri.queryParameters['q'])),
          ),
          GoRoute(
            path: '/product/:id',
            pageBuilder: (_, state) => _tab(ProductDetailScreen(productId: state.pathParameters['id']!)),
          ),
          GoRoute(path: '/wishlist', pageBuilder: (_, __) => _tab(const WishlistScreen())),
          GoRoute(path: '/cart', pageBuilder: (_, __) => _tab(const CartScreen())),
          GoRoute(path: '/profile', pageBuilder: (_, __) => _tab(const ProfileScreen())),
        ],
      ),
      GoRoute(path: '/profile/edit', builder: (_, __) => const EditProfileScreen()),
      GoRoute(path: '/addresses', builder: (_, __) => const AddressesScreen()),
      GoRoute(path: '/settings', builder: (_, __) => const SettingsScreen()),
      GoRoute(path: '/help', builder: (_, __) => const HelpScreen()),
      GoRoute(path: '/checkout', builder: (_, __) => const CheckoutScreen()),
      GoRoute(
        path: '/order-success',
        builder: (_, state) => OrderSuccessScreen(orderId: state.uri.queryParameters['id']),
      ),
      GoRoute(
        path: '/orders',
        builder: (_, __) => const OrdersScreen(),
        routes: [
          GoRoute(
            path: ':id',
            builder: (_, state) => OrderDetailScreen(orderId: state.pathParameters['id']!),
          ),
        ],
      ),
    ],
  );
}
