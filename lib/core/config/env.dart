/// Build-time configuration supplied via `--dart-define` / `--dart-define-from-file`.
/// Only public client values belong here — never a service-role/secret key.
abstract final class Env {
  static const supabaseUrl = String.fromEnvironment('SUPABASE_URL');
  static const supabaseKey = String.fromEnvironment('SUPABASE_PUBLISHABLE_KEY');
  static const googleAuthEnabled = bool.fromEnvironment('GOOGLE_AUTH_ENABLED');
  static const appleAuthEnabled = bool.fromEnvironment('APPLE_AUTH_ENABLED');

  static bool get isConfigured => supabaseUrl.isNotEmpty && supabaseKey.isNotEmpty;
}
