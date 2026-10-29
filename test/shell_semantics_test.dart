import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import 'package:transfarmation/core/alerts/proactive_alerts.dart';
import 'package:transfarmation/features/notifications/presentation/providers/notification_providers.dart';
import 'package:transfarmation/features/shell/presentation/screens/app_shell.dart';
import 'package:transfarmation/features/sync_ui/presentation/providers/sync_providers.dart';

Future<void> _pumpShell(WidgetTester tester, Size size) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);

  final router = GoRouter(
    initialLocation: '/home',
    routes: [
      ShellRoute(
        builder: (context, state, child) => AppShell(child: child),
        routes: [
          GoRoute(
            path: '/home',
            builder: (_, __) => const Scaffold(body: Text('page content')),
          ),
        ],
      ),
    ],
  );

  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        proactiveAlertsProvider.overrideWith((ref) async => 0),
        unreadCountProvider.overrideWithValue(0),
        syncItemsProvider.overrideWith((ref) async => []),
      ],
      child: MaterialApp.router(routerConfig: router),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  for (final entry in {
    'desktop': const Size(1440, 900),
    'phone': const Size(390, 844),
  }.entries) {
    testWidgets('shell navigation is exposed to semantics (${entry.key})',
        (tester) async {
      final handle = tester.ensureSemantics();
      await _pumpShell(tester, entry.value);

      // The Navigator's modal barrier must not hide the shell chrome from
      // screen readers, and each item must be announced once, not twice.
      expect(find.bySemanticsLabel('Markets'), findsOneWidget);
      expect(find.bySemanticsLabel('Advisory'), findsOneWidget);
      expect(find.byTooltip('Notifications'), findsOneWidget);
      expect(find.bySemanticsLabel('page content'), findsOneWidget);
      handle.dispose();
    });
  }
}
