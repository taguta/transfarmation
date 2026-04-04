import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/farm_input.dart';

import '../../../../core/providers/data_providers.dart';

final inputsProvider = FutureProvider<List<FarmInput>>((ref) async {
  final repo = ref.watch(inputRepositoryImplProvider);
  return repo.getInputs();
});

final inputCategoryProvider = Provider.family<List<FarmInput>, String>((
  ref,
  category,
) {
  final inputsAsync = ref.watch(inputsProvider);
  final inputs = inputsAsync.value ?? [];
  if (category == 'all') return inputs;
  return inputs.where((i) => i.category == category).toList();
});

// ─── Subsidy Programs ──────────────────────────────────
final subsidyProgramsProvider = FutureProvider<List<SubsidyProgram>>((ref) async {
  final repo = ref.watch(inputRepositoryImplProvider);
  return repo.getSubsidyPrograms();
});

final subsidyApplicationsProvider = FutureProvider<List<SubsidyApplication>>((ref) async {
  final repo = ref.watch(inputRepositoryImplProvider);
  return repo.getMyApplications('farmer-001');
});
