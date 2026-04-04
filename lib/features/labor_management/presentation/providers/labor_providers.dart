import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/labor_models.dart';

// --- Dummy Data ---
final _dummyWorkers = [
  Worker(id: 'w1', name: 'James Banda', role: 'Permanent', dailyWage: 15.0, phone: '0771234567'),
  Worker(id: 'w2', name: 'Sarah Moyo', role: 'Seasonal', dailyWage: 10.0, phone: '0711234567'),
  Worker(id: 'w3', name: 'Tendai Mutasa', role: 'Daily', dailyWage: 8.0, phone: '0731234567'),
];

final _dummyTasks = [
  FarmTask(id: 't1', name: 'Weed Field B (Maize)', assignedWorkerId: 'w2', date: DateTime.now(), status: 'in_progress', estimatedCost: 10.0),
  FarmTask(id: 't2', name: 'Apply Top Dressing', assignedWorkerId: 'w1', date: DateTime.now().add(const Duration(days: 1)), status: 'pending', estimatedCost: 15.0),
  FarmTask(id: 't3', name: 'Harvest Tomatoes', assignedWorkerId: 'w3', date: DateTime.now().subtract(const Duration(days: 1)), status: 'completed', estimatedCost: 8.0),
];

// --- Providers ---
final workersProvider = StateProvider<List<Worker>>((ref) => _dummyWorkers);
final tasksProvider = StateProvider<List<FarmTask>>((ref) => _dummyTasks);

final farmTasksByWorkerProvider = Provider.family<List<FarmTask>, String>((ref, workerId) {
  final tasks = ref.watch(tasksProvider);
  return tasks.where((t) => t.assignedWorkerId == workerId).toList();
});

final totalLaborCostProvider = Provider<double>((ref) {
  final tasks = ref.watch(tasksProvider);
  return tasks
      .where((t) => t.status == 'completed')
      .fold(0.0, (sum, task) => sum + task.estimatedCost);
});
