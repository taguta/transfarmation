import 'dart:convert';
import 'package:sqflite/sqflite.dart';
import '../../../domain/entities/commodity.dart';

class CommodityLocalDataSource {
  final Database db;
  CommodityLocalDataSource(this.db);

  Future<void> cacheCommodities(List<Commodity> commodities) async {
    final batch = db.batch();
    for (final c in commodities) {
      batch.insert('commodity_prices', {
        'id': c.id,
        'name': c.name,
        'category': c.category,
        'unit': c.unit,
        'currentPrice': c.currentPrice,
        'previousPrice': c.previousPrice,
        'history': jsonEncode(
          c.history.map((p) => {'month': p.month, 'price': p.price}).toList(),
        ),
        'updatedAt': DateTime.now().toIso8601String(),
        'isSynced': 1,
      }, conflictAlgorithm: ConflictAlgorithm.replace);
    }
    await batch.commit(noResult: true);
  }

  Future<List<Commodity>> getCommodities() async {
    final rows = await db.query('commodity_prices');
    return rows.map((r) {
      List<PricePoint> history = [];
      if (r['history'] != null) {
        try {
          final decoded = jsonDecode(r['history'] as String) as List;
          history =
              decoded
                  .map(
                    (p) => PricePoint(
                      month: p['month'] as String,
                      price: (p['price'] as num).toDouble(),
                    ),
                  )
                  .toList();
        } catch (_) {}
      }
      return Commodity(
        id: r['id'] as String,
        name: r['name'] as String,
        category: r['category'] as String? ?? '',
        unit: r['unit'] as String? ?? 'per tonne',
        currentPrice: (r['currentPrice'] as num).toDouble(),
        previousPrice: (r['previousPrice'] as num).toDouble(),
        history: history,
      );
    }).toList();
  }
}
