import 'package:sqflite/sqflite.dart';
import '../../../domain/entities/cooperative.dart';

class GroupBuyingLocalDataSource {
  final Database db;
  GroupBuyingLocalDataSource(this.db);

  Future<void> saveCooperative(Cooperative coop) async {
    await db.insert('cooperatives', {
      'id': coop.id,
      'name': coop.name,
      'description': coop.description,
      'region': coop.region,
      'memberCount': coop.memberCount,
      'category': coop.category,
      'isSynced': 0,
    }, conflictAlgorithm: ConflictAlgorithm.replace);

    for (final order in coop.activeOrders) {
      await saveOrder(coop.id, order);
    }
  }

  Future<void> saveOrder(String coopId, GroupOrder order) async {
    await db.insert('group_orders', {
      'id': order.id,
      'cooperativeId': coopId,
      'productName': order.productName,
      'supplier': order.supplier,
      'unitPrice': order.unitPrice,
      'bulkPrice': order.bulkPrice,
      'minimumQuantity': order.minimumQuantity,
      'currentQuantity': order.currentQuantity,
      'unit': order.unit,
      'deadline': order.deadline.toIso8601String(),
      'status': order.status,
      'isSynced': 0,
    }, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<List<Cooperative>> getCooperatives() async {
    final coopRows = await db.query('cooperatives');
    final coops = <Cooperative>[];

    for (final row in coopRows) {
      final coopId = row['id'] as String;
      final orderRows = await db.query(
        'group_orders',
        where: 'cooperativeId = ?',
        whereArgs: [coopId],
      );
      coops.add(
        Cooperative(
          id: coopId,
          name: row['name'] as String,
          description: row['description'] as String? ?? '',
          region: row['region'] as String? ?? '',
          memberCount: row['memberCount'] as int? ?? 0,
          category: row['category'] as String? ?? 'mixed',
          activeOrders:
              orderRows
                  .map(
                    (o) => GroupOrder(
                      id: o['id'] as String,
                      productName: o['productName'] as String,
                      supplier: o['supplier'] as String? ?? '',
                      unitPrice: (o['unitPrice'] as num).toDouble(),
                      bulkPrice: (o['bulkPrice'] as num).toDouble(),
                      minimumQuantity: o['minimumQuantity'] as int? ?? 0,
                      currentQuantity: o['currentQuantity'] as int? ?? 0,
                      unit: o['unit'] as String? ?? 'kg',
                      deadline: DateTime.parse(o['deadline'] as String),
                      status: o['status'] as String? ?? 'open',
                    ),
                  )
                  .toList(),
        ),
      );
    }
    return coops;
  }

  Future<List<GroupOrder>> getActiveOrders() async {
    final rows = await db.query(
      'group_orders',
      where: 'status = ?',
      whereArgs: ['open'],
    );
    return rows
        .map(
          (o) => GroupOrder(
            id: o['id'] as String,
            productName: o['productName'] as String,
            supplier: o['supplier'] as String? ?? '',
            unitPrice: (o['unitPrice'] as num).toDouble(),
            bulkPrice: (o['bulkPrice'] as num).toDouble(),
            minimumQuantity: o['minimumQuantity'] as int? ?? 0,
            currentQuantity: o['currentQuantity'] as int? ?? 0,
            unit: o['unit'] as String? ?? 'kg',
            deadline: DateTime.parse(o['deadline'] as String),
            status: o['status'] as String? ?? 'open',
          ),
        )
        .toList();
  }
}
