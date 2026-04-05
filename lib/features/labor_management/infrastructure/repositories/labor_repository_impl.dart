import 'dart:convert';
import 'package:sqflite/sqflite.dart';
import '../../domain/entities/labor_models.dart';
import '../datasource/local/labor_sqlite.dart';

class LaborRepositoryImpl {
  final LaborLocalDataSource local;
  final Database db;

  LaborRepositoryImpl(this.local, this.db);

  Future<List<Worker>> getWorkers() => local.getWorkers();

  Future<List<FarmTask>> getTasks() => local.getTasks();

  Future<void> saveWorker(Worker worker) async {
    await local.saveWorker(worker);
    await db.insert('sync_queue', {
      'id': worker.id,
      'type': 'worker',
      'payload': jsonEncode({
        'id': worker.id,
        'name': worker.name,
        'role': worker.role,
        'dailyWage': worker.dailyWage,
        'phone': worker.phone,
      }),
      'retryCount': 0,
    });
  }

  Future<void> saveTask(FarmTask task) async {
    await local.saveTask(task);
    await db.insert('sync_queue', {
      'id': task.id,
      'type': 'farm_task',
      'payload': jsonEncode({
        'id': task.id,
        'name': task.name,
        'assignedWorkerId': task.assignedWorkerId,
        'date': task.date.toIso8601String(),
        'status': task.status,
        'estimatedCost': task.estimatedCost,
      }),
      'retryCount': 0,
    });
  }
}
