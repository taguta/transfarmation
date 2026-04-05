import '../entities/traceability_batch.dart';
abstract class TraceabilityRepository {
  Future<List<TraceabilityBatch>> getHarvestBatches();
}
