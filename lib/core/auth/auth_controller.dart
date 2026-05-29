import 'dart:async';

import 'package:flutter/foundation.dart';

import '../../data/repositories/repositories.dart';
import 'auth_session.dart';

/// Auth state for routing and UI; backed by Supabase Auth (session persisted by the SDK).
class AuthController extends ChangeNotifier {
  AuthController(this._repo) {
    _session = _repo.currentSession;
    _sub = _repo.events.listen(_onEvent);
  }

  final AuthRepository _repo;
  late final StreamSubscription<AuthEvent> _sub;
  AuthSession? _session;
  bool _passwordRecovery = false;

  AuthSession? get session => _session;
  bool get isSignedIn => _session != null;

  /// True after the user opened a password-reset link; router forces /reset-password.
  bool get passwordRecovery => _passwordRecovery;

  void _onEvent(AuthEvent e) {
    _session = e.session;
    if (e.passwordRecovery) _passwordRecovery = true;
    notifyListeners();
  }

  void _syncSession() {
    _session = _repo.currentSession;
    notifyListeners();
  }

  Future<void> signIn({required String email, required String password}) async {
    await _repo.signIn(email: email, password: password);
    _syncSession();
  }

  /// Returns `true` when email verification is required before signing in.
  Future<bool> signUp({
    required String name,
    required String email,
    required String password,
    String? phone,
  }) async {
    final needsVerification = await _repo.signUp(name: name, email: email, password: password, phone: phone);
    _syncSession();
    return needsVerification;
  }

  Future<void> signOut() async {
    await _repo.signOut();
    _passwordRecovery = false;
    _syncSession();
  }

  Future<void> sendPasswordReset(String email) => _repo.sendPasswordReset(email);

  Future<void> updatePassword(String password) async {
    await _repo.updatePassword(password);
    _passwordRecovery = false;
    notifyListeners();
  }

  Future<void> signInWithProvider(SocialProvider provider) => _repo.signInWithProvider(provider);

  @override
  void dispose() {
    _sub.cancel();
    super.dispose();
  }
}
