import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/commodity.dart';
import '../../../../core/providers/data_providers.dart';

final commoditiesProvider = FutureProvider<List<Commodity>>((ref) {
  final repo = ref.watch(marketPriceRepositoryImplProvider);
  return repo.getCommodities();
});

// --- Filtered by category ---
final selectedCategoryProvider = StateProvider<String?>((ref) => null);

final filteredCommoditiesProvider = FutureProvider<List<Commodity>>((ref) async {
  final all = await ref.watch(commoditiesProvider.future);
  final cat = ref.watch(selectedCategoryProvider);
  if (cat == null) return all;
  return all.where((c) => c.category == cat).toList();
});
