import '../entities/expert_entity.dart';

abstract class ExpertRepository {
  Future<List<ExpertEntity>> getExperts({String? specialization});
  Future<ExpertEntity> getExpertById(String id);
  Future<void> bookConsultation(String expertId, DateTime slot);
}
