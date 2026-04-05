import 'dart:convert';
import 'package:sqflite/sqflite.dart';
import '../../domain/entities/sensor_node.dart';
import '../../domain/repositories/iot_repository.dart';
import '../datasource/local/iot_sqlite.dart';

class IotRepositoryImpl implements IotRepository {
  final IotLocalDataSource local;
  final Database db;

  IotRepositoryImpl(this.local, this.db);

  @override
  Future<List<SensorNode>> getSensors() async {
    return await local.getSensors();
  }

  @override
  Future<void> saveSensor(SensorNode sensor) async {
    await local.saveSensor(sensor);
    await db.insert('sync_queue', {
      'id': sensor.id,
      'type': 'iot_sensor',
      'payload': jsonEncode({
        'id': sensor.id,
        'name': sensor.name,
        'type': sensor.type,
        'status': sensor.status,
        'battery': sensor.battery,
        'currentValue': sensor.currentValue,
        'trend': sensor.trend,
        'lastUpdated': sensor.lastUpdated.toIso8601String(),
      }),
      'retryCount': 0,
    });
  }
}
