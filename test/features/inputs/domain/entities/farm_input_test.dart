import 'package:flutter_test/flutter_test.dart';
import 'package:transfarmation/features/inputs/domain/entities/farm_input.dart';

void main() {
  group('FarmInput entity', () {
    test('calculates bulk discount', () {
      final input = FarmInput(
        id: '1',
        name: 'Compound D',
        category: 'fertilizer',
        supplier: 'ZFC Ltd',
        description: 'NPK fertilizer',
        price: 38,
        unit: 'bag',
        bulkPrice: 30,
        bulkMinQuantity: 50,
      );

      expect(input.bulkDiscount, closeTo(21.05, 0.1));
    });

    test('bulk discount is 0 when no bulk price', () {
      final input = FarmInput(
        id: '2',
        name: 'Seed',
        category: 'seeds',
        supplier: 'SeedCo',
        description: 'Maize seed',
        price: 25,
        unit: 'bag',
      );

      expect(input.bulkDiscount, 0);
    });
  });

  group('SubsidyApplication entity', () {
    test('creates application', () {
      final app = SubsidyApplication(
        id: 'sa1',
        programId: 'sp1',
        programName: 'Pfumvudza/Intwasa',
        status: 'applied',
        appliedDate: DateTime(2026, 3, 1),
      );

      expect(app.status, 'applied');
      expect(app.amountApproved, null);
    });
  });
}
