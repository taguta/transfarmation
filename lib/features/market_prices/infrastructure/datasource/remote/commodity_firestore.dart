import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../domain/entities/commodity.dart';

class CommodityRemoteDataSource {
  final FirebaseFirestore firestore;
  CommodityRemoteDataSource(this.firestore);

  Future<List<Commodity>> fetchCommodities() async {
    final snap = await firestore.collection('commodity_prices').get();
    return snap.docs.map((doc) {
      final d = doc.data();
      final historyRaw = d['history'] as List<dynamic>? ?? [];
      return Commodity(
        id: doc.id,
        name: d['name'] as String? ?? '',
        category: d['category'] as String? ?? '',
        unit: d['unit'] as String? ?? 'per tonne',
        currentPrice: (d['currentPrice'] as num?)?.toDouble() ?? 0,
        previousPrice: (d['previousPrice'] as num?)?.toDouble() ?? 0,
        history:
            historyRaw
                .map(
                  (p) => PricePoint(
                    month: (p as Map)['month'] as String? ?? '',
                    price: ((p)['price'] as num?)?.toDouble() ?? 0,
                  ),
                )
                .toList(),
      );
    }).toList();
  }
}
