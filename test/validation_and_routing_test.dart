import 'package:flutter_test/flutter_test.dart';
import 'package:luxe_jewel/core/validation/validators.dart';
import 'package:luxe_jewel/domain/pricing/checkout_pricing.dart';
import 'package:luxe_jewel/router/app_router.dart';

void main() {
  group('validators', () {
    test('email', () {
      expect(Validators.email(''), isNotNull);
      expect(Validators.email('bad@'), isNotNull);
      expect(Validators.email('a@b.co'), isNull);
    });

    test('new password requires 8+ chars with letters and digits', () {
      expect(Validators.newPassword('short1'), isNotNull);
      expect(Validators.newPassword('longpassword'), isNotNull);
      expect(Validators.newPassword('Passw0rd1'), isNull);
    });

    test('phone and postal code', () {
      expect(Validators.phone('12'), isNotNull);
      expect(Validators.phone('+1 (555) 000-1234'), isNull);
      expect(Validators.phone('', isRequired: false), isNull);
      expect(Validators.postalCode('10001'), isNull);
      expect(Validators.postalCode('!'), isNotNull);
    });

    test('confirm password', () {
      final v = Validators.confirmPassword(() => 'abc12345');
      expect(v('abc12345'), isNull);
      expect(v('other'), isNotNull);
    });
  });

  test('pricing matches server rules (cents)', () {
    expect(CheckoutPricing.shippingCents(0), 0);
    expect(CheckoutPricing.taxCents(10000), 800);
    expect(CheckoutPricing.grandTotalCents(10000), 15800);
  });

  group('route protection', () {
    String? r(String loc, {bool signedIn = false, bool recovery = false}) =>
        resolveRedirect(uri: Uri.parse(loc), signedIn: signedIn, passwordRecovery: recovery);

    test('guests are sent to login with return path', () {
      for (final p in ['/checkout', '/orders', '/orders/abc', '/profile', '/cart', '/wishlist', '/settings']) {
        expect(r(p), startsWith('/login?from='), reason: p);
      }
    });

    test('public routes stay public', () {
      for (final p in ['/home', '/products', '/product/x', '/login', '/help']) {
        expect(r(p), isNull, reason: p);
      }
    });

    test('signed-in users leave auth pages to the requested page', () {
      expect(r('/login?from=%2Fcheckout', signedIn: true), '/checkout');
      expect(r('/login?from=https%3A%2F%2Fevil.com', signedIn: true), '/home');
      expect(r('/signup', signedIn: true), '/home');
      expect(r('/checkout', signedIn: true), isNull);
    });

    test('root goes to splash and recovery forces reset screen', () {
      expect(r('/'), '/splash');
      expect(r('/home', signedIn: true, recovery: true), '/reset-password');
    });
  });
}
