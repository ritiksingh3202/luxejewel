import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import '../../core/formatting/money.dart';
import 'package:provider/provider.dart';

import '../../application/app_state.dart';
import '../../core/theme/app_colors.dart';
import '../../domain/pricing/checkout_pricing.dart';
import '../../shared/feedback.dart';
import '../../shared/widgets/luxe_button.dart';
import '../../shared/widgets/luxe_empty_state.dart';
import '../../shared/widgets/luxe_image.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppState>();
    final cart = app.cart;
    final subtotal = app.cartSubtotalCents;
    final ship = CheckoutPricing.shippingCents(subtotal);
    final tax = CheckoutPricing.taxCents(subtotal);
    final total = CheckoutPricing.grandTotalCents(subtotal);

    return Scaffold(
      backgroundColor: AppColors.bgPrimary,
      body: Column(
        children: [
          const _CartHeader(),
          Expanded(
            child: cart.isEmpty
                ? (app.userLoading
                    ? const Center(child: CircularProgressIndicator(color: AppColors.gold))
                    : app.userError != null
                        ? LuxeEmptyState(
                            icon: Icons.cloud_off_rounded,
                            title: 'Could not load your cart',
                            message: app.userError!,
                            actionLabel: 'Retry',
                            onAction: app.refreshUserData,
                          )
                        : _EmptyCart(onShop: () => context.go('/home')))
                : ListView.separated(
                    padding: const EdgeInsets.fromLTRB(24, 18, 24, 200),
                    itemCount: cart.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 14),
                    itemBuilder: (context, i) {
                      final item = cart[i];
                      return Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: AppColors.bgSecondary,
                          borderRadius: BorderRadius.circular(18),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(14),
                              child: SizedBox(
                                width: 92,
                                height: 92,
                                child: LuxeImage(source: item.image, semanticLabel: item.product.name),
                              ),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    item.product.name,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: Theme.of(context).textTheme.titleSmall?.copyWith(color: AppColors.textPrimary),
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    usd.format(item.product.price),
                                    style: Theme.of(context).textTheme.titleSmall?.copyWith(color: AppColors.gold),
                                  ),
                                  const SizedBox(height: 12),
                                  Row(
                                    children: [
                                      _IconCircle(
                                        icon: Icons.remove,
                                        onTap: () => runWithFeedback(
                                          context,
                                          () => app.updateCartQuantity(item.id, item.quantity - 1),
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.symmetric(horizontal: 14),
                                        child: Text('${item.quantity}', style: Theme.of(context).textTheme.titleMedium),
                                      ),
                                      _IconCircle(
                                        icon: Icons.add,
                                        onTap: () => runWithFeedback(
                                          context,
                                          () => app.updateCartQuantity(item.id, item.quantity + 1),
                                        ),
                                      ),
                                      const Spacer(),
                                      IconButton(
                                        tooltip: 'Remove',
                                        onPressed: () {
                                          HapticFeedback.lightImpact();
                                          runWithFeedback(context, () => app.removeFromCart(item.id));
                                        },
                                        icon: const Icon(Icons.delete_outline_rounded, color: AppColors.destructive),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
      bottomSheet: cart.isEmpty
          ? null
          : Container(
              padding: const EdgeInsets.fromLTRB(24, 14, 24, 28),
              decoration: const BoxDecoration(
                color: AppColors.bgSecondary,
                border: Border(top: BorderSide(color: AppColors.divider)),
              ),
              child: SafeArea(
                top: false,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _Line('Subtotal', formatCents(subtotal)),
                    _Line('Shipping', formatCents(ship)),
                    _Line('Tax (8%)', formatCents(tax)),
                    const Divider(height: 22, color: AppColors.divider),
                    Row(
                      children: [
                        Text('Total', style: Theme.of(context).textTheme.titleMedium),
                        const Spacer(),
                        Text(
                          formatCents(total),
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(color: AppColors.gold),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    LuxeButton(
                      label: 'Proceed to Checkout',
                      expanded: true,
                      onPressed: () => context.push('/checkout'),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}

class _CartHeader extends StatelessWidget {
  const _CartHeader();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(24, 14, 24, 14),
      decoration: const BoxDecoration(
        color: AppColors.bgPrimary,
        border: Border(bottom: BorderSide(color: AppColors.divider)),
      ),
      child: Text('Shopping Cart', style: Theme.of(context).textTheme.titleLarge),
    );
  }
}

class _Line extends StatelessWidget {
  const _Line(this.left, this.right);

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

class _EmptyCart extends StatelessWidget {
  const _EmptyCart({required this.onShop});

  final VoidCallback onShop;

  @override
  Widget build(BuildContext context) {
    return LuxeEmptyState(
      icon: Icons.shopping_bag_outlined,
      title: 'Your cart is empty',
      message: 'Add some jewelry to your cart to continue.',
      actionLabel: 'Start Shopping',
      onAction: onShop,
    );
  }
}

class _IconCircle extends StatelessWidget {
  const _IconCircle({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.bgPrimary,
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
        onTap: () {
          HapticFeedback.selectionClick();
          onTap();
        },
        borderRadius: BorderRadius.circular(10),
        child: Padding(
          padding: const EdgeInsets.all(6),
          child: Icon(icon, size: 18, color: AppColors.textPrimary),
        ),
      ),
    );
  }
}
