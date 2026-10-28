import 'package:flutter_test/flutter_test.dart';
import 'package:transfarmation/core/workspace/workspace.dart';

void main() {
  test('every selectable role has a workspace with actions', () {
    for (final r in ['Farmer', 'Lender', 'Buyer', 'Expert']) {
      expect(workspaces[r], isNotNull, reason: r);
      expect(workspaces[r]!.actions, isNotEmpty);
    }
  });

  test('action routes are absolute and unique within a workspace', () {
    for (final w in workspaces.values) {
      final routes = w.actions.map((a) => a.route).toList();
      expect(routes.every((r) => r.startsWith('/')), isTrue);
      expect(routes.toSet().length, routes.length, reason: w.name);
    }
  });

  test('unknown active role falls back to the farmer workspace', () {
    expect(const WorkspaceState(['Farmer'], 'Nope').current.role, 'Farmer');
  });
}
