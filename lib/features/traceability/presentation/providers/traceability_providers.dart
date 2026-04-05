import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/providers/data_providers.dart';
import '../../infrastructure/datasource/traceability_local_datasource.dart';
import '../../infrastructure/repositories/traceability_repository_impl.dart';
import '../../domain/repositories/traceability_repository.dart';
import '../../domain/entities/traceability_batch.dart';

final traceabilityLocalDataSourceProvider = Provider<TraceabilityLocalDataSource>((ref) {
  final db = ref.watch(databaseProvider);
  return TraceabilityLocalDataSourceImpl(db);
});

final traceabilityRepositoryProvider = Provider<TraceabilityRepository>((ref) {
  return TraceabilityRepositoryImpl(ref.watch(traceabilityLocalDataSourceProvider));
});

final traceabilityBatchesProvider = FutureProvider<List<TraceabilityBatch>>((ref) {
  return ref.watch(traceabilityRepositoryProvider).getHarvestBatches();
});
