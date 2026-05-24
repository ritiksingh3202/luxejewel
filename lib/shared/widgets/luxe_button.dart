import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';

enum LuxeButtonVariant { primary, secondary, outline }

class LuxeButton extends StatelessWidget {
  const LuxeButton({
    super.key,
    required this.label,
    this.onPressed,
    this.variant = LuxeButtonVariant.primary,
    this.expanded = false,
    this.icon,
  });

  final String label;
  final VoidCallback? onPressed;
  final LuxeButtonVariant variant;
  final bool expanded;
  final Widget? icon;

  @override
  Widget build(BuildContext context) {
    final child = Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (icon != null) ...[icon!, const SizedBox(width: 8)],
        Flexible(child: Text(label, textAlign: TextAlign.center)),
      ],
    );

    switch (variant) {
      case LuxeButtonVariant.primary:
        return _wrap(
          FilledButton(
            onPressed: onPressed,
            child: child,
          ),
        );
      case LuxeButtonVariant.secondary:
        return _wrap(
          FilledButton(
            onPressed: onPressed,
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.bgSecondary,
              foregroundColor: AppColors.textPrimary,
            ),
            child: child,
          ),
        );
      case LuxeButtonVariant.outline:
        return _wrap(
          OutlinedButton(
            onPressed: onPressed,
            child: child,
          ),
        );
    }
  }

  Widget _wrap(Widget button) {
    if (!expanded) return button;
    return SizedBox(width: double.infinity, child: button);
  }
}
