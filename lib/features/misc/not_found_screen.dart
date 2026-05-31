import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_colors.dart';
import '../../shared/widgets/luxe_empty_state.dart';

class NotFoundScreen extends StatelessWidget {
  const NotFoundScreen({super.key, required this.location});

  final String location;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgPrimary,
      body: SafeArea(
        child: Center(
          child: LuxeEmptyState(
            icon: Icons.explore_off_outlined,
            title: 'Page not found',
            message: 'We couldn\'t find "$location".',
            actionLabel: 'Go Home',
            onAction: () => context.go('/home'),
          ),
        ),
      ),
    );
  }
}
