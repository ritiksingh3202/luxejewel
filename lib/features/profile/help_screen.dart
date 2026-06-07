import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/theme/app_colors.dart';
import '../../router/nav.dart';

class HelpScreen extends StatelessWidget {
  const HelpScreen({super.key});

  static const supportEmail = 'support@luxejewel.app';

  static const _faqs = [
    ('Is my payment real?', 'No. Checkout currently runs in demo mode: orders are saved, but no money is charged and nothing ships.'),
    ('How do I track my order?', 'Open Profile › My Orders and tap an order to see its status and details.'),
    ('Can I change my shipping address?', 'Manage addresses in Profile › Shipping Addresses. Pick one at checkout.'),
    ('I forgot my password.', 'Use "Forgot Password?" on the sign-in screen to receive a reset link by email.'),
    ('Returns & resizing', 'Every piece includes complimentary resizing and a lifetime warranty. Contact us to arrange it.'),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).textTheme;
    return Scaffold(
      backgroundColor: AppColors.bgPrimary,
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => context.popOrGo('/profile'),
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
        ),
        title: const Text('Help & Support'),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 720),
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
            children: [
              for (final (q, a) in _faqs)
                ExpansionTile(
                  iconColor: AppColors.gold,
                  collapsedIconColor: AppColors.textSecondary,
                  title: Text(q, style: theme.titleSmall),
                  childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                  children: [Align(alignment: Alignment.centerLeft, child: Text(a, style: theme.bodyMedium))],
                ),
              const SizedBox(height: 16),
              ListTile(
                leading: const Icon(Icons.mail_outline, color: AppColors.gold),
                title: Text('Email support', style: theme.titleSmall),
                subtitle: Text(supportEmail, style: theme.bodySmall),
                trailing: const Icon(Icons.copy_rounded, color: AppColors.textSecondary, size: 18),
                onTap: () async {
                  await Clipboard.setData(const ClipboardData(text: supportEmail));
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Support email copied')),
                    );
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
