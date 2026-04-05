import '../../domain/entities/service_partner.dart';
import '../../domain/repositories/services_repository.dart';
import '../datasource/local/services_sqlite.dart';

class ServicesRepositoryImpl implements ServicesRepository {
  final ServicesLocalDataSource local;
  ServicesRepositoryImpl(this.local);

  @override
  Future<List<ServicePartner>> getServices() async {
    return await local.getServices();
  }
}
