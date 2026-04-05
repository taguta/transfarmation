import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/providers/data_providers.dart';
import '../../domain/entities/sensor_node.dart';
import '../../domain/repositories/iot_repository.dart';
import '../../infrastructure/datasource/local/iot_sqlite.dart';
import '../../infrastructure/repositories/iot_repository_impl.dart';

final iotDataSourceProvider = Provider<IotLocalDataSource>((ref) {
  return IotLocalDataSource(ref.watch(databaseProvider));
});

final iotRepositoryProvider = Provider<IotRepository>((ref) {
  return IotRepositoryImpl(ref.watch(iotDataSourceProvider), ref.watch(databaseProvider));
});

final sensorsProvider = FutureProvider<List<SensorNode>>((ref) async {
  return ref.watch(iotRepositoryProvider).getSensors();
});
