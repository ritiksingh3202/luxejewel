/// Display-side pricing; mirrors `place_demo_order` in SQL, which is authoritative.
abstract final class CheckoutPricing {
  static const int shippingFlatCents = 5000;
  static const double taxRate = 0.08;

  static int shippingCents(int subtotalCents) => subtotalCents > 0 ? shippingFlatCents : 0;

  static int taxCents(int subtotalCents) => (subtotalCents * taxRate).round();

  static int grandTotalCents(int subtotalCents) =>
      subtotalCents + shippingCents(subtotalCents) + taxCents(subtotalCents);
}
