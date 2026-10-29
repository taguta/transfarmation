import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'package:transfarmation/core/utils/app_prefs.dart';
import 'package:transfarmation/features/onboarding/presentation/screens/onboarding_screen.dart';

/// The full app needs Firebase and a real database, so this exercises the
/// first thing a new user sees: onboarding, role choice and the hand-off to login.
void main() {
  late Directory dir;

  setUp(() {
    dir = Directory.systemTemp.createTempSync('hive_test');
    Hive.init(dir.path);
  });

  tearDown(() async {
    await Hive.close();
    dir.deleteSync(recursive: true);
  });

  Widget app() => MaterialApp.router(
    routerConfig: GoRouter(
      routes: [
        GoRoute(path: '/', builder: (_, _) => const OnboardingScreen()),
        GoRoute(path: '/login', builder: (_, _) => const Scaffold(body: Text('LOGIN PAGE'))),
      ],
    ),
  );

  testWidgets('onboarding walks through the value pages, saves the role and opens login',
      (tester) async {
    await tester.pumpWidget(app());
    await tester.pumpAndSettle();
    expect(find.text('A Plan Your Bank Accepts'), findsOneWidget);

    for (var i = 0; i < 4; i++) {
      await tester.tap(find.text('Continue'));
      await tester.pumpAndSettle();
    }
    expect(find.text('How will you use Transfarmation?'), findsOneWidget);

    await tester.tap(find.text('Lender'));
    await tester.pumpAndSettle();
    await tester.runAsync(() async {
      await tester.tap(find.text('Get Started'));
      await Future<void>.delayed(const Duration(milliseconds: 300));
    });
    await tester.pumpAndSettle();

    expect(find.text('LOGIN PAGE'), findsOneWidget);
    final saved = await tester.runAsync(() async => (await AppPrefs.role, await AppPrefs.onboardingDone));
    expect(saved, ('Lender', true));
  });

  testWidgets('skip jumps straight to the role choice', (tester) async {
    await tester.pumpWidget(app());
    await tester.pumpAndSettle();
    await tester.tap(find.text('Skip'));
    await tester.pumpAndSettle();
    expect(find.text('How will you use Transfarmation?'), findsOneWidget);
  });
}
