import 'dart:convert';
import 'package:sqflite/sqflite.dart';
import '../../domain/entities/feasibility_plan.dart';
import '../datasource/local/feasibility_sqlite.dart';

/// Offline-first: writes hit SQLite and the sync queue; the UI only reads SQLite.
class FeasibilityRepository {
  final FeasibilityLocalDataSource local;
  final Database db;
  FeasibilityRepository(this.local, this.db);

  Future<List<FeasibilityPlan>> getPlans() => local.getAll();

  Future<void> savePlan(FeasibilityPlan plan) async {
    await local.save(plan);
    await db.insert('sync_queue', {
      'id': 'feasibility_${plan.id}',
      'type': 'feasibility_plan',
      'payload': jsonEncode({
        'id': plan.id,
        'farmerId': plan.farmerId,
        'createdAt': plan.createdAt.toIso8601String(),
        'updatedAt': DateTime.now().toIso8601String(),
        ...plan.inputs.toJson(),
      }),
      'retryCount': 0,
    }, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<void> deletePlan(String id) => local.delete(id);
}
