import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../application/app_state.dart';
import '../../core/formatting/money.dart';
import '../../core/theme/app_colors.dart';
import '../../router/nav.dart';
import '../../shared/widgets/luxe_empty_state.dart';
import '../../shared/widgets/luxe_image.dart';
import 'orders_screen.dart';

class OrderDetailScreen extends StatelessWidget {
  const OrderDetailScreen({super.key, required this.orderId});

  final String orderId;

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppState>();
    final o = app.orderById(orderId);
    final theme = Theme.of(context).textTheme;

    Widget row(String l, String r, {TextStyle? style}) => Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Row(children: [Text(l, style: theme.bodySmall), const Spacer(), Text(r, style: style ?? theme.bodySmall)]),
        );

    return Scaffold(
      backgroundColor: AppColors.bgPrimary,
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => context.popOrGo('/orders'),
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
        ),
        title: const Text('Order Details'),
      ),
      body: o == null
          ? (app.userLoading
              ? const Center(child: CircularProgressIndicator(color: AppColors.gold))
              : const LuxeEmptyState(
                  icon: Icons.receipt_long_outlined,
                  title: 'Order not found',
                  message: 'This order does not exist or belongs to another account.',
                ))
          : Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 720),
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(24, 12, 24, 32),
                  children: [
                    Wrap(
                      spacing: 8,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        Text(o.orderNumber, style: theme.titleLarge),
                        if (o.isDemo) const DemoBadge(),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text('Placed ${o.date}', style: theme.bodySmall),
                    const SizedBox(height: 4),
                    Text('Status: ${o.statusLabel}', style: theme.bodySmall?.copyWith(color: orderStatusColor(o.status))),
                    if (o.isDemo) ...[
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppColors.gold.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppColors.gold.withValues(alpha: 0.4)),
                        ),
                        child: Text(
                          'Test order: no real payment was processed and it will not be fulfilled.',
                          style: theme.bodySmall,
                        ),
                      ),
                    ],
                    const SizedBox(height: 20),
                    Text('Items', style: theme.titleMedium),
                    const SizedBox(height: 10),
                    for (final l in o.lines)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: Row(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: SizedBox(width: 64, height: 64, child: LuxeImage(source: l.image, semanticLabel: l.name)),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(l.name, style: theme.bodyMedium),
                                  const SizedBox(height: 4),
                                  Text('Qty: ${l.quantity} × ${formatCents(l.unitPriceCents)}', style: theme.bodySmall),
                                ],
                              ),
                            ),
                            Text(formatCents(l.unitPriceCents * l.quantity),
                                style: theme.bodySmall?.copyWith(color: AppColors.gold)),
                          ],
                        ),
                      ),
                    const SizedBox(height: 12),
                    Text('Shipping Address', style: theme.titleMedium),
                    const SizedBox(height: 8),
                    Text(o.addressLabel, style: theme.bodySmall),
                    const SizedBox(height: 20),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.bgSecondary,
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(color: AppColors.divider),
                      ),
                      child: Column(
                        children: [
                          row('Subtotal', formatCents(o.subtotalCents)),
                          row('Shipping', formatCents(o.shippingCents)),
                          row('Tax', formatCents(o.taxCents)),
                          row('Payment', o.paymentLabel),
                          const Divider(color: AppColors.divider),
                          row('Total', formatCents(o.totalCents),
                              style: theme.titleMedium?.copyWith(color: AppColors.gold)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
