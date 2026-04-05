import '../entities/sensor_node.dart';

abstract class IotRepository {
  Stream<List<SensorNode>> watchSensors();
  Future<void> saveSensor(SensorNode sensor);
}
