import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:luxe_jewel/main.dart';

import 'fakes.dart';

Future<void> _boot(WidgetTester tester, FakeStore store) async {
  tester.view.physicalSize = const Size(1080, 2400);
  tester.view.devicePixelRatio = 2.5;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(LuxeJewelRoot(backend: fakeBackend(store)));
  await tester.pump();
  await tester.pump(const Duration(seconds: 3));
}

GoRouter _router(WidgetTester tester) => GoRouter.of(tester.element(find.byType(Scaffold).first));

void main() {
  testWidgets('app starts and shows brand', (tester) async {
    await _boot(tester, FakeStore());
    expect(find.textContaining('LuxeJewel'), findsWidgets);
  });

  testWidgets('guest opening checkout is redirected to login', (tester) async {
    await _boot(tester, FakeStore());
    _router(tester).go('/checkout');
    await tester.pumpAndSettle();
    expect(find.text('Welcome Back'), findsOneWidget);
  });

  testWidgets('login validates input and shows server errors', (tester) async {
    await _boot(tester, FakeStore());
    _router(tester).go('/login');
    await tester.pumpAndSettle();

    await tester.tap(find.text('Sign In'));
    await tester.pump();
    expect(find.text('Email is required'), findsOneWidget);

    await tester.enterText(find.byType(TextFormField).at(0), 'test@example.com');
    await tester.enterText(find.byType(TextFormField).at(1), 'wrong');
    await tester.tap(find.text('Sign In'));
    await tester.pump();
    await tester.pump();
    expect(find.text('Invalid login credentials'), findsOneWidget);
  });

  testWidgets('successful login lands on home with products', (tester) async {
    await _boot(tester, FakeStore());
    _router(tester).go('/login');
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextFormField).at(0), 'test@example.com');
    await tester.enterText(find.byType(TextFormField).at(1), 'Passw0rd1');
    await tester.tap(find.text('Sign In'));
    await tester.pumpAndSettle();
    expect(find.text('Featured Products'), findsOneWidget);
    expect(find.text('Diamond Solitaire Ring'), findsWidgets);
  });

  testWidgets('unknown route shows not-found page', (tester) async {
    await _boot(tester, FakeStore());
    _router(tester).go('/does-not-exist');
    await tester.pumpAndSettle();
    expect(find.text('Page not found'), findsOneWidget);
  });
}
