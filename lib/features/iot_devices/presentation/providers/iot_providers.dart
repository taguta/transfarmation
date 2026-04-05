import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/providers/data_providers.dart';
import '../../domain/entities/sensor_node.dart';
import '../../domain/repositories/iot_repository.dart';
import '../../infrastructure/datasource/iot_remote_datasource.dart';
import '../../infrastructure/repositories/iot_repository_impl.dart';

final iotDataSourceProvider = Provider<IotRemoteDataSource>((ref) {
  return IotRemoteDataSourceFirestoreImpl(ref.watch(firestoreProvider));
});

final iotRepositoryProvider = Provider<IotRepository>((ref) {
  return IotRepositoryImpl(ref.watch(iotDataSourceProvider));
});

final sensorsProvider = StreamProvider<List<SensorNode>>((ref) {
  return ref.watch(iotRepositoryProvider).watchSensors();
});
