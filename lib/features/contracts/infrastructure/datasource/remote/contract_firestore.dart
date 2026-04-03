import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../domain/entities/farming_contract.dart';

class ContractRemoteDataSource {
  final FirebaseFirestore firestore;
  ContractRemoteDataSource(this.firestore);

  Future<void> applyToContract(String contractId, String farmerId) async {
    await firestore
        .collection('farming_contracts')
        .doc(contractId)
        .collection('applications')
        .doc(farmerId)
        .set({
          'farmerId': farmerId,
          'appliedAt': FieldValue.serverTimestamp(),
          'status': 'applied',
        });
  }

  Future<List<FarmingContract>> fetchContracts({
    String? region,
    String? commodity,
  }) async {
    Query<Map<String, dynamic>> query = firestore.collection(
      'farming_contracts',
    );
    if (region != null) {
      query = query.where('region', isEqualTo: region);
    }
    if (commodity != null) {
      query = query.where('commodity', isEqualTo: commodity);
    }

    final snap = await query.get();
    return snap.docs.map((doc) {
      final d = doc.data();
      return FarmingContract(
        id: doc.id,
        buyerName: d['buyerName'] as String? ?? '',
        buyerType: d['buyerType'] as String? ?? '',
        commodity: d['commodity'] as String? ?? '',
        pricePerUnit: (d['pricePerUnit'] as num?)?.toDouble() ?? 0,
        unit: d['unit'] as String? ?? 'tonne',
        minQuantity: d['minQuantity'] as int? ?? 0,
        season: d['season'] as String? ?? '',
        region: d['region'] as String? ?? '',
        requirements: List<String>.from(d['requirements'] ?? []),
        buyerProvides: List<String>.from(d['buyerProvides'] ?? []),
        deadline:
            d['deadline'] != null
                ? (d['deadline'] as Timestamp).toDate()
                : DateTime.now(),
        status: d['status'] as String? ?? 'open',
      );
    }).toList();
  }
}
