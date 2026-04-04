import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/cooperative.dart';

import '../../../../core/providers/data_providers.dart';

final cooperativesProvider = FutureProvider<List<Cooperative>>((ref) async {
  final repo = ref.watch(groupBuyingRepositoryImplProvider);
  return repo.getCooperatives('farmer-001');
});

/// All active group orders across all cooperatives.
final allGroupOrdersProvider = Provider<List<MapEntry<Cooperative, GroupOrder>>>((ref) {
  final coopsAsync = ref.watch(cooperativesProvider);
  final coops = coopsAsync.value ?? [];
  final orders = <MapEntry<Cooperative, GroupOrder>>[];
  for (final c in coops) {
    for (final o in c.activeOrders) {
      orders.add(MapEntry(c, o));
    }
  }
  return orders;
});
