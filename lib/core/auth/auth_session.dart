class AuthSession {
  const AuthSession({
    required this.userId,
    required this.email,
    required this.displayName,
    this.phone,
  });

  final String userId;
  final String email;
  final String displayName;
  final String? phone;
}
