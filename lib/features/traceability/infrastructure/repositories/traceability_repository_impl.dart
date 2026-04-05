import '../../domain/entities/traceability_batch.dart';
import '../../domain/repositories/traceability_repository.dart';
import '../datasource/traceability_local_datasource.dart';

class TraceabilityRepositoryImpl implements TraceabilityRepository {
  final TraceabilityLocalDataSource localDataSource;

  TraceabilityRepositoryImpl(this.localDataSource);

  @override
  Future<List<TraceabilityBatch>> getHarvestBatches() async {
    return await localDataSource.getHarvestBatches();
  }
}
