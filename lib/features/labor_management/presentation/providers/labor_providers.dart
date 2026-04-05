import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/labor_models.dart';
import '../../../../core/providers/data_providers.dart';
import '../../infrastructure/datasource/local/labor_sqlite.dart';
import '../../infrastructure/repositories/labor_repository_impl.dart';

final laborRepositoryProvider = Provider<LaborRepositoryImpl>((ref) {
  final db = ref.watch(databaseProvider);
  return LaborRepositoryImpl(LaborLocalDataSource(db), db);
});

final workersProvider = FutureProvider<List<Worker>>((ref) async {
  return ref.watch(laborRepositoryProvider).getWorkers();
});

final tasksProvider = FutureProvider<List<FarmTask>>((ref) async {
  return ref.watch(laborRepositoryProvider).getTasks();
});

final farmTasksByWorkerProvider = Provider.family<AsyncValue<List<FarmTask>>, String>((ref, workerId) {
  final tasksAsync = ref.watch(tasksProvider);
  return tasksAsync.whenData((tasks) => tasks.where((t) => t.assignedWorkerId == workerId).toList());
});

final totalLaborCostProvider = Provider<AsyncValue<double>>((ref) {
  final tasksAsync = ref.watch(tasksProvider);
  return tasksAsync.whenData((tasks) => tasks
      .where((t) => t.status == 'completed')
      .fold(0.0, (sum, task) => sum + task.estimatedCost));
});

