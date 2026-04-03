import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/farm.dart';

import '../../../../core/providers/data_providers.dart';

// --- Farm list provider ---
final farmListProvider = FutureProvider<List<Farm>>((ref) async {
  final repo = ref.watch(farmRepositoryImplProvider);
  return await repo.getFarms('farmer-001');
});

// --- Selected farm provider ---
final selectedFarmIndexProvider = StateProvider<int>((ref) => 0);

// --- Farm summary stats ---
final farmSummaryProvider = Provider<Map<String, dynamic>>((ref) {
  final farmsAsync = ref.watch(farmListProvider);
  final farms = farmsAsync.value ?? [];
  if (farms.isEmpty) return {};

  final farm = farms[ref.watch(selectedFarmIndexProvider)];
  final totalExpenses = farm.fields.fold<double>(0, (s, f) => s + f.totalExpenses);
  final plantedHa = farm.fields.where((f) => f.status != 'fallow').fold<double>(0, (s, f) => s + f.hectares);
  final cattleCount = farm.livestockRecords.where((l) => l.type == 'cattle' && l.status == 'active').length;
  final poultryCount = farm.livestockRecords.where((l) => l.type == 'poultry' && l.status == 'active').length;
  final goatCount = farm.livestockRecords.where((l) => l.type == 'goat' && l.status == 'active').length;

  return {
    'totalHa': farm.totalHectares,
    'plantedHa': plantedHa,
    'fallowHa': farm.totalHectares - plantedHa,
    'totalExpenses': totalExpenses,
    'cattleCount': cattleCount,
    'poultryCount': poultryCount,
    'goatCount': goatCount,
    'totalLivestock': farm.livestockRecords.where((l) => l.status == 'active').length,
    'fieldCount': farm.fields.length,
  };
});
