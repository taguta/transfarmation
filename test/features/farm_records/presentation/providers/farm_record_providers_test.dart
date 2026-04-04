import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:transfarmation/features/farm_records/presentation/providers/farm_record_providers.dart';
import 'package:transfarmation/features/farm_records/domain/entities/farm.dart';
import 'package:transfarmation/core/providers/data_providers.dart';
import 'package:transfarmation/features/farm_records/infrastructure/repositories/farm_repository_impl.dart';

class FakeFarmRepository implements FarmRepositoryImpl {
  final List<Farm> farms = [
    Farm(
      id: 'farm-001',
      name: 'Baba Tonde\'s Homestead',
      farmerId: 'farmer-001',
      totalHectares: 8.5,
      region: 'Region II',
      soilType: 'Red Soil',
      waterSource: 'Borehole',
      address: 'Plot 12, Domboshava',
      fields: [
        const FarmField(id: 'f1', name: 'Maize Plot', hectares: 2.0, currentCrop: 'Maize', season: '2025/26', status: 'planted'),
        const FarmField(id: 'f2', name: 'Tomato Plot', hectares: 1.0, currentCrop: 'Tomatoes', season: '2025/26', status: 'planted'),
        const FarmField(id: 'f3', name: 'Cabbage Plot', hectares: 1.5, currentCrop: 'Cabbage', season: '2025/26', status: 'harvested'),
        const FarmField(id: 'f4', name: 'Fallow Plot', hectares: 4.0, currentCrop: 'None', season: '2025/26', status: 'fallow'),
      ],
      livestockRecords: [
        const LivestockRecord(id: 'l1', type: 'cattle', breed: 'Mashona', sex: 'Female', status: 'active'),
        const LivestockRecord(id: 'l2', type: 'poultry', breed: 'Broiler', sex: 'Unknown', status: 'active'),
        const LivestockRecord(id: 'l3', type: 'goat', breed: 'Boer', sex: 'Male', status: 'active'),
      ]
    )
  ];

  @override
  get db => throw UnimplementedError();

  @override
  get local => throw UnimplementedError();

  @override
  get remote => throw UnimplementedError();

  @override
  Future<List<Farm>> getFarms(String farmerId) async {
    return farms;
  }

  @override
  Future<void> deleteFarm(String farmId) async {}

  @override
  Future<void> saveFarm(Farm farm) async {}

  @override
  Future<void> saveField(String farmId, FarmField field) async {}

  @override
  Future<void> saveLivestock(String farmId, LivestockRecord record) async {}
}

void main() {
  group('farmListProvider', () {
    test('loads farm data from repository', () async {
      final container = ProviderContainer(
        overrides: [
          farmRepositoryImplProvider.overrideWithValue(FakeFarmRepository()),
        ],
      );
      addTearDown(container.dispose);

      final farmsAsync = container.read(farmListProvider);
      expect(farmsAsync, isA<AsyncLoading<List<Farm>>>());

      final farms = await container.read(farmListProvider.future);
      expect(farms.isNotEmpty, true);
      expect(farms.first.name, 'Baba Tonde\'s Homestead');
    });
  });

  group('farmSummaryProvider', () {
    test('computes farm summary from data', () async {
      final container = ProviderContainer(
        overrides: [
          farmRepositoryImplProvider.overrideWithValue(FakeFarmRepository()),
        ],
      );
      addTearDown(container.dispose);

      // Wait for farmListProvider to resolve
      await container.read(farmListProvider.future);

      final summary = container.read(farmSummaryProvider);
      expect(summary['totalHa'], 8.5);
      expect(summary['fieldCount'], 4);
      expect(summary['totalLivestock'], 3);
      expect(summary['cattleCount'], 1);
      expect(summary['poultryCount'], 1);
      expect(summary['goatCount'], 1);
      expect(summary['plantedHa'], 4.5); // 2.0 + 1.0 + 1.5
      expect(summary['fallowHa'], 4.0);
    });
  });
}
