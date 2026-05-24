import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../application/app_state.dart';
import '../../core/formatting/money.dart';
import '../../core/theme/app_colors.dart';
import '../../domain/models/product.dart';
import 'luxe_image.dart';

class ProductCard extends StatelessWidget {
  const ProductCard({super.key, required this.product});

  final Product product;

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppState>();
    final inWishlist = app.isInWishlist(product.id);

    return Material(
      color: AppColors.bgSecondary,
      borderRadius: BorderRadius.circular(16),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AspectRatio(
            aspectRatio: 1,
            child: Stack(
              fit: StackFit.expand,
              children: [
                InkWell(
                  onTap: () => context.push('/product/${product.id}'),
                  child: LuxeImage(source: product.image, semanticLabel: product.name),
                ),
                Positioned(
                  top: 10,
                  right: 10,
                  child: Material(
                    color: AppColors.bgPrimary.withOpacity(0.75),
                    shape: const CircleBorder(),
                    child: InkWell(
                      customBorder: const CircleBorder(),
                      onTap: () {
                        HapticFeedback.selectionClick();
                        context.read<AppState>().toggleWishlist(product);
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(8),
                        child: Icon(
                          inWishlist ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                          size: 20,
                          color: inWishlist ? AppColors.gold : AppColors.textPrimary,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                InkWell(
                  onTap: () => context.push('/product/${product.id}'),
                  child: Text(
                    product.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    const Icon(Icons.star_rounded, size: 16, color: AppColors.gold),
                    const SizedBox(width: 4),
                    Text(
                      '${product.rating}',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.textSecondary),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        usd.format(product.price),
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              color: AppColors.gold,
                              fontWeight: FontWeight.w700,
                            ),
                      ),
                    ),
                    FilledButton(
                      onPressed: () {
                        HapticFeedback.lightImpact();
                        context.read<AppState>().addToCart(product);
                      },
                      style: FilledButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        textStyle: Theme.of(context).textTheme.labelSmall?.copyWith(fontWeight: FontWeight.w700),
                      ),
                      child: const FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text('Add to Cart'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
