import 'package:flutter_test/flutter_test.dart';
import 'package:transfarmation/features/farm_records/domain/entities/farm.dart';

void main() {
  group('Farm entity', () {
    test('creates farm with required fields', () {
      final farm = Farm(
        id: 'f1',
        name: 'Test Farm',
        farmerId: 'farmer-001',
        totalHectares: 10,
        region: 'Region II',
        soilType: 'Red clay loam',
        waterSource: 'Borehole',
        address: 'Chihota',
      );

      expect(farm.id, 'f1');
      expect(farm.name, 'Test Farm');
      expect(farm.totalHectares, 10);
      expect(farm.fields, isEmpty);
      expect(farm.livestockRecords, isEmpty);
    });

    test('creates farm with fields and livestock', () {
      final farm = Farm(
        id: 'f1',
        name: 'Test Farm',
        farmerId: 'farmer-001',
        totalHectares: 10,
        region: 'Region II',
        soilType: 'Red clay loam',
        waterSource: 'Borehole',
        address: 'Chihota',
        fields: [
          FarmField(
            id: 'field1',
            name: 'Maize Field',
            hectares: 3,
            currentCrop: 'Maize',
            season: '2024/25',
            status: 'growing',
          ),
        ],
        livestockRecords: [
          LivestockRecord(
            id: 'l1',
            type: 'cattle',
            breed: 'Mashona',
            sex: 'Bull',
            status: 'active',
          ),
        ],
      );

      expect(farm.fields.length, 1);
      expect(farm.livestockRecords.length, 1);
      expect(farm.fields.first.currentCrop, 'Maize');
    });
  });

  group('FarmField entity', () {
    test('calculates totalExpenses', () {
      final field = FarmField(
        id: 'f1',
        name: 'Maize Field',
        hectares: 3,
        currentCrop: 'Maize',
        season: '2024/25',
        status: 'growing',
        expenses: [
          FieldExpense(
            id: 'e1',
            category: 'seed',
            description: 'SC 513',
            amount: 45,
            date: DateTime(2024, 10, 15),
          ),
          FieldExpense(
            id: 'e2',
            category: 'fertilizer',
            description: 'Compound D',
            amount: 120,
            date: DateTime(2024, 10, 15),
          ),
        ],
      );

      expect(field.totalExpenses, 165);
      expect(field.costPerHectare, 55);
    });

    test('costPerHectare returns 0 for zero hectares', () {
      final field = FarmField(
        id: 'f1',
        name: 'Empty',
        hectares: 0,
        currentCrop: '',
        season: '',
        status: 'fallow',
        expenses: [
          FieldExpense(
            id: 'e1',
            category: 'seed',
            description: 'Test',
            amount: 100,
            date: DateTime.now(),
          ),
        ],
      );

      expect(field.costPerHectare, 0);
    });
  });

  group('LivestockRecord entity', () {
    test('creates record with vet events', () {
      final record = LivestockRecord(
        id: 'l1',
        type: 'cattle',
        tagNumber: 'TAG-001',
        name: 'Mhofu',
        breed: 'Mashona',
        sex: 'Bull',
        dateOfBirth: DateTime(2020, 3, 15),
        weight: 450,
        status: 'active',
        vetEvents: [
          VetEvent(
            id: 'v1',
            type: 'vaccination',
            description: 'LSD vaccine',
            date: DateTime(2024, 9, 20),
            administeredBy: 'Dr Moyo',
          ),
        ],
      );

      expect(record.vetEvents.length, 1);
      expect(record.tagNumber, 'TAG-001');
    });
  });
}
