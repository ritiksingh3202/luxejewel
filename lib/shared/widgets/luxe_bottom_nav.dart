import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../application/app_state.dart';
import '../../core/theme/app_colors.dart';

class LuxeBottomNav extends StatelessWidget {
  const LuxeBottomNav({super.key});

  static const _items = <_NavItem>[
    _NavItem(path: '/home', label: 'Home', icon: Icons.home_outlined, selectedIcon: Icons.home_rounded),
    _NavItem(path: '/wishlist', label: 'Wishlist', icon: Icons.favorite_border, selectedIcon: Icons.favorite_rounded),
    _NavItem(path: '/cart', label: 'Cart', icon: Icons.shopping_cart_outlined, selectedIcon: Icons.shopping_cart_rounded),
    _NavItem(path: '/profile', label: 'Profile', icon: Icons.person_outline, selectedIcon: Icons.person_rounded),
  ];

  @override
  Widget build(BuildContext context) {
    final location = GoRouterState.of(context).uri.path;
    final app = context.watch<AppState>();

    return DecoratedBox(
      decoration: const BoxDecoration(
        color: AppColors.bgSecondary,
        border: Border(top: BorderSide(color: AppColors.divider)),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
          child: Row(
            children: [
              for (final item in _items)
                Expanded(
                  child: _NavTile(
                    item: item,
                    selected: location == item.path,
                    badge: item.path == '/wishlist'
                        ? app.wishlist.length
                        : item.path == '/cart'
                            ? app.cartCount
                            : 0,
                    onTap: () {
                      if (location != item.path) {
                        HapticFeedback.selectionClick();
                      }
                      context.go(item.path);
                    },
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavItem {
  const _NavItem({
    required this.path,
    required this.label,
    required this.icon,
    required this.selectedIcon,
  });

  final String path;
  final String label;
  final IconData icon;
  final IconData selectedIcon;
}

class _NavTile extends StatelessWidget {
  const _NavTile({
    required this.item,
    required this.selected,
    required this.badge,
    required this.onTap,
  });

  final _NavItem item;
  final bool selected;
  final int badge;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = selected ? AppColors.gold : AppColors.textSecondary;
    final icon = selected ? item.selectedIcon : item.icon;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                Icon(icon, size: 24, color: color),
                if (badge > 0)
                  Positioned(
                    right: -6,
                    top: -6,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 5),
                      constraints: const BoxConstraints(minWidth: 18, minHeight: 18),
                      decoration: BoxDecoration(
                        color: AppColors.gold,
                        borderRadius: BorderRadius.circular(999),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        badge > 99 ? '99+' : '$badge',
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                              color: AppColors.bgPrimary,
                              fontWeight: FontWeight.w700,
                              fontSize: 10,
                            ),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              item.label,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: color,
                    fontWeight: FontWeight.w500,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}
