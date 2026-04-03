import 'package:sqflite/sqflite.dart';
import '../../../domain/entities/farm.dart';

class FarmLocalDataSource {
  final Database db;
  FarmLocalDataSource(this.db);

  Future<void> saveFarm(Farm farm) async {
    await db.insert('farms', {
      'id': farm.id,
      'name': farm.name,
      'farmerId': farm.farmerId,
      'totalHectares': farm.totalHectares,
      'region': farm.region,
      'soilType': farm.soilType,
      'waterSource': farm.waterSource,
      'latitude': farm.latitude,
      'longitude': farm.longitude,
      'address': farm.address,
      'isSynced': 0,
      'updatedAt': DateTime.now().toIso8601String(),
    }, conflictAlgorithm: ConflictAlgorithm.replace);

    for (final field in farm.fields) {
      await saveField(farm.id, field);
    }
    for (final record in farm.livestockRecords) {
      await saveLivestock(farm.id, record);
    }
  }

  Future<void> saveField(String farmId, FarmField field) async {
    await db.insert('farm_fields', {
      'id': field.id,
      'farmId': farmId,
      'name': field.name,
      'hectares': field.hectares,
      'currentCrop': field.currentCrop,
      'season': field.season,
      'status': field.status,
      'yieldTonnes': field.yieldTonnes,
      'isSynced': 0,
    }, conflictAlgorithm: ConflictAlgorithm.replace);

    for (final expense in field.expenses) {
      await saveExpense(field.id, expense);
    }
  }

  Future<void> saveExpense(String fieldId, FieldExpense expense) async {
    await db.insert('field_expenses', {
      'id': expense.id,
      'fieldId': fieldId,
      'category': expense.category,
      'description': expense.description,
      'amount': expense.amount,
      'date': expense.date.toIso8601String(),
      'isSynced': 0,
    }, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<void> saveLivestock(String farmId, LivestockRecord record) async {
    await db.insert('livestock_records', {
      'id': record.id,
      'farmId': farmId,
      'type': record.type,
      'tagNumber': record.tagNumber,
      'name': record.name,
      'breed': record.breed,
      'sex': record.sex,
      'dateOfBirth': record.dateOfBirth?.toIso8601String(),
      'weight': record.weight,
      'status': record.status,
      'isSynced': 0,
    }, conflictAlgorithm: ConflictAlgorithm.replace);

    for (final event in record.vetEvents) {
      await saveVetEvent(record.id, event);
    }
  }

  Future<void> saveVetEvent(String livestockId, VetEvent event) async {
    await db.insert('vet_events', {
      'id': event.id,
      'livestockId': livestockId,
      'type': event.type,
      'description': event.description,
      'date': event.date.toIso8601String(),
      'administeredBy': event.administeredBy,
      'isSynced': 0,
    }, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<List<Farm>> getFarms(String farmerId) async {
    final farmRows = await db.query('farms', where: 'farmerId = ?', whereArgs: [farmerId]);
    final farms = <Farm>[];

    for (final row in farmRows) {
      final farmId = row['id'] as String;

      final fieldRows = await db.query('farm_fields', where: 'farmId = ?', whereArgs: [farmId]);
      final fields = <FarmField>[];
      for (final fr in fieldRows) {
        final fieldId = fr['id'] as String;
        final expenseRows = await db.query('field_expenses', where: 'fieldId = ?', whereArgs: [fieldId]);
        fields.add(FarmField(
          id: fieldId,
          name: fr['name'] as String,
          hectares: (fr['hectares'] as num?)?.toDouble() ?? 0,
          currentCrop: fr['currentCrop'] as String? ?? '',
          season: fr['season'] as String? ?? '',
          status: fr['status'] as String? ?? 'fallow',
          yieldTonnes: (fr['yieldTonnes'] as num?)?.toDouble(),
          expenses: expenseRows.map((e) => FieldExpense(
            id: e['id'] as String,
            category: e['category'] as String,
            description: e['description'] as String? ?? '',
            amount: (e['amount'] as num).toDouble(),
            date: DateTime.parse(e['date'] as String),
          )).toList(),
        ));
      }

      final livestockRows = await db.query('livestock_records', where: 'farmId = ?', whereArgs: [farmId]);
      final livestock = <LivestockRecord>[];
      for (final lr in livestockRows) {
        final lrId = lr['id'] as String;
        final vetRows = await db.query('vet_events', where: 'livestockId = ?', whereArgs: [lrId]);
        livestock.add(LivestockRecord(
          id: lrId,
          type: lr['type'] as String,
          tagNumber: lr['tagNumber'] as String?,
          name: lr['name'] as String?,
          breed: lr['breed'] as String? ?? '',
          sex: lr['sex'] as String? ?? '',
          dateOfBirth: lr['dateOfBirth'] != null ? DateTime.parse(lr['dateOfBirth'] as String) : null,
          weight: (lr['weight'] as num?)?.toDouble(),
          status: lr['status'] as String? ?? 'active',
          vetEvents: vetRows.map((v) => VetEvent(
            id: v['id'] as String,
            type: v['type'] as String,
            description: v['description'] as String? ?? '',
            date: DateTime.parse(v['date'] as String),
            administeredBy: v['administeredBy'] as String?,
          )).toList(),
        ));
      }

      farms.add(Farm(
        id: farmId,
        name: row['name'] as String,
        farmerId: row['farmerId'] as String,
        totalHectares: (row['totalHectares'] as num?)?.toDouble() ?? 0,
        region: row['region'] as String? ?? '',
        soilType: row['soilType'] as String? ?? '',
        waterSource: row['waterSource'] as String? ?? '',
        latitude: (row['latitude'] as num?)?.toDouble(),
        longitude: (row['longitude'] as num?)?.toDouble(),
        address: row['address'] as String? ?? '',
        fields: fields,
        livestockRecords: livestock,
      ));
    }
    return farms;
  }

  Future<void> deleteFarm(String farmId) async {
    await db.delete('farms', where: 'id = ?', whereArgs: [farmId]);
  }
}
