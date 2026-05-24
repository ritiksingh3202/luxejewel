import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';

/// Product and hero imagery: prefers bundled assets, optional network fallback.
class LuxeImage extends StatelessWidget {
  const LuxeImage({
    super.key,
    required this.source,
    this.fit = BoxFit.cover,
    this.borderRadius,
    this.semanticLabel,
  });

  final String source;
  final BoxFit fit;
  final BorderRadius? borderRadius;
  final String? semanticLabel;

  static bool isAsset(String path) => path.startsWith('assets/');

  @override
  Widget build(BuildContext context) {
    Widget child;
    if (isAsset(source)) {
      child = Image.asset(
        source,
        fit: fit,
        semanticLabel: semanticLabel,
        errorBuilder: (_, __, ___) => _errorPlaceholder(),
      );
    } else {
      child = CachedNetworkImage(
        imageUrl: source,
        fit: fit,
        fadeInDuration: const Duration(milliseconds: 200),
        placeholder: (_, __) => _loadingPlaceholder(),
        errorWidget: (_, __, ___) => _errorPlaceholder(),
      );
    }

    if (borderRadius != null) {
      return ClipRRect(borderRadius: borderRadius!, child: child);
    }
    return child;
  }

  Widget _loadingPlaceholder() => Container(
        color: AppColors.divider,
        alignment: Alignment.center,
        child: const SizedBox(
          width: 28,
          height: 28,
          child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.gold),
        ),
      );

  Widget _errorPlaceholder() => Container(
        color: AppColors.bgSecondary,
        alignment: Alignment.center,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.diamond_outlined, size: 36, color: AppColors.gold.withOpacity(0.85)),
            const SizedBox(height: 8),
            Text(
              'LuxeJewel',
              style: TextStyle(
                color: AppColors.textSecondary.withOpacity(0.8),
                fontSize: 11,
                letterSpacing: 1.2,
              ),
            ),
          ],
        ),
      );
}
