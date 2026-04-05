import '../../domain/entities/expert_entity.dart';
import '../../domain/repositories/expert_repository.dart';
import '../datasource/expert_remote_datasource.dart';

class ExpertRepositoryImpl implements ExpertRepository {
  final ExpertRemoteDataSource remoteDataSource;

  ExpertRepositoryImpl(this.remoteDataSource);

  @override
  Future<List<ExpertEntity>> getExperts({String? specialization}) {
    return remoteDataSource.getExperts(specialization: specialization);
  }

  @override
  Future<ExpertEntity> getExpertById(String id) {
    return remoteDataSource.getExpertById(id);
  }

  @override
  Future<void> bookConsultation(String expertId, DateTime slot) {
    return remoteDataSource.bookConsultation(expertId, slot);
  }
}
