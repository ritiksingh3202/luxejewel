/// Pure pricing rules shared by cart, checkout, and order persistence.
abstract final class CheckoutPricing {
  static const double shippingFlat = 50;
  static const double taxRate = 0.08;

  static double subtotal(List<(double unitPrice, int qty)> lines) {
    var sum = 0.0;
    for (final (p, q) in lines) {
      sum += p * q;
    }
    return sum;
  }

  static double shippingForSubtotal(double subtotal) =>
      subtotal > 0 ? shippingFlat : 0;

  static double tax(double subtotal) => subtotal * taxRate;

  static double grandTotal(double subtotal) {
    final ship = shippingForSubtotal(subtotal);
    return subtotal + ship + tax(subtotal);
  }
}
