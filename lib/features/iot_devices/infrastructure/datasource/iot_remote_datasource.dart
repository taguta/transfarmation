import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/sensor_node.dart';

abstract class IotRemoteDataSource {
  Stream<List<SensorNode>> watchSensors();
  Future<void> saveSensor(SensorNode sensor);
}

class IotRemoteDataSourceFirestoreImpl implements IotRemoteDataSource {
  final FirebaseFirestore firestore;
  IotRemoteDataSourceFirestoreImpl(this.firestore);

  @override
  Stream<List<SensorNode>> watchSensors() {
    return firestore.collection('iot_devices').snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data();
        return SensorNode(
          id: doc.id,
          name: data['name'] ?? 'Unknown Sensor',
          type: data['type'] ?? 'General',
          status: data['status'] ?? 'offline',
          battery: data['battery'] ?? 0,
          currentValue: data['currentValue'] ?? '0.0',
          trend: data['trend'] ?? 'flat',
          lastUpdated: (data['lastUpdated'] as Timestamp?)?.toDate() ?? DateTime.now(),
        );
      }).toList();
    });
  }

  @override
  Future<void> saveSensor(SensorNode sensor) async {
    await firestore.collection('iot_devices').doc(sensor.id).set({
      'name': sensor.name,
      'type': sensor.type,
      'status': sensor.status,
      'battery': sensor.battery,
      'currentValue': sensor.currentValue,
      'trend': sensor.trend,
      'lastUpdated': FieldValue.serverTimestamp(),
    });
  }
}
