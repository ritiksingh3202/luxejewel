/// Describes a checkout payment option shown in the UI.
class PaymentMethodInfo {
  const PaymentMethodInfo({
    required this.id,
    required this.label,
    required this.description,
    required this.isDemo,
  });

  final String id;
  final String label;
  final String description;
  final bool isDemo;
}

/// Checkout boundary. A real gateway implementation (create intent → confirm →
/// server-side verification/webhook) can replace the demo one without UI changes.
abstract class PaymentService {
  PaymentMethodInfo get method;

  /// Creates the order server-side and returns its id. Totals are computed by the server.
  Future<String> placeOrder({required String addressId});
}
