import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../domain/entities/cooperative.dart';

class GroupBuyingRemoteDataSource {
  final FirebaseFirestore firestore;
  GroupBuyingRemoteDataSource(this.firestore);

  Future<void> joinOrder(String orderId, String farmerId, int quantity) async {
    await firestore
        .collection('group_orders')
        .doc(orderId)
        .collection('participants')
        .doc(farmerId)
        .set({
          'farmerId': farmerId,
          'quantity': quantity,
          'joinedAt': FieldValue.serverTimestamp(),
        });
  }

  Future<List<Cooperative>> fetchCooperatives(String region) async {
    final snap =
        await firestore
            .collection('cooperatives')
            .where('region', isEqualTo: region)
            .get();
    return snap.docs.map((doc) {
      final d = doc.data();
      return Cooperative(
        id: doc.id,
        name: d['name'] as String? ?? '',
        description: d['description'] as String? ?? '',
        region: d['region'] as String? ?? '',
        memberCount: d['memberCount'] as int? ?? 0,
        category: d['category'] as String? ?? 'mixed',
      );
    }).toList();
  }
}
