import 'package:sqflite/sqflite.dart';
import '../../../domain/entities/labor_models.dart';

class LaborLocalDataSource {
  final Database db;

  LaborLocalDataSource(this.db);

  Future<void> saveWorker(Worker worker) async {
    await db.insert(
      'farm_workers',
      {
        'id': worker.id,
        'farmId': 'default_farm', // Inject current farm
        'name': worker.name,
        'role': worker.role,
        'dailyWage': worker.dailyWage,
        'phone': worker.phone,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<Worker>> getWorkers() async {
    final rows = await db.query('farm_workers');
    return rows.map((r) => Worker(
      id: r['id'] as String,
      name: r['name'] as String,
      role: r['role'] as String,
      dailyWage: (r['dailyWage'] as num).toDouble(),
      phone: r['phone'] as String,
    )).toList();
  }

  Future<void> saveTask(FarmTask task) async {
    await db.insert(
      'farm_tasks',
      {
        'id': task.id,
        'farmId': 'default_farm',
        'name': task.name,
        'assignedWorkerId': task.assignedWorkerId,
        'date': task.date.toIso8601String(),
        'status': task.status,
        'estimatedCost': task.estimatedCost,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<FarmTask>> getTasks() async {
    final rows = await db.query('farm_tasks');
    return rows.map((r) => FarmTask(
      id: r['id'] as String,
      name: r['name'] as String,
      assignedWorkerId: r['assignedWorkerId'] as String,
      date: DateTime.parse(r['date'] as String),
      status: r['status'] as String,
      estimatedCost: (r['estimatedCost'] as num).toDouble(),
    )).toList();
  }
}
