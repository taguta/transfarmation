import 'package:sqflite/sqflite.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/providers/data_providers.dart';

// --- Domain Entity ---
class SensorNode {
  final String id;
  final String name;
  final String type;
  final String status;
  final int battery;
  final String currentValue;
  final String trend;
  final DateTime lastUpdated;

  SensorNode({
    required this.id,
    required this.name,
    required this.type,
    required this.status,
    required this.battery,
    required this.currentValue,
    required this.trend,
    required this.lastUpdated,
  });
}

// --- Local DataSource ---
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

// --- Repository Impl ---
class IotRepositoryImpl {
  final IotLocalDataSource local;
  final Database db;

  IotRepositoryImpl(this.local, this.db);

  Future<List<SensorNode>> getSensors() => local.getSensors();

  Future<void> saveSensor(SensorNode sensor) async {
    await local.saveSensor(sensor);
    await db.insert('sync_queue', {
      'id': sensor.id,
      'type': 'iot_sensor_pairing',
      'payload': '{"id": "${sensor.id}", "name": "${sensor.name}", "type": "${sensor.type}"}',
      'retryCount': 0,
    });
  }
}

// --- Providers ---
final iotRepositoryProvider = Provider<IotRepositoryImpl>((ref) {
  final db = ref.watch(databaseProvider);
  return IotRepositoryImpl(IotLocalDataSource(db), db);
});

final sensorsProvider = FutureProvider<List<SensorNode>>((ref) async {
  return ref.watch(iotRepositoryProvider).getSensors();
});
