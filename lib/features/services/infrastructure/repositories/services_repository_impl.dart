import '../../domain/entities/service_partner.dart';
import '../../domain/repositories/services_repository.dart';
import '../datasource/services_remote_datasource.dart';

class ServicesRepositoryImpl implements ServicesRepository {
  final ServicesRemoteDataSource remoteDataSource;
  ServicesRepositoryImpl(this.remoteDataSource);

  @override
  Future<List<ServicePartner>> getServices() async {
    return await remoteDataSource.getServices();
  }
}
