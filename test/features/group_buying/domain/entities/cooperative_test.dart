import 'package:flutter_test/flutter_test.dart';
import 'package:transfarmation/features/group_buying/domain/entities/cooperative.dart';

void main() {
  group('GroupOrder entity', () {
    test('calculates savings', () {
      final order = GroupOrder(
        id: 'go1',
        productName: 'Compound D',
        supplier: 'ZFC Ltd',
        unitPrice: 38,
        bulkPrice: 30,
        minimumQuantity: 200,
        currentQuantity: 156,
        unit: 'bags (50kg)',
        deadline: DateTime(2025, 9, 15),
        status: 'open',
      );

      expect(order.savings, (38 - 30) * 156);
      expect(order.discountPercent, closeTo(21.05, 0.1));
    });

    test('calculates progress', () {
      final order = GroupOrder(
        id: 'go1',
        productName: 'Seed',
        supplier: 'SeedCo',
        unitPrice: 25,
        bulkPrice: 20,
        minimumQuantity: 100,
        currentQuantity: 75,
        unit: 'bags',
        deadline: DateTime(2025, 9, 1),
        status: 'open',
      );

      expect(order.progress, 0.75);
    });

    test('progress is 0 when minimumQuantity is 0', () {
      final order = GroupOrder(
        id: 'go1',
        productName: 'Test',
        supplier: 'Test',
        unitPrice: 10,
        bulkPrice: 8,
        minimumQuantity: 0,
        currentQuantity: 50,
        unit: 'kg',
        deadline: DateTime(2025, 9, 1),
        status: 'open',
      );

      expect(order.progress, 0);
    });
  });

  group('Cooperative entity', () {
    test('creates cooperative with active orders', () {
      final coop = Cooperative(
        id: '1',
        name: 'Test Coop',
        description: 'Test cooperative',
        region: 'Mashonaland',
        memberCount: 45,
        category: 'mixed',
        activeOrders: [
          GroupOrder(
            id: 'go1',
            productName: 'Feed',
            supplier: 'Supplier',
            unitPrice: 30,
            bulkPrice: 25,
            minimumQuantity: 100,
            currentQuantity: 80,
            unit: 'bags',
            deadline: DateTime(2025, 10, 1),
            status: 'open',
          ),
        ],
      );

      expect(coop.activeOrders.length, 1);
      expect(coop.name, 'Test Coop');
    });
  });
}
