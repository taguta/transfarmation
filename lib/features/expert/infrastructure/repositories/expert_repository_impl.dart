import '../../domain/entities/expert_entity.dart';
import '../../domain/repositories/expert_repository.dart';
import '../datasource/local/expert_sqlite.dart';

class ExpertRepositoryImpl implements ExpertRepository {
  final ExpertLocalDataSource localDataSource;

  ExpertRepositoryImpl(this.localDataSource);

  @override
  Future<List<ExpertEntity>> getExperts({String? specialization}) {
    return localDataSource.getExperts(specialization: specialization);
  }

  @override
  Future<ExpertEntity> getExpertById(String id) {
    return localDataSource.getExpertById(id);
  }

  @override
  Future<void> bookConsultation(String expertId, DateTime slot) {
    return localDataSource.bookConsultation(expertId, slot);
  }
}
