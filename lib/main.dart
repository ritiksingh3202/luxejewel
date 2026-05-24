import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import 'application/app_state.dart';
import 'core/auth/auth_controller.dart';
import 'core/theme/app_theme.dart';
import 'router/app_router.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  final appState = AppState();
  final auth = AuthController();
  final router = createAppRouter(auth);
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider<AppState>.value(value: appState),
        ChangeNotifierProvider<AuthController>.value(value: auth),
      ],
      child: LuxeJewelApp(router: router),
    ),
  );
}

class LuxeJewelApp extends StatelessWidget {
  const LuxeJewelApp({super.key, required this.router});

  final GoRouter router;

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'LuxeJewel',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.dark(),
      routerConfig: router,
    );
  }
}
