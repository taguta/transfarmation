import '../entities/sensor_node.dart';

abstract class IotRepository {
  Future<List<SensorNode>> getSensors();
  Future<void> saveSensor(SensorNode sensor);
}
