import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../core/auth/auth_controller.dart';
import '../features/auth/login_screen.dart';
import '../features/auth/signup_screen.dart';
import '../features/cart/cart_screen.dart';
import '../features/checkout/checkout_screen.dart';
import '../features/home/home_screen.dart';
import '../features/onboarding/onboarding_screen.dart';
import '../features/orders/order_success_screen.dart';
import '../features/orders/orders_screen.dart';
import '../features/product/product_detail_screen.dart';
import '../features/product/products_screen.dart';
import '../features/profile/profile_screen.dart';
import '../features/splash/splash_screen.dart';
import '../features/wishlist/wishlist_screen.dart';
import '../shell/luxe_shell.dart';

final GlobalKey<NavigatorState> rootNavigatorKey = GlobalKey<NavigatorState>();

GoRouter createAppRouter(AuthController auth) {
  return GoRouter(
    navigatorKey: rootNavigatorKey,
    initialLocation: '/splash',
    refreshListenable: auth,
    redirect: (context, state) {
      final signedIn = auth.isSignedIn;
      final path = state.matchedLocation;
      final authRoute = path == '/login' || path == '/signup';
      if (signedIn && authRoute) return '/home';
      return null;
    },
    routes: [
      GoRoute(
        path: '/splash',
        parentNavigatorKey: rootNavigatorKey,
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: '/onboarding',
        parentNavigatorKey: rootNavigatorKey,
        builder: (context, state) => const OnboardingScreen(),
      ),
      GoRoute(
        path: '/login',
        parentNavigatorKey: rootNavigatorKey,
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/signup',
        parentNavigatorKey: rootNavigatorKey,
        builder: (context, state) => const SignupScreen(),
      ),
      ShellRoute(
        builder: (context, state, child) => LuxeShell(child: child),
        routes: [
          GoRoute(
            path: '/home',
            pageBuilder: (context, state) =>
                const NoTransitionPage<void>(child: HomeScreen()),
          ),
          GoRoute(
            path: '/products',
            pageBuilder: (context, state) =>
                const NoTransitionPage<void>(child: ProductsScreen()),
          ),
          GoRoute(
            path: '/product/:id',
            pageBuilder: (context, state) {
              final id = state.pathParameters['id']!;
              return NoTransitionPage<void>(
                child: ProductDetailScreen(productId: id),
              );
            },
          ),
          GoRoute(
            path: '/wishlist',
            pageBuilder: (context, state) =>
                const NoTransitionPage<void>(child: WishlistScreen()),
          ),
          GoRoute(
            path: '/cart',
            pageBuilder: (context, state) =>
                const NoTransitionPage<void>(child: CartScreen()),
          ),
          GoRoute(
            path: '/profile',
            pageBuilder: (context, state) =>
                const NoTransitionPage<void>(child: ProfileScreen()),
          ),
        ],
      ),
      GoRoute(
        path: '/checkout',
        parentNavigatorKey: rootNavigatorKey,
        builder: (context, state) => const CheckoutScreen(),
      ),
      GoRoute(
        path: '/order-success',
        parentNavigatorKey: rootNavigatorKey,
        builder: (context, state) => const OrderSuccessScreen(),
      ),
      GoRoute(
        path: '/orders',
        parentNavigatorKey: rootNavigatorKey,
        builder: (context, state) => const OrdersScreen(),
      ),
    ],
  );
}
