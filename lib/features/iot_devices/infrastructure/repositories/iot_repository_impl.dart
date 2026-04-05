import '../../domain/entities/sensor_node.dart';
import '../../domain/repositories/iot_repository.dart';
import '../datasource/iot_remote_datasource.dart';

class IotRepositoryImpl implements IotRepository {
  final IotRemoteDataSource remoteDataSource;

  IotRepositoryImpl(this.remoteDataSource);

  @override
  Stream<List<SensorNode>> watchSensors() {
    return remoteDataSource.watchSensors();
  }

  @override
  Future<void> saveSensor(SensorNode sensor) async {
    await remoteDataSource.saveSensor(sensor);
  }
}
