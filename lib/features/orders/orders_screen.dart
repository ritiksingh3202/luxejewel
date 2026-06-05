import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../application/app_state.dart';
import '../../core/formatting/money.dart';
import '../../core/theme/app_colors.dart';
import '../../domain/models/order.dart';
import '../../router/nav.dart';
import '../../shared/feedback.dart';
import '../../shared/widgets/luxe_empty_state.dart';
import '../../shared/widgets/luxe_image.dart';

Color orderStatusColor(String status) => switch (status) {
      'delivered' => const Color(0xFF22C55E),
      'cancelled' => AppColors.destructive,
      _ => AppColors.gold,
    };

class DemoBadge extends StatelessWidget {
  const DemoBadge({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: AppColors.gold.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        'DEMO',
        style: Theme.of(context).textTheme.labelSmall?.copyWith(color: AppColors.gold, fontWeight: FontWeight.w700),
      ),
    );
  }
}

class OrdersScreen extends StatelessWidget {
  const OrdersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppState>();
    final orders = app.orders;
    return Scaffold(
      backgroundColor: AppColors.bgPrimary,
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => context.popOrGo('/profile'),
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
        ),
        title: const Text('My Orders'),
      ),
      body: orders.isEmpty
          ? app.userLoading
              ? const Center(child: CircularProgressIndicator(color: AppColors.gold))
              : app.userError != null
                  ? LuxeEmptyState(
                      icon: Icons.cloud_off_rounded,
                      title: 'Could not load orders',
                      message: app.userError!,
                      actionLabel: 'Retry',
                      onAction: app.refreshUserData,
                    )
                  : LuxeEmptyState(
                      icon: Icons.inventory_2_outlined,
                      title: 'No orders yet',
                      message: 'Your order history will appear here after checkout.',
                      actionLabel: 'Start Shopping',
                      onAction: () => context.go('/home'),
                    )
          : RefreshIndicator(
              color: AppColors.gold,
              onRefresh: () => runWithFeedback(context, app.reloadOrders),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 720),
                  child: ListView.separated(
                    padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
                    itemCount: orders.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 14),
                    itemBuilder: (context, i) => _OrderCard(order: orders[i]),
                  ),
                ),
              ),
            ),
    );
  }
}

class _OrderCard extends StatelessWidget {
  const _OrderCard({required this.order});

  final Order order;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).textTheme;
    final o = order;
    return Material(
      color: AppColors.bgSecondary,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: () => context.push('/orders/${o.id}'),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: AppColors.divider),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Wrap(
                          spacing: 8,
                          crossAxisAlignment: WrapCrossAlignment.center,
                          children: [
                            Text('Order ${o.orderNumber}', style: theme.titleSmall),
                            if (o.isDemo) const DemoBadge(),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text('${o.date} • ${o.itemCount} item${o.itemCount == 1 ? '' : 's'}',
                            style: theme.bodySmall),
                      ],
                    ),
                  ),
                  Text(o.statusLabel, style: theme.labelLarge?.copyWith(color: orderStatusColor(o.status))),
                ],
              ),
              const SizedBox(height: 12),
              SizedBox(
                height: 56,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: o.lines.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 8),
                  itemBuilder: (_, i) => ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: SizedBox(
                      width: 56,
                      child: LuxeImage(source: o.lines[i].image, semanticLabel: o.lines[i].name),
                    ),
                  ),
                ),
              ),
              const Divider(color: AppColors.divider, height: 24),
              Row(
                children: [
                  Expanded(child: Text(o.paymentLabel, style: theme.bodySmall)),
                  Text(formatCents(o.totalCents), style: theme.titleMedium?.copyWith(color: AppColors.gold)),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
