import 'package:intl/intl.dart';

class OrderLine {
  const OrderLine({
    required this.productId,
    required this.name,
    required this.image,
    required this.unitPriceCents,
    required this.quantity,
  });

  final String? productId;
  final String name;
  final String image;
  final int unitPriceCents;
  final int quantity;

  double get unitPrice => unitPriceCents / 100;

  factory OrderLine.fromMap(Map<String, dynamic> m) => OrderLine(
        productId: m['product_id'] as String?,
        name: m['product_name'] as String,
        image: (m['image_path'] as String?) ?? '',
        unitPriceCents: (m['unit_price_cents'] as num).toInt(),
        quantity: (m['quantity'] as num).toInt(),
      );
}

class Order {
  const Order({
    required this.id,
    required this.orderNumber,
    required this.createdAt,
    required this.lines,
    required this.subtotalCents,
    required this.shippingCents,
    required this.taxCents,
    required this.totalCents,
    required this.status,
    required this.paymentMode,
    required this.paymentStatus,
    required this.shippingAddress,
  });

  final String id;
  final String orderNumber;
  final DateTime createdAt;
  final List<OrderLine> lines;
  final int subtotalCents;
  final int shippingCents;
  final int taxCents;
  final int totalCents;
  final String status;
  final String paymentMode;
  final String paymentStatus;
  final Map<String, dynamic> shippingAddress;

  bool get isDemo => paymentMode == 'demo';
  double get total => totalCents / 100;
  String get date => DateFormat.yMMMd().format(createdAt.toLocal());
  int get itemCount => lines.fold(0, (n, l) => n + l.quantity);

  String get statusLabel => status.isEmpty ? '' : status[0].toUpperCase() + status.substring(1);

  String get paymentLabel => switch (paymentStatus) {
        'demo_completed' => 'Demo payment — not charged',
        'paid' => 'Paid',
        'pending' => 'Payment pending',
        'failed' => 'Payment failed',
        'refunded' => 'Refunded',
        _ => paymentStatus,
      };

  String get addressLabel {
    final a = shippingAddress;
    final parts = [a['line1'], a['line2'], a['city'], a['postal_code'], a['country']]
        .whereType<String>()
        .where((s) => s.trim().isNotEmpty);
    return '${a['full_name'] ?? ''}\n${parts.join(', ')}';
  }

  factory Order.fromMap(Map<String, dynamic> m) => Order(
        id: m['id'] as String,
        orderNumber: m['order_number'] as String,
        createdAt: DateTime.parse(m['created_at'] as String),
        lines: ((m['order_items'] as List?) ?? const [])
            .map((e) => OrderLine.fromMap(Map<String, dynamic>.from(e as Map)))
            .toList(),
        subtotalCents: (m['subtotal_cents'] as num).toInt(),
        shippingCents: (m['shipping_cents'] as num).toInt(),
        taxCents: (m['tax_cents'] as num).toInt(),
        totalCents: (m['total_cents'] as num).toInt(),
        status: m['status'] as String,
        paymentMode: m['payment_mode'] as String,
        paymentStatus: m['payment_status'] as String,
        shippingAddress: Map<String, dynamic>.from((m['shipping_address'] as Map?) ?? const {}),
      );
}
