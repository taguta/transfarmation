import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/farming_contract.dart';

import '../../../../core/providers/data_providers.dart';

final contractsProvider = FutureProvider<List<FarmingContract>>((ref) async {
  final repo = ref.watch(contractRepositoryImplProvider);
  return repo.getContracts('farmer-001');
});

// --- Filter ---
final contractFilterProvider = StateProvider<String>((ref) => 'all'); // all, open, applied, active

final filteredContractsProvider = FutureProvider<List<FarmingContract>>((ref) async {
  final all = await ref.watch(contractsProvider.future);
  final filter = ref.watch(contractFilterProvider);
  if (filter == 'all') return all;
  return all.where((c) => c.status == filter).toList();
});
