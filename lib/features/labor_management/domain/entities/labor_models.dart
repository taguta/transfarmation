class Worker {
  final String id;
  final String name;
  final String role; // 'Permanent', 'Seasonal', 'Daily'
  final double dailyWage;
  final String phone;

  Worker({
    required this.id,
    required this.name,
    required this.role,
    required this.dailyWage,
    required this.phone,
  });
}

class FarmTask {
  final String id;
  final String name;
  final String? assignedWorkerId;
  final DateTime date;
  final String status; // 'pending', 'in_progress', 'completed'
  final double estimatedCost;

  FarmTask({
    required this.id,
    required this.name,
    this.assignedWorkerId,
    required this.date,
    required this.status,
    this.estimatedCost = 0.0,
  });
}
