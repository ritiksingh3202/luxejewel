abstract final class Validators {
  static final _email = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]{2,}$');
  static final _phoneChars = RegExp(r'^[0-9+()\-.\s]+$');
  static final _postal = RegExp(r'^[A-Za-z0-9\- ]{3,10}$');

  static String? required(String? v, [String label = 'This field']) =>
      (v == null || v.trim().isEmpty) ? '$label is required' : null;

  static String? name(String? v) {
    final r = required(v, 'Name');
    if (r != null) return r;
    return v!.trim().length > 120 ? 'Name is too long' : null;
  }

  static String? email(String? v) {
    final r = required(v, 'Email');
    if (r != null) return r;
    return _email.hasMatch(v!.trim()) ? null : 'Enter a valid email address';
  }

  /// Sign-in only checks presence; strength rules apply when creating a password.
  static String? loginPassword(String? v) => required(v, 'Password');

  static String? newPassword(String? v) {
    final r = required(v, 'Password');
    if (r != null) return r;
    if (v!.length < 8) return 'Use at least 8 characters';
    if (!RegExp(r'[A-Za-z]').hasMatch(v) || !RegExp(r'\d').hasMatch(v)) {
      return 'Include both letters and numbers';
    }
    return null;
  }

  static String? Function(String?) confirmPassword(String Function() original) =>
      (v) => v != original() ? 'Passwords do not match' : null;

  static String? phone(String? v, {bool isRequired = true}) {
    if (v == null || v.trim().isEmpty) return isRequired ? 'Phone number is required' : null;
    final digits = v.replaceAll(RegExp(r'\D'), '');
    if (!_phoneChars.hasMatch(v.trim()) || digits.length < 7 || digits.length > 15) {
      return 'Enter a valid phone number';
    }
    return null;
  }

  static String? postalCode(String? v) {
    final r = required(v, 'Postal code');
    if (r != null) return r;
    return _postal.hasMatch(v!.trim()) ? null : 'Enter a valid postal code';
  }
}
