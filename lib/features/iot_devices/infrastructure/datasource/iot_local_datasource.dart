import 'package:sqflite/sqflite.dart';
import '../../domain/entities/sensor_node.dart';

class IotLocalDataSource {
  final Database db;

  IotLocalDataSource(this.db);

  Future<List<SensorNode>> getSensors() async {
    final rows = await db.query('iot_sensors');
    return rows.map((r) => SensorNode(
      id: r['id'] as String,
      name: r['name'] as String,
      type: r['type'] as String,
      status: r['status'] as String,
      battery: r['battery'] as int,
      currentValue: r['currentValue'] as String,
      trend: r['trend'] as String,
      lastUpdated: DateTime.parse(r['lastUpdated'] as String),
    )).toList();
  }

  Future<void> saveSensor(SensorNode sensor) async {
    await db.insert('iot_sensors', {
      'id': sensor.id,
      'farmId': 'default_farm',
      'name': sensor.name,
      'type': sensor.type,
      'status': sensor.status,
      'battery': sensor.battery,
      'currentValue': sensor.currentValue,
      'trend': sensor.trend,
      'lastUpdated': sensor.lastUpdated.toIso8601String(),
    }, conflictAlgorithm: ConflictAlgorithm.replace);
  }
}
