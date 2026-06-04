import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../application/app_state.dart';
import '../../core/formatting/money.dart';
import '../../core/theme/app_colors.dart';
import '../../domain/pricing/checkout_pricing.dart';
import '../../router/nav.dart';
import '../../shared/feedback.dart';
import '../../shared/widgets/luxe_button.dart';
import '../../shared/widgets/luxe_image.dart';
import '../profile/address_form_sheet.dart';

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  String? _addressId;
  bool _placing = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final app = context.read<AppState>();
      if (app.cart.isEmpty && !app.userLoading) context.go('/cart');
    });
  }

  Future<void> _addAddress() async {
    final saved = await showAddressForm(context);
    if (saved != null && mounted) setState(() => _addressId = saved.id);
  }

  Future<void> _place(String addressId) async {
    setState(() => _placing = true);
    String? orderId;
    await runWithFeedback(context, () async {
      orderId = await context.read<AppState>().placeOrder(addressId: addressId);
    });
    if (!mounted) return;
    setState(() => _placing = false);
    if (orderId != null) context.go('/order-success?id=$orderId');
  }

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppState>();
    final subtotal = app.cartSubtotalCents;
    final ship = CheckoutPricing.shippingCents(subtotal);
    final tax = CheckoutPricing.taxCents(subtotal);
    final total = CheckoutPricing.grandTotalCents(subtotal);
    final addresses = app.addresses;
    final selectedId = addresses.any((a) => a.id == _addressId) ? _addressId : app.defaultAddress?.id;
    final method = app.paymentMethod;
    final theme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: AppColors.bgPrimary,
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => context.popOrGo('/cart'),
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
        ),
        title: const Text('Checkout'),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 720),
          child: ListView(
            padding: const EdgeInsets.fromLTRB(24, 10, 24, 32),
            children: [
              Text('Your Items', style: theme.titleMedium),
              const SizedBox(height: 12),
              for (final item in app.cart)
                Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Row(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: SizedBox(
                          width: 52,
                          height: 52,
                          child: LuxeImage(source: item.image, semanticLabel: item.name),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text('${item.name} × ${item.quantity}',
                            maxLines: 2, overflow: TextOverflow.ellipsis, style: theme.bodyMedium),
                      ),
                      Text(formatCents(item.product.priceCents * item.quantity), style: theme.bodySmall),
                    ],
                  ),
                ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(child: Text('Delivery Address', style: theme.titleMedium)),
                  TextButton.icon(
                    onPressed: _addAddress,
                    icon: const Icon(Icons.add, size: 18),
                    label: const Text('Add New'),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              if (addresses.isEmpty)
                Text('Add a delivery address to continue.', style: theme.bodySmall)
              else
                for (final a in addresses)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: _SelectTile(
                      selected: a.id == selectedId,
                      onTap: () => setState(() => _addressId = a.id),
                      leading: const Icon(Icons.location_on_outlined, color: AppColors.gold),
                      title: a.fullName,
                      subtitle: '${a.singleLine}\n${a.phone}',
                    ),
                  ),
              const SizedBox(height: 16),
              Text('Payment Method', style: theme.titleMedium),
              const SizedBox(height: 12),
              _SelectTile(
                selected: true,
                onTap: null,
                leading: const Icon(Icons.science_outlined, color: AppColors.gold),
                title: method.label,
                subtitle: method.description,
                badge: method.isDemo ? 'TEST MODE' : null,
              ),
              const SizedBox(height: 22),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.bgSecondary,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: AppColors.divider),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Order Summary', style: theme.titleMedium),
                    const SizedBox(height: 12),
                    _SummaryRow('Subtotal', formatCents(subtotal)),
                    _SummaryRow('Shipping', formatCents(ship)),
                    _SummaryRow('Tax (8%)', formatCents(tax)),
                    const Divider(height: 22, color: AppColors.divider),
                    Row(
                      children: [
                        Text('Total', style: theme.titleMedium),
                        const Spacer(),
                        Text(formatCents(total), style: theme.titleMedium?.copyWith(color: AppColors.gold)),
                      ],
                    ),
                    if (method.isDemo) ...[
                      const SizedBox(height: 8),
                      Text('Demo order — you will not be charged.', style: theme.bodySmall),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 18),
              LuxeButton(
                label: _placing
                    ? 'Placing order…'
                    : '${method.isDemo ? 'Place Demo Order' : 'Place Order'} — ${formatCents(total)}',
                expanded: true,
                onPressed: (app.cart.isEmpty || selectedId == null || _placing) ? null : () => _place(selectedId),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SelectTile extends StatelessWidget {
  const _SelectTile({
    required this.selected,
    required this.onTap,
    required this.leading,
    required this.title,
    required this.subtitle,
    this.badge,
  });

  final bool selected;
  final VoidCallback? onTap;
  final Widget leading;
  final String title;
  final String subtitle;
  final String? badge;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).textTheme;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.bgSecondary,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: selected ? AppColors.gold : AppColors.divider, width: selected ? 1.5 : 1),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              selected ? Icons.radio_button_checked : Icons.radio_button_off,
              color: selected ? AppColors.gold : AppColors.textSecondary,
            ),
            const SizedBox(width: 10),
            leading,
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Wrap(
                    spacing: 8,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      Text(title, style: theme.titleSmall),
                      if (badge != null)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppColors.gold.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(badge!,
                              style: theme.labelSmall?.copyWith(color: AppColors.gold, fontWeight: FontWeight.w700)),
                        ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(subtitle, style: theme.bodySmall),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  const _SummaryRow(this.left, this.right);

  final String left;
  final String right;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Text(left, style: Theme.of(context).textTheme.bodySmall),
          const Spacer(),
          Text(right, style: Theme.of(context).textTheme.bodySmall),
        ],
      ),
    );
  }
}
