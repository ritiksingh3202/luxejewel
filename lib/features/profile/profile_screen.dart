import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../application/app_state.dart';
import '../../core/auth/auth_controller.dart';
import '../../core/constants/app_assets.dart';
import '../../core/theme/app_colors.dart';
import '../../shared/feedback.dart';
import '../../shared/widgets/luxe_image.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppState>();
    final auth = context.watch<AuthController>();
    final user = auth.session;
    final profile = app.profile;
    final name = (profile?.fullName.isNotEmpty ?? false) ? profile!.fullName : (user?.displayName ?? 'Guest');
    final email = user?.email ?? 'Sign in to sync your account';
    final phone = profile?.phone ?? user?.phone ?? '';
    final avatar = profile?.avatarUrl;

    return Scaffold(
      backgroundColor: AppColors.bgPrimary,
      body: ListView(
        padding: const EdgeInsets.fromLTRB(24, 36, 24, 110),
        children: [
          Text('Profile', style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 22),
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: AppColors.bgSecondary,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: AppColors.divider),
            ),
            child: Row(
              children: [
                ClipOval(
                  child: SizedBox(
                    width: 78,
                    height: 78,
                    child: LuxeImage(
                      source: (avatar == null || avatar.isEmpty) ? AppAssets.avatarDefault : avatar,
                      fit: BoxFit.cover,
                      semanticLabel: 'Profile photo',
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(name, style: Theme.of(context).textTheme.titleLarge),
                      const SizedBox(height: 4),
                      Text(email, style: Theme.of(context).textTheme.bodySmall),
                      if (phone.isNotEmpty)
                        Text(phone, style: Theme.of(context).textTheme.bodySmall),
                    ],
                  ),
                ),
                IconButton(
                  tooltip: 'Edit profile',
                  onPressed: () => context.push('/profile/edit'),
                  icon: const Icon(Icons.edit_outlined, color: AppColors.gold),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Container(
            decoration: BoxDecoration(
              color: AppColors.bgSecondary,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: AppColors.divider),
            ),
            child: Column(
              children: [
                _Tile(
                  icon: Icons.inventory_2_outlined,
                  title: 'My Orders',
                  trailing: '${app.orders.length} orders',
                  onTap: () => context.push('/orders'),
                  showDivider: true,
                ),
                _Tile(
                  icon: Icons.favorite_border_rounded,
                  title: 'Wishlist',
                  trailing: '${app.wishlist.length} items',
                  onTap: () => context.go('/wishlist'),
                  showDivider: true,
                ),
                _Tile(
                  icon: Icons.location_on_outlined,
                  title: 'Shipping Addresses',
                  trailing: '${app.addresses.length}',
                  onTap: () => context.push('/addresses'),
                  showDivider: true,
                ),
                _Tile(
                  icon: Icons.settings_outlined,
                  title: 'Settings',
                  onTap: () => context.push('/settings'),
                  showDivider: true,
                ),
                _Tile(
                  icon: Icons.help_outline_rounded,
                  title: 'Help & Support',
                  onTap: () => context.push('/help'),
                  showDivider: false,
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Material(
            color: AppColors.bgSecondary,
            borderRadius: BorderRadius.circular(18),
            child: InkWell(
              borderRadius: BorderRadius.circular(18),
              onTap: () async {
                final ok = await runWithFeedback(context, auth.signOut);
                if (ok && context.mounted) context.go('/login');
              },
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    const Icon(Icons.logout_rounded, color: AppColors.destructive),
                    const SizedBox(width: 14),
                    Text(
                      'Logout',
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(color: AppColors.destructive),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Tile extends StatelessWidget {
  const _Tile({
    required this.icon,
    required this.title,
    required this.onTap,
    required this.showDivider,
    this.trailing,
  });

  final IconData icon;
  final String title;
  final String? trailing;
  final VoidCallback onTap;
  final bool showDivider;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
            child: Row(
              children: [
                Icon(icon, color: AppColors.gold, size: 22),
                const SizedBox(width: 12),
                Expanded(child: Text(title, style: Theme.of(context).textTheme.titleSmall)),
                if (trailing != null)
                  Text(trailing!, style: Theme.of(context).textTheme.bodySmall),
                const SizedBox(width: 6),
                Icon(Icons.chevron_right_rounded, color: AppColors.textSecondary.withOpacity(0.8)),
              ],
            ),
          ),
        ),
        if (showDivider) const Divider(height: 1, color: AppColors.divider),
      ],
    );
  }
}
