import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:transfarmation/features/farm_records/presentation/providers/farm_record_providers.dart';
import 'package:transfarmation/features/farm_records/domain/entities/farm.dart';

void main() {
  group('FarmNotifier', () {
    late ProviderContainer container;

    setUp(() {
      container = ProviderContainer();
    });

    tearDown(() {
      container.dispose();
    });

    test('initial state has mock farm data', () {
      final farms = container.read(farmListProvider);
      expect(farms.isNotEmpty, true);
      expect(farms.first.name, 'Baba Tonde\'s Homestead');
    });

    test('addFarm adds a new farm', () {
      final notifier = container.read(farmListProvider.notifier);
      final newFarm = Farm(
        id: 'new-farm',
        name: 'New Farm',
        farmerId: 'farmer-002',
        totalHectares: 5,
        region: 'Region III',
        soilType: 'Sandy',
        waterSource: 'Rainfed',
        address: 'Masvingo',
      );

      notifier.addFarm(newFarm);
      final farms = container.read(farmListProvider);
      expect(farms.length, 2);
      expect(farms.last.name, 'New Farm');
    });

    test('addFieldToFarm adds field to correct farm', () {
      final notifier = container.read(farmListProvider.notifier);
      final farms = container.read(farmListProvider);
      final farmId = farms.first.id;
      final initialFieldCount = farms.first.fields.length;

      notifier.addFieldToFarm(farmId, FarmField(
        id: 'new-field',
        name: 'Wheat Plot',
        hectares: 2,
        currentCrop: 'Wheat',
        season: '2025/26',
        status: 'planted',
      ));

      final updated = container.read(farmListProvider);
      expect(updated.first.fields.length, initialFieldCount + 1);
    });

    test('addLivestockToFarm adds record to correct farm', () {
      final notifier = container.read(farmListProvider.notifier);
      final farms = container.read(farmListProvider);
      final farmId = farms.first.id;
      final initialCount = farms.first.livestockRecords.length;

      notifier.addLivestockToFarm(farmId, LivestockRecord(
        id: 'new-livestock',
        type: 'pig',
        breed: 'Large White',
        sex: 'Male',
        status: 'active',
      ));

      final updated = container.read(farmListProvider);
      expect(updated.first.livestockRecords.length, initialCount + 1);
    });
  });

  group('farmSummaryProvider', () {
    late ProviderContainer container;

    setUp(() {
      container = ProviderContainer();
    });

    tearDown(() {
      container.dispose();
    });

    test('computes farm summary from mock data', () {
      final summary = container.read(farmSummaryProvider);
      expect(summary['totalHa'], 8.5);
      expect(summary['fieldCount'], 4);
      expect(summary['totalLivestock'], greaterThan(0));
    });
  });
}
