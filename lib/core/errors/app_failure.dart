/// User-presentable error raised by repositories and controllers.
class AppFailure implements Exception {
  const AppFailure(this.message, {this.requiresAuth = false});

  final String message;
  final bool requiresAuth;

  @override
  String toString() => message;
}
