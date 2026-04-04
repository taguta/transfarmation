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
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'farmerId': farmerId,
      'name': name,
      'province': province,
      'sizeHectares': sizeHectares,
      'farmingMethod': farmingMethod.name,
      'crops': crops.map((e) => e.toJson()).toList(),
      'livestock': livestock.map((e) => e.toJson()).toList(),
    };
  }

  factory Farm.fromJson(Map<String, dynamic> json) {
    return Farm(
      id: json['id'],
      farmerId: json['farmerId'],
      name: json['name'],
      province: json['province'],
      sizeHectares: json['sizeHectares'],
      farmingMethod: FarmingMethod.values.firstWhere((e) => e.name == json['farmingMethod'], orElse: () => FarmingMethod.rainfed),
      crops: (json['crops'] as List).map((e) => CropRecord.fromJson(e)).toList(),
      livestock: (json['livestock'] as List).map((e) => LivestockRecord.fromJson(e)).toList(),
    );
  }
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

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'cropName': cropName,
      'areHectares': areHectares,
      'status': status.name,
      'plantedDate': plantedDate.toIso8601String(),
      'expectedHarvest': expectedHarvest?.toIso8601String(),
      'expectedYield': expectedYield,
      'actualYield': actualYield,
      'notes': notes,
    };
  }

  factory CropRecord.fromJson(Map<String, dynamic> json) {
    return CropRecord(
      id: json['id'],
      cropName: json['cropName'],
      areHectares: json['areHectares'],
      status: CropStatus.values.firstWhere((e) => e.name == json['status'], orElse: () => CropStatus.planted),
      plantedDate: DateTime.parse(json['plantedDate']),
      expectedHarvest: json['expectedHarvest'] != null ? DateTime.parse(json['expectedHarvest']) : null,
      expectedYield: json['expectedYield'],
      actualYield: json['actualYield'],
      notes: json['notes'],
    );
  }
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

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type,
      'count': count,
      'healthStatus': healthStatus,
    };
  }

  factory LivestockRecord.fromJson(Map<String, dynamic> json) {
    return LivestockRecord(
      id: json['id'],
      type: json['type'],
      count: json['count'],
      healthStatus: json['healthStatus'],
    );
  }
}
