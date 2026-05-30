import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../core/errors/app_failure.dart';

/// Runs [action], surfacing failures as snackbars. Returns `true` on success.
/// Guests hitting an auth-only action are sent to login and returned afterwards.
Future<bool> runWithFeedback(
  BuildContext context,
  Future<void> Function() action, {
  String? success,
}) async {
  final messenger = ScaffoldMessenger.maybeOf(context);
  final router = GoRouter.maybeOf(context);
  try {
    await action();
    if (success != null) messenger?.showSnackBar(SnackBar(content: Text(success)));
    return true;
  } on AppFailure catch (e) {
    messenger?.showSnackBar(SnackBar(content: Text(e.message)));
    if (e.requiresAuth && router != null) {
      final from = router.routerDelegate.currentConfiguration.uri.toString();
      router.go('/login?from=${Uri.encodeComponent(from)}');
    }
    return false;
  } catch (_) {
    messenger?.showSnackBar(const SnackBar(content: Text('Something went wrong. Please try again.')));
    return false;
  }
}
