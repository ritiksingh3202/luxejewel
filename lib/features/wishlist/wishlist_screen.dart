import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../application/app_state.dart';
import '../../core/theme/app_colors.dart';
import '../../shared/widgets/luxe_empty_state.dart';
import '../../shared/widgets/product_grid.dart';

class WishlistScreen extends StatelessWidget {
  const WishlistScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final wishlist = context.watch<AppState>().wishlist;

    return Scaffold(
      backgroundColor: AppColors.bgPrimary,
      body: CustomScrollView(
        slivers: [
          const SliverAppBar(
            pinned: true,
            backgroundColor: AppColors.bgPrimary,
            surfaceTintColor: Colors.transparent,
            title: Text('My Wishlist'),
          ),
          if (wishlist.isEmpty)
            const SliverFillRemaining(
              hasScrollBody: false,
              child: _EmptyWishlist(),
            )
          else ...[
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 8, 24, 12),
                child: Text(
                  '${wishlist.length} ${wishlist.length == 1 ? 'item' : 'items'} saved',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 100),
              sliver: ProductSliverGrid(products: wishlist),
            ),
          ],
        ],
      ),
    );
  }
}

class _EmptyWishlist extends StatelessWidget {
  const _EmptyWishlist();

  @override
  Widget build(BuildContext context) {
    return const LuxeEmptyState(
      icon: Icons.favorite_border_rounded,
      title: 'Your wishlist is empty',
      message: 'Save your favorite pieces to view them later.',
    );
  }
}
