import 'package:flutter/material.dart';

import '../shared/widgets/luxe_bottom_nav.dart';

/// Main app chrome: content + bottom navigation (React `Layout` + `BottomNav`).
class LuxeShell extends StatelessWidget {
  const LuxeShell({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: child,
      bottomNavigationBar: const LuxeBottomNav(),
    );
  }
}
