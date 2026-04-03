/// A cooperative or farmer buying group.
class Cooperative {
  final String id;
  final String name;
  final String description;
  final String region;
  final int memberCount;
  final String category; // crop, livestock, mixed
  final List<GroupOrder> activeOrders;

  const Cooperative({
    required this.id,
    required this.name,
    required this.description,
    required this.region,
    required this.memberCount,
    required this.category,
    this.activeOrders = const [],
  });
}

/// A bulk / group order placed by a cooperative.
class GroupOrder {
  final String id;
  final String productName;
  final String supplier;
  final double unitPrice;
  final double bulkPrice;
  final int minimumQuantity;
  final int currentQuantity;
  final String unit; // kg, bags, litres, units
  final DateTime deadline;
  final String status; // open, confirmed, dispatched, delivered

  const GroupOrder({
    required this.id,
    required this.productName,
    required this.supplier,
    required this.unitPrice,
    required this.bulkPrice,
    required this.minimumQuantity,
    required this.currentQuantity,
    required this.unit,
    required this.deadline,
    required this.status,
  });

  double get savings => (unitPrice - bulkPrice) * currentQuantity;
  double get progress => minimumQuantity > 0 ? currentQuantity / minimumQuantity : 0;
  double get discountPercent => unitPrice > 0 ? ((unitPrice - bulkPrice) / unitPrice) * 100 : 0;
}
