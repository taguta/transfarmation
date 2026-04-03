/// A farm profile with GPS boundary and records.
class Farm {
  final String id;
  final String name;
  final String farmerId;
  final double totalHectares;
  final String region; // agro-ecological region I-V
  final String soilType;
  final String waterSource; // rainfed, borehole, dam, river, irrigation_scheme
  final double? latitude;
  final double? longitude;
  final String address;
  final List<FarmField> fields;
  final List<LivestockRecord> livestockRecords;

  const Farm({
    required this.id,
    required this.name,
    required this.farmerId,
    required this.totalHectares,
    required this.region,
    required this.soilType,
    required this.waterSource,
    this.latitude,
    this.longitude,
    required this.address,
    this.fields = const [],
    this.livestockRecords = const [],
  });
}

/// A farm field/plot with crop rotation history.
class FarmField {
  final String id;
  final String name;
  final double hectares;
  final String currentCrop;
  final String season; // 2025/26, 2026/27
  final String status; // planted, growing, harvested, fallow
  final List<FieldExpense> expenses;
  final double? yieldTonnes;

  const FarmField({
    required this.id,
    required this.name,
    required this.hectares,
    required this.currentCrop,
    required this.season,
    required this.status,
    this.expenses = const [],
    this.yieldTonnes,
  });

  double get totalExpenses => expenses.fold(0, (s, e) => s + e.amount);
  double get costPerHectare => hectares > 0 ? totalExpenses / hectares : 0;
}

/// An expense entry for a field.
class FieldExpense {
  final String id;
  final String category; // seed, fertilizer, chemicals, labour, equipment, transport, other
  final String description;
  final double amount;
  final DateTime date;

  const FieldExpense({
    required this.id,
    required this.category,
    required this.description,
    required this.amount,
    required this.date,
  });
}

/// Individual livestock record.
class LivestockRecord {
  final String id;
  final String type; // cattle, goat, poultry, pig
  final String? tagNumber;
  final String? name;
  final String breed;
  final String sex;
  final DateTime? dateOfBirth;
  final double? weight;
  final String status; // active, sold, deceased
  final List<VetEvent> vetEvents;

  const LivestockRecord({
    required this.id,
    required this.type,
    this.tagNumber,
    this.name,
    required this.breed,
    required this.sex,
    this.dateOfBirth,
    this.weight,
    required this.status,
    this.vetEvents = const [],
  });
}

/// Veterinary event for livestock.
class VetEvent {
  final String id;
  final String type; // vaccination, treatment, deworming, dipping, examination
  final String description;
  final DateTime date;
  final String? administeredBy;

  const VetEvent({
    required this.id,
    required this.type,
    required this.description,
    required this.date,
    this.administeredBy,
  });
}
