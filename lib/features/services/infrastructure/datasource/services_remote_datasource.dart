import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/service_partner.dart';

abstract class ServicesRemoteDataSource {
  Future<List<ServicePartner>> getServices();
}

class ServicesRemoteDataSourceFirestoreImpl implements ServicesRemoteDataSource {
  final FirebaseFirestore firestore;
  ServicesRemoteDataSourceFirestoreImpl(this.firestore);

  @override
  Future<List<ServicePartner>> getServices() async {
    final snapshot = await firestore.collection('app_services').orderBy('orderIndex').get();
    return snapshot.docs.map((doc) {
      final data = doc.data();
      return ServicePartner(
        id: doc.id,
        title: data['title'] ?? '',
        subtitle: data['subtitle'] ?? '',
        iconCode: data['iconCode'] ?? '0xe3ae',
        colorHex: data['colorHex'] ?? '0xFF4CAF50',
        route: data['route'] ?? '/home',
      );
    }).toList();
  }
}
