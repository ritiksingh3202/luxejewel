import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/formatting/money.dart';
import 'package:provider/provider.dart';

import '../../application/app_state.dart';
import '../../core/theme/app_colors.dart';
import '../../domain/models/order.dart';
import '../../shared/widgets/luxe_empty_state.dart';
import '../../shared/widgets/luxe_image.dart';

class OrdersScreen extends StatelessWidget {
  const OrdersScreen({super.key});

  Color _statusColor(OrderStatus s) {
    switch (s) {
      case OrderStatus.delivered:
        return const Color(0xFF22C55E);
      case OrderStatus.pending:
        return AppColors.gold;
      case OrderStatus.cancelled:
        return AppColors.destructive;
    }
  }

  String _statusLabel(OrderStatus s) {
    switch (s) {
      case OrderStatus.delivered:
        return 'Delivered';
      case OrderStatus.pending:
        return 'Pending';
      case OrderStatus.cancelled:
        return 'Cancelled';
    }
  }

  @override
  Widget build(BuildContext context) {
    final orders = context.watch<AppState>().orders;
    return Scaffold(
      backgroundColor: AppColors.bgPrimary,
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => context.canPop() ? context.pop() : context.go('/profile'),
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
        ),
        title: const Text('My Orders'),
      ),
      body: orders.isEmpty
          ? const LuxeEmptyState(
              icon: Icons.inventory_2_outlined,
              title: 'No orders yet',
              message: 'Your order history will appear here after checkout.',
            )
          : ListView.separated(
              padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
              itemCount: orders.length,
              separatorBuilder: (_, __) => const SizedBox(height: 14),
              itemBuilder: (context, i) {
                final o = orders[i];
                return Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.bgSecondary,
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
                                Text('Order #${o.id}', style: Theme.of(context).textTheme.titleSmall),
                                const SizedBox(height: 4),
                                Text(o.date, style: Theme.of(context).textTheme.bodySmall),
                              ],
                            ),
                          ),
                          Text(
                            _statusLabel(o.status),
                            style: Theme.of(context).textTheme.labelLarge?.copyWith(color: _statusColor(o.status)),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      for (final item in o.items) ...[
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: SizedBox(
                                width: 64,
                                height: 64,
                                child: LuxeImage(source: item.product.image, semanticLabel: item.product.name),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(item.product.name, style: Theme.of(context).textTheme.bodyMedium),
                                  const SizedBox(height: 4),
                                  Text('Qty: ${item.quantity}', style: Theme.of(context).textTheme.bodySmall),
                                  const SizedBox(height: 4),
                                  Text(
                                    usd.format(item.product.price),
                                    style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.gold),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                      ],
                      const Divider(color: AppColors.divider),
                      Row(
                        children: [
                          Text('Total Amount', style: Theme.of(context).textTheme.bodySmall),
                          const Spacer(),
                          Text(
                            usd.format(o.total),
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(color: AppColors.gold),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
    );
  }
}
