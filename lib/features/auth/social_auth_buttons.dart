import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/auth/auth_controller.dart';
import '../../core/config/env.dart';
import '../../core/theme/app_colors.dart';
import '../../data/repositories/repositories.dart';
import '../../shared/feedback.dart';

/// Shown only when the provider is enabled in Supabase and flagged via --dart-define.
class SocialAuthButtons extends StatelessWidget {
  const SocialAuthButtons({super.key, required this.caption});

  final String caption;

  @override
  Widget build(BuildContext context) {
    if (!Env.googleAuthEnabled && !Env.appleAuthEnabled) return const SizedBox.shrink();
    void signIn(SocialProvider p) =>
        runWithFeedback(context, () => context.read<AuthController>().signInWithProvider(p));
    return Column(
      children: [
        const SizedBox(height: 28),
        Row(
          children: [
            const Expanded(child: Divider(color: AppColors.divider)),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Text(caption, style: Theme.of(context).textTheme.bodySmall),
            ),
            const Expanded(child: Divider(color: AppColors.divider)),
          ],
        ),
        const SizedBox(height: 20),
        Row(
          children: [
            if (Env.googleAuthEnabled)
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => signIn(SocialProvider.google),
                  icon: const Icon(Icons.g_mobiledata_rounded, size: 28),
                  label: const Text('Google'),
                ),
              ),
            if (Env.googleAuthEnabled && Env.appleAuthEnabled) const SizedBox(width: 12),
            if (Env.appleAuthEnabled)
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => signIn(SocialProvider.apple),
                  icon: const Icon(Icons.apple_rounded, size: 22),
                  label: const Text('Apple'),
                ),
              ),
          ],
        ),
      ],
    );
  }
}
