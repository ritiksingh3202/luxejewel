import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'package:luxe_jewel/application/app_state.dart';
import 'package:luxe_jewel/core/auth/auth_controller.dart';
import 'package:luxe_jewel/main.dart';
import 'package:luxe_jewel/router/app_router.dart';

void main() {
  testWidgets('app starts and shows brand', (WidgetTester tester) async {
    final appState = AppState();
    final auth = AuthController();
    final router = createAppRouter(auth);
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider<AppState>.value(value: appState),
          ChangeNotifierProvider<AuthController>.value(value: auth),
        ],
        child: LuxeJewelApp(router: router),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(seconds: 3));
    expect(find.textContaining('LuxeJewel'), findsWidgets);
  });
}
