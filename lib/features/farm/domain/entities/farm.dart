enum FarmingMethod { rainfed, irrigated, mixed }

enum CropStatus { planted, growing, harvesting, harvested, fallow }

class Farm {
  final String id;
  final String farmerId;
  final String name;
  final String province;
  final double sizeHectares;
  final FarmingMethod farmingMethod;
  final List<CropRecord> crops;
  final List<LivestockRecord> livestock;

  const Farm({
    required this.id,
    required this.farmerId,
    required this.name,
    required this.province,
    required this.sizeHectares,
    required this.farmingMethod,
    this.crops = const [],
    this.livestock = const [],
  });

  double get totalYield =>
      crops.fold(0.0, (sum, c) => sum + (c.actualYield ?? 0));

  int get activeCrops =>
      crops.where((c) => c.status != CropStatus.harvested && c.status != CropStatus.fallow).length;
}

class CropRecord {
  final String id;
  final String cropName;
  final double areHectares;
  final CropStatus status;
  final DateTime plantedDate;
  final DateTime? expectedHarvest;
  final double? expectedYield; // tons
  final double? actualYield;   // tons
  final String? notes;

  const CropRecord({
    required this.id,
    required this.cropName,
    required this.areHectares,
    required this.status,
    required this.plantedDate,
    this.expectedHarvest,
    this.expectedYield,
    this.actualYield,
    this.notes,
  });

  double get yieldPerHectare =>
      (actualYield != null && areHectares > 0) ? actualYield! / areHectares : 0;
}

class LivestockRecord {
  final String id;
  final String type; // Cattle, Goats, Poultry, etc.
  final int count;
  final String? healthStatus;

  const LivestockRecord({
    required this.id,
    required this.type,
    required this.count,
    this.healthStatus,
  });
}
