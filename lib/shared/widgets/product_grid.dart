import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../domain/models/product.dart';
import 'luxe_empty_state.dart';
import 'product_card.dart';

/// Responsive product grid: 2 columns on phones, more on tablet/desktop.
class ProductSliverGrid extends StatelessWidget {
  const ProductSliverGrid({super.key, required this.products});

  final List<Product> products;

  @override
  Widget build(BuildContext context) {
    return SliverLayoutBuilder(
      builder: (context, constraints) {
        const spacing = 14.0;
        final width = constraints.crossAxisExtent;
        final count = (width / 240).floor().clamp(2, 6);
        final tile = (width - spacing * (count - 1)) / count;
        return SliverGrid(
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: count,
            mainAxisSpacing: spacing,
            crossAxisSpacing: spacing,
            mainAxisExtent: tile + 140,
          ),
          delegate: SliverChildBuilderDelegate(
            (context, i) => ProductCard(product: products[i]),
            childCount: products.length,
          ),
        );
      },
    );
  }
}

/// Loading / error / empty placeholder for catalog-driven slivers.
class CatalogStatusSliver extends StatelessWidget {
  const CatalogStatusSliver({
    super.key,
    required this.loading,
    required this.error,
    required this.onRetry,
    this.emptyMessage,
  });

  final bool loading;
  final String? error;
  final VoidCallback onRetry;
  final String? emptyMessage;

  @override
  Widget build(BuildContext context) {
    final Widget child;
    if (loading) {
      child = const Center(child: CircularProgressIndicator(color: AppColors.gold));
    } else if (error != null) {
      child = LuxeEmptyState(
        icon: Icons.cloud_off_rounded,
        title: 'Could not load products',
        message: error!,
        actionLabel: 'Retry',
        onAction: onRetry,
      );
    } else {
      child = LuxeEmptyState(
        icon: Icons.search_off_rounded,
        title: 'No products found',
        message: emptyMessage ?? 'Try a different search or filter.',
      );
    }
    return SliverToBoxAdapter(
      child: Padding(padding: const EdgeInsets.symmetric(vertical: 32), child: child),
    );
  }
}
