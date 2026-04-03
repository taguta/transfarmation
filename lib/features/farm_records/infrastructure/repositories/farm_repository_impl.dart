import 'dart:convert';
import 'package:sqflite/sqflite.dart';
import '../../domain/entities/farm.dart';
import '../../domain/repositories/farm_repository.dart';
import '../datasource/local/farm_sqlite.dart';
import '../datasource/remote/farm_firestore.dart';

class FarmRepositoryImpl implements FarmRepository {
  final FarmLocalDataSource local;
  final FarmRemoteDataSource remote;
  final Database db;

  FarmRepositoryImpl(this.local, this.remote, this.db);

  @override
  Future<void> saveFarm(Farm farm) async {
    await local.saveFarm(farm);
    try {
      await remote.sendFarm(farm);
      await db.update('farms', {'isSynced': 1}, where: 'id = ?', whereArgs: [farm.id]);
    } catch (_) {
      await db.insert('sync_queue', {
        'id': farm.id,
        'type': 'farm',
        'payload': jsonEncode({
          'id': farm.id,
          'name': farm.name,
          'farmerId': farm.farmerId,
          'totalHectares': farm.totalHectares,
          'region': farm.region,
        }),
        'retryCount': 0,
      });
    }
  }

  @override
  Future<List<Farm>> getFarms(String farmerId) => local.getFarms(farmerId);

  @override
  Future<void> deleteFarm(String farmId) => local.deleteFarm(farmId);

  @override
  Future<void> saveField(String farmId, FarmField field) async {
    await local.saveField(farmId, field);
    try {
      await remote.sendField(farmId, field);
      await db.update('farm_fields', {'isSynced': 1}, where: 'id = ?', whereArgs: [field.id]);
    } catch (_) {
      await db.insert('sync_queue', {
        'id': field.id,
        'type': 'farm_field',
        'payload': jsonEncode({
          'farmId': farmId,
          'id': field.id,
          'name': field.name,
          'hectares': field.hectares,
          'currentCrop': field.currentCrop,
          'season': field.season,
          'status': field.status,
          'yieldTonnes': field.yieldTonnes,
        }),
        'retryCount': 0,
      });
    }
  }

  @override
  Future<void> saveLivestock(String farmId, LivestockRecord record) async {
    await local.saveLivestock(farmId, record);
    try {
      await remote.sendLivestock(farmId, record);
      await db.update('livestock_records', {'isSynced': 1}, where: 'id = ?', whereArgs: [record.id]);
    } catch (_) {
      await db.insert('sync_queue', {
        'id': record.id,
        'type': 'livestock',
        'payload': jsonEncode({
          'farmId': farmId,
          'id': record.id,
          'type': record.type,
          'tagNumber': record.tagNumber,
          'name': record.name,
          'breed': record.breed,
          'sex': record.sex,
          'dateOfBirth': record.dateOfBirth?.toIso8601String(),
          'weight': record.weight,
          'status': record.status,
        }),
        'retryCount': 0,
      });
    }
  }
}
