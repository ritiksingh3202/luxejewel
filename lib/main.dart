import 'package:flutter/material.dart';
import 'package:flutter_web_plugins/url_strategy.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'application/app_state.dart';
import 'core/auth/auth_controller.dart';
import 'core/config/env.dart';
import 'core/theme/app_colors.dart';
import 'core/theme/app_theme.dart';
import 'data/repositories/repositories.dart';
import 'data/supabase/supabase_backend.dart';
import 'router/app_router.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  usePathUrlStrategy();
  if (!Env.isConfigured) {
    runApp(const _ConfigMissingApp());
    return;
  }
  await Supabase.initialize(url: Env.supabaseUrl, publishableKey: Env.supabaseKey);
  runApp(LuxeJewelRoot(backend: createSupabaseBackend(Supabase.instance.client)));
}

/// Wires controllers to a [Backend]; tests pass an in-memory backend.
class LuxeJewelRoot extends StatefulWidget {
  const LuxeJewelRoot({super.key, required this.backend});

  final Backend backend;

  @override
  State<LuxeJewelRoot> createState() => _LuxeJewelRootState();
}

class _LuxeJewelRootState extends State<LuxeJewelRoot> {
  late final AuthController _auth = AuthController(widget.backend.auth);
  late final AppState _app = AppState(widget.backend);
  late final GoRouter _router = createAppRouter(_auth);

  @override
  void initState() {
    super.initState();
    _app.loadCatalog();
    _auth.addListener(_syncUser);
    _syncUser();
  }

  void _syncUser() => _app.setUser(_auth.session?.userId);

  @override
  void dispose() {
    _auth.removeListener(_syncUser);
    _auth.dispose();
    _router.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<AppState>.value(value: _app),
        ChangeNotifierProvider<AuthController>.value(value: _auth),
      ],
      child: LuxeJewelApp(router: _router),
    );
  }
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

class _ConfigMissingApp extends StatelessWidget {
  const _ConfigMissingApp();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: AppTheme.dark(),
      home: const Scaffold(
        backgroundColor: AppColors.bgPrimary,
        body: Center(
          child: Padding(
            padding: EdgeInsets.all(24),
            child: Text(
              'Supabase is not configured.\nRun with --dart-define-from-file=env/dev.json '
              '(see README).',
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ),
    );
  }
}
