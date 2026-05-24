import 'package:flutter/foundation.dart';

import 'auth_session.dart';

/// Local auth today; swap implementation for Supabase/Firebase when deploying.
class AuthController extends ChangeNotifier {
  AuthSession? _session;

  AuthSession? get session => _session;
  bool get isSignedIn => _session != null;

  Future<void> signIn({required String email, required String password}) async {
    await Future<void>.delayed(const Duration(milliseconds: 400));
    _session = AuthSession(
      userId: 'local-${email.hashCode}',
      email: email.trim(),
      displayName: email.split('@').first,
    );
    notifyListeners();
  }

  Future<void> signUp({
    required String name,
    required String email,
    required String password,
    String? phone,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 400));
    _session = AuthSession(
      userId: 'local-${email.hashCode}',
      email: email.trim(),
      displayName: name.trim(),
      phone: phone?.trim(),
    );
    notifyListeners();
  }

  void signOut() {
    _session = null;
    notifyListeners();
  }
}
