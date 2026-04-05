import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/providers/data_providers.dart';
import '../../infrastructure/datasource/services_remote_datasource.dart';
import '../../infrastructure/repositories/services_repository_impl.dart';
import '../../domain/repositories/services_repository.dart';
import '../../domain/entities/service_partner.dart';

final servicesRemoteDataSourceProvider = Provider<ServicesRemoteDataSource>((ref) {
  return ServicesRemoteDataSourceFirestoreImpl(ref.watch(firestoreProvider));
});

final servicesRepositoryProvider = Provider<ServicesRepository>((ref) {
  return ServicesRepositoryImpl(ref.watch(servicesRemoteDataSourceProvider));
});

final dynamicServicesProvider = FutureProvider<List<ServicePartner>>((ref) {
  return ref.watch(servicesRepositoryProvider).getServices();
});
