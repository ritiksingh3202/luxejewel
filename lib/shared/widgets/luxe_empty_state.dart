import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import 'luxe_button.dart';
import 'luxe_logo.dart';

class LuxeEmptyState extends StatelessWidget {
  const LuxeEmptyState({
    super.key,
    required this.icon,
    required this.title,
    required this.message,
    this.actionLabel,
    this.onAction,
  });

  final IconData icon;
  final String title;
  final String message;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: AppColors.bgSecondary,
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.divider),
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                const LuxeLogo(size: 44),
                Positioned(
                  bottom: 22,
                  right: 22,
                  child: Icon(icon, size: 28, color: AppColors.gold),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Text(title, style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 8),
          Text(
            message,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          if (actionLabel != null && onAction != null) ...[
            const SizedBox(height: 22),
            LuxeButton(label: actionLabel!, onPressed: onAction),
          ],
        ],
      ),
    );
  }
}
