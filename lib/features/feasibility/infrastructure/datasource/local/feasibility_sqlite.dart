import 'dart:convert';
import 'package:sqflite/sqflite.dart';
import '../../../domain/entities/feasibility_plan.dart';

class FeasibilityLocalDataSource {
  final Database db;
  FeasibilityLocalDataSource(this.db);

  Future<void> save(FeasibilityPlan plan) async {
    await db.insert('feasibility_plans', {
      'id': plan.id,
      'farmerId': plan.farmerId,
      'crop': plan.inputs.crop,
      'data': jsonEncode(plan.inputs.toJson()),
      'createdAt': plan.createdAt.toIso8601String(),
      'isSynced': plan.isSynced ? 1 : 0,
    }, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<List<FeasibilityPlan>> getAll() async {
    final rows = await db.query('feasibility_plans', orderBy: 'createdAt DESC');
    return rows
        .map((r) => FeasibilityPlan(
              id: r['id'] as String,
              farmerId: r['farmerId'] as String,
              inputs: FeasibilityInputs.fromJson(
                jsonDecode(r['data'] as String) as Map<String, dynamic>,
              ),
              createdAt: DateTime.parse(r['createdAt'] as String),
              isSynced: (r['isSynced'] as int? ?? 0) == 1,
            ))
        .toList();
  }

  Future<void> delete(String id) =>
      db.delete('feasibility_plans', where: 'id = ?', whereArgs: [id]);
}
