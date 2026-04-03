import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../domain/entities/farm.dart';

class FarmRemoteDataSource {
  final FirebaseFirestore firestore;
  FarmRemoteDataSource(this.firestore);

  Future<void> sendFarm(Farm farm) async {
    final docRef = firestore.collection('farms').doc(farm.id);
    await docRef.set({
      'name': farm.name,
      'farmerId': farm.farmerId,
      'totalHectares': farm.totalHectares,
      'region': farm.region,
      'soilType': farm.soilType,
      'waterSource': farm.waterSource,
      'latitude': farm.latitude,
      'longitude': farm.longitude,
      'address': farm.address,
      'updatedAt': FieldValue.serverTimestamp(),
    });

    for (final field in farm.fields) {
      await docRef.collection('fields').doc(field.id).set({
        'name': field.name,
        'hectares': field.hectares,
        'currentCrop': field.currentCrop,
        'season': field.season,
        'status': field.status,
        'yieldTonnes': field.yieldTonnes,
      });
    }

    for (final record in farm.livestockRecords) {
      await docRef.collection('livestock').doc(record.id).set({
        'type': record.type,
        'tagNumber': record.tagNumber,
        'name': record.name,
        'breed': record.breed,
        'sex': record.sex,
        'dateOfBirth': record.dateOfBirth?.toIso8601String(),
        'weight': record.weight,
        'status': record.status,
      });
    }
  }
}
