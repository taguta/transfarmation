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
  }

  @override
  Future<void> saveLivestock(String farmId, LivestockRecord record) async {
    await local.saveLivestock(farmId, record);
  }
}
