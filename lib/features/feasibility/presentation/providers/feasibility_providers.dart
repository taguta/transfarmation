import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/providers/data_providers.dart';
import '../../domain/entities/feasibility_plan.dart';
import '../../infrastructure/datasource/local/feasibility_sqlite.dart';
import '../../infrastructure/repositories/feasibility_repository.dart';

final feasibilityRepositoryProvider = Provider<FeasibilityRepository>((ref) {
  final db = ref.watch(databaseProvider);
  return FeasibilityRepository(FeasibilityLocalDataSource(db), db);
});

final feasibilityPlansProvider = FutureProvider<List<FeasibilityPlan>>((ref) {
  return ref.watch(feasibilityRepositoryProvider).getPlans();
});
