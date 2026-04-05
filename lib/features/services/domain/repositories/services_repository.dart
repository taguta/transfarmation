import '../entities/service_partner.dart';
abstract class ServicesRepository {
  Future<List<ServicePartner>> getServices();
}
