import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/farm.dart';

class FarmNotifier extends Notifier<Farm> {
  @override
  Farm build() => _mockFarm;

  void addCrop(CropRecord crop) {
    state = Farm(
      id: state.id,
      farmerId: state.farmerId,
      name: state.name,
      province: state.province,
      sizeHectares: state.sizeHectares,
      farmingMethod: state.farmingMethod,
      crops: [...state.crops, crop],
      livestock: state.livestock,
    );
  }

  static final _mockFarm = Farm(
    id: 'farm-001',
    farmerId: 'farmer-001',
    name: 'Moyo Family Farm',
    province: 'Mashonaland East',
    sizeHectares: 12,
    farmingMethod: FarmingMethod.rainfed,
    crops: [
      CropRecord(
        id: 'crop-001',
        cropName: 'Maize',
        areHectares: 5,
        status: CropStatus.growing,
        plantedDate: DateTime(2025, 11, 15),
        expectedHarvest: DateTime(2026, 4, 20),
        expectedYield: 15,
        actualYield: null,
        notes: 'Top-dress fertilizer applied',
      ),
      CropRecord(
        id: 'crop-002',
        cropName: 'Soya Beans',
        areHectares: 4,
        status: CropStatus.growing,
        plantedDate: DateTime(2025, 12, 1),
        expectedHarvest: DateTime(2026, 5, 10),
        expectedYield: 8,
        actualYield: null,
      ),
      CropRecord(
        id: 'crop-003',
        cropName: 'Groundnuts',
        areHectares: 3,
        status: CropStatus.harvested,
        plantedDate: DateTime(2025, 10, 1),
        expectedHarvest: DateTime(2026, 2, 15),
        expectedYield: 4.5,
        actualYield: 4.2,
      ),
    ],
    livestock: [
      LivestockRecord(
        id: 'lv-001',
        type: 'Cattle',
        count: 8,
        healthStatus: 'Healthy',
      ),
      LivestockRecord(
        id: 'lv-002',
        type: 'Goats',
        count: 15,
        healthStatus: 'Healthy',
      ),
      LivestockRecord(
        id: 'lv-003',
        type: 'Poultry',
        count: 45,
        healthStatus: '3 under treatment',
      ),
    ],
  );
}

final farmProvider = NotifierProvider<FarmNotifier, Farm>(FarmNotifier.new);
