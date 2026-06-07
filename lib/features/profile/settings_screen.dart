import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../application/app_state.dart';
import '../../core/auth/auth_controller.dart';
import '../../core/theme/app_colors.dart';
import '../../router/nav.dart';
import '../../shared/feedback.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthController>();
    final payment = context.watch<AppState>().paymentMethod;
    final theme = Theme.of(context).textTheme;

    Widget tile(IconData icon, String title, {String? subtitle, VoidCallback? onTap}) => ListTile(
          leading: Icon(icon, color: AppColors.gold),
          title: Text(title, style: theme.titleSmall),
          subtitle: subtitle == null ? null : Text(subtitle, style: theme.bodySmall),
          trailing: onTap == null ? null : const Icon(Icons.chevron_right_rounded, color: AppColors.textSecondary),
          onTap: onTap,
        );

    return Scaffold(
      backgroundColor: AppColors.bgPrimary,
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => context.popOrGo('/profile'),
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
        ),
        title: const Text('Settings'),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 720),
          child: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            children: [
              tile(Icons.email_outlined, 'Email', subtitle: auth.session?.email),
              tile(Icons.person_outline, 'Edit Profile', onTap: () => context.push('/profile/edit')),
              tile(Icons.location_on_outlined, 'Shipping Addresses', onTap: () => context.push('/addresses')),
              tile(Icons.lock_outline, 'Change Password', onTap: () => context.push('/reset-password')),
              tile(
                Icons.science_outlined,
                'Payments',
                subtitle: payment.isDemo ? 'Demo mode — no real charges are made' : payment.label,
              ),
              tile(Icons.info_outline, 'About', subtitle: 'LuxeJewel v1.0.0'),
              const Divider(color: AppColors.divider),
              ListTile(
                leading: const Icon(Icons.logout_rounded, color: AppColors.destructive),
                title: Text('Log Out', style: theme.titleSmall?.copyWith(color: AppColors.destructive)),
                onTap: () async {
                  final ok = await runWithFeedback(context, auth.signOut);
                  if (ok && context.mounted) context.go('/login');
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
