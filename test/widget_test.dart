import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'package:transfarmation/main.dart';

void main() {
  setUp(() async {
    final dir = Directory.systemTemp.createTempSync('hive_test');
    Hive.init(dir.path);
  });

  tearDown(() async {
    await Hive.close();
  });

  testWidgets('App smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const ProviderScope(child: TransfarmationApp()));
    await tester.pumpAndSettle(const Duration(seconds: 5));
    expect(find.byType(TransfarmationApp), findsOneWidget);
  });
}
