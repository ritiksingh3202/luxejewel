import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../application/app_state.dart';
import '../../core/formatting/money.dart';
import '../../core/theme/app_colors.dart';
import '../../shared/widgets/luxe_button.dart';

class OrderSuccessScreen extends StatefulWidget {
  const OrderSuccessScreen({super.key, this.orderId});

  final String? orderId;

  @override
  State<OrderSuccessScreen> createState() => _OrderSuccessScreenState();
}

class _OrderSuccessScreenState extends State<OrderSuccessScreen> with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(vsync: this, duration: const Duration(milliseconds: 650))
    ..forward();

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final id = widget.orderId;
    final order = id == null ? null : context.watch<AppState>().orderById(id);
    return Scaffold(
      backgroundColor: AppColors.bgPrimary,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            children: [
              const Spacer(),
              ScaleTransition(
                scale: CurvedAnimation(parent: _c, curve: Curves.elasticOut),
                child: const Icon(Icons.check_circle_rounded, size: 104, color: AppColors.gold),
              ),
              const SizedBox(height: 18),
              FadeTransition(
                opacity: CurvedAnimation(parent: _c, curve: const Interval(0.35, 1, curve: Curves.easeOut)),
                child: SlideTransition(
                  position: Tween<Offset>(begin: const Offset(0, 0.08), end: Offset.zero).animate(
                    CurvedAnimation(parent: _c, curve: const Interval(0.35, 1, curve: Curves.easeOutCubic)),
                  ),
                  child: Column(
                    children: [
                      Text('Demo Order Placed!', style: Theme.of(context).textTheme.headlineSmall),
                      const SizedBox(height: 10),
                      Text(
                        order != null
                            ? 'Order ${order.orderNumber} • ${formatCents(order.totalCents)}'
                            : 'Your order has been saved',
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'This was a test order. No real payment was processed and nothing will be shipped.',
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
              ),
              const Spacer(),
              LuxeButton(
                label: order != null ? 'View Order' : 'View Orders',
                expanded: true,
                onPressed: () => context.go(order != null ? '/orders/${order.id}' : '/orders'),
              ),
              const SizedBox(height: 12),
              LuxeButton(
                label: 'Continue Shopping',
                variant: LuxeButtonVariant.outline,
                expanded: true,
                onPressed: () => context.go('/home'),
              ),
              const SizedBox(height: 18),
            ],
          ),
        ),
      ),
    );
  }
}
