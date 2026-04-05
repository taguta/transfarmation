import 'package:sqflite/sqflite.dart';
import '../../domain/entities/farm.dart';

abstract class FarmLocalDataSource {
  Future<Farm?> getCachedFarm(String id);
  Future<void> cacheFarm(Farm farm);
  Future<List<Map<String, dynamic>>> getPendingSyncQueue();
  Future<void> addToSyncQueue(Map<String, dynamic> payload);
  Future<void> clearSyncQueue();
}

class FarmLocalDataSourceImpl implements FarmLocalDataSource {
  final Database database;

  FarmLocalDataSourceImpl(this.database);

  @override
  Future<Farm?> getCachedFarm(String id) async {
    // Abstracting sqlite raw queries handling for cache
    return null; 
  }

  @override
  Future<void> cacheFarm(Farm farm) async {
    // Write farm map to local DB
  }

  @override
  Future<List<Map<String, dynamic>>> getPendingSyncQueue() async {
    return [];
  }

  @override
  Future<void> addToSyncQueue(Map<String, dynamic> payload) async {
    // Insert into sync queue table
  }

  @override
  Future<void> clearSyncQueue() async {}
}
