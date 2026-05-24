import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import '../../core/formatting/money.dart';
import 'package:provider/provider.dart';

import '../../application/app_state.dart';
import '../../core/theme/app_colors.dart';
import '../../domain/models/product.dart';
import '../../shared/widgets/luxe_button.dart';
import '../../shared/widgets/luxe_image.dart';

class ProductDetailScreen extends StatefulWidget {
  const ProductDetailScreen({super.key, required this.productId});

  final String productId;

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  int _qty = 1;

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppState>();
    final product = app.catalog.byId(widget.productId);
    if (product == null) {
      return Scaffold(
        backgroundColor: AppColors.bgPrimary,
        appBar: AppBar(),
        body: const Center(child: Text('Product not found')),
      );
    }

    final inWishlist = app.isInWishlist(product.id);
    final fullStars = product.rating.floor();

    return Scaffold(
      backgroundColor: AppColors.bgPrimary,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            pinned: true,
            backgroundColor: AppColors.bgPrimary.withOpacity(0.92),
            surfaceTintColor: Colors.transparent,
            leading: IconButton(
              onPressed: () => context.pop(),
              icon: const Icon(Icons.arrow_back_ios_new_rounded),
            ),
            actions: [
              IconButton(
                onPressed: () {
                  HapticFeedback.selectionClick();
                  context.read<AppState>().toggleWishlist(product);
                },
                icon: Icon(
                  inWishlist ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                  color: inWishlist ? AppColors.gold : AppColors.textPrimary,
                ),
              ),
            ],
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(28),
                    child: AspectRatio(
                      aspectRatio: 1,
                      child: LuxeImage(source: product.image, semanticLabel: product.name),
                    ),
                  ),
                  const SizedBox(height: 18),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          product.name,
                          style: Theme.of(context).textTheme.headlineSmall,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        usd.format(product.price),
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(color: AppColors.gold),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      for (var i = 0; i < 5; i++)
                        Icon(
                          i < fullStars ? Icons.star_rounded : Icons.star_border_rounded,
                          size: 18,
                          color: i < fullStars ? AppColors.gold : AppColors.divider,
                        ),
                      const SizedBox(width: 8),
                      Text(
                        '${product.rating} (127 reviews)',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                  if (product.material != null) ...[
                    const SizedBox(height: 10),
                    Text.rich(
                      TextSpan(
                        style: Theme.of(context).textTheme.bodySmall,
                        children: [
                          const TextSpan(text: 'Material: '),
                          TextSpan(
                            text: product.material,
                            style: const TextStyle(color: AppColors.gold, fontWeight: FontWeight.w600),
                          ),
                        ],
                      ),
                    ),
                  ],
                  const SizedBox(height: 22),
                  Text('Description', style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 8),
                  Text(product.description, style: Theme.of(context).textTheme.bodyMedium),
                  const SizedBox(height: 22),
                  Text('Quantity', style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      _QtyButton(
                        icon: Icons.remove,
                        onTap: () => setState(() => _qty = (_qty - 1).clamp(1, 999)),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 18),
                        child: Text('$_qty', style: Theme.of(context).textTheme.titleLarge),
                      ),
                      _QtyButton(
                        icon: Icons.add,
                        onTap: () => setState(() => _qty = (_qty + 1).clamp(1, 999)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 22),
                  Text('Features', style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 12),
                  const _Bullet('Certified authentic gemstones'),
                  const _Bullet('Lifetime warranty included'),
                  const _Bullet('Free luxury gift box'),
                  const _Bullet('Complimentary resizing service'),
                  const SizedBox(height: 22),
                  Row(
                    children: [
                      Expanded(
                        child: SizedBox(
                          height: 52,
                          child: OutlinedButton(
                            onPressed: () {
                              HapticFeedback.selectionClick();
                              context.read<AppState>().toggleWishlist(product);
                            },
                            child: Icon(
                              inWishlist ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                              color: inWishlist ? AppColors.gold : AppColors.textPrimary,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        flex: 2,
                        child: LuxeButton(
                          label: 'Add to Cart',
                          icon: const Icon(Icons.shopping_cart_outlined, size: 20),
                          expanded: true,
                          onPressed: () {
                            HapticFeedback.mediumImpact();
                            final state = context.read<AppState>();
                            for (var i = 0; i < _qty; i++) {
                              state.addToCart(product);
                            }
                            context.push('/cart');
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _QtyButton extends StatelessWidget {
  const _QtyButton({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.bgSecondary,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Icon(icon, color: AppColors.textPrimary),
        ),
      ),
    );
  }
}

class _Bullet extends StatelessWidget {
  const _Bullet(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 6,
            height: 6,
            margin: const EdgeInsets.only(top: 7),
            decoration: const BoxDecoration(color: AppColors.gold, shape: BoxShape.circle),
          ),
          const SizedBox(width: 12),
          Expanded(child: Text(text, style: Theme.of(context).textTheme.bodyMedium)),
        ],
      ),
    );
  }
}
