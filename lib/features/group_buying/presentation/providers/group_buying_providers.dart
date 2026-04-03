import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/cooperative.dart';

final cooperativesProvider = NotifierProvider<CooperativeNotifier, List<Cooperative>>(
  CooperativeNotifier.new,
);

class CooperativeNotifier extends Notifier<List<Cooperative>> {
  @override
  List<Cooperative> build() {
    return [
      Cooperative(
        id: '1',
        name: 'Mhondoro Farmers Union',
        description: 'Mixed farming cooperative serving Mhondoro-Ngezi district. Joint purchasing of inputs and collective marketing of maize and soya.',
        region: 'Mashonaland West',
        memberCount: 45,
        category: 'mixed',
        activeOrders: [
          GroupOrder(
            id: 'go1',
            productName: 'Compound D Fertilizer',
            supplier: 'ZFC Ltd',
            unitPrice: 38,
            bulkPrice: 30,
            minimumQuantity: 200,
            currentQuantity: 156,
            unit: 'bags (50kg)',
            deadline: DateTime(2025, 9, 15),
            status: 'open',
          ),
          GroupOrder(
            id: 'go2',
            productName: 'SeedCo SC 513 Maize Seed',
            supplier: 'SeedCo Zimbabwe',
            unitPrice: 25,
            bulkPrice: 20,
            minimumQuantity: 100,
            currentQuantity: 100,
            unit: 'bags (25kg)',
            deadline: DateTime(2025, 9, 1),
            status: 'confirmed',
          ),
        ],
      ),
      Cooperative(
        id: '2',
        name: 'Guruve Tobacco Growers',
        description: 'Tobacco-focused cooperative in Guruve district. Group buying of chemicals and curing fuel.',
        region: 'Mashonaland Central',
        memberCount: 32,
        category: 'crop',
        activeOrders: [
          GroupOrder(
            id: 'go3',
            productName: 'Confidor (Imidacloprid)',
            supplier: 'Agricura',
            unitPrice: 18,
            bulkPrice: 14,
            minimumQuantity: 60,
            currentQuantity: 42,
            unit: 'litres',
            deadline: DateTime(2025, 8, 20),
            status: 'open',
          ),
        ],
      ),
      Cooperative(
        id: '3',
        name: 'Chipinge Poultry Syndicate',
        description: 'Poultry cooperative buying feed and day-old-chicks in bulk for members in Chipinge area.',
        region: 'Manicaland',
        memberCount: 28,
        category: 'livestock',
        activeOrders: [
          GroupOrder(
            id: 'go4',
            productName: 'Broiler Starter Mash',
            supplier: 'National Foods',
            unitPrice: 32,
            bulkPrice: 26,
            minimumQuantity: 150,
            currentQuantity: 130,
            unit: 'bags (50kg)',
            deadline: DateTime(2025, 8, 10),
            status: 'open',
          ),
          GroupOrder(
            id: 'go5',
            productName: 'Day-Old Broiler Chicks',
            supplier: 'Irvine\'s Zimbabwe',
            unitPrice: 1.50,
            bulkPrice: 1.10,
            minimumQuantity: 5000,
            currentQuantity: 5000,
            unit: 'chicks',
            deadline: DateTime(2025, 8, 5),
            status: 'dispatched',
          ),
        ],
      ),
    ];
  }

  void joinOrder(String coopId, String orderId, int qty) {
    state = [
      for (final c in state)
        if (c.id == coopId)
          Cooperative(
            id: c.id,
            name: c.name,
            description: c.description,
            region: c.region,
            memberCount: c.memberCount,
            category: c.category,
            activeOrders: [
              for (final o in c.activeOrders)
                if (o.id == orderId)
                  GroupOrder(
                    id: o.id,
                    productName: o.productName,
                    supplier: o.supplier,
                    unitPrice: o.unitPrice,
                    bulkPrice: o.bulkPrice,
                    minimumQuantity: o.minimumQuantity,
                    currentQuantity: o.currentQuantity + qty,
                    unit: o.unit,
                    deadline: o.deadline,
                    status: o.status,
                  )
                else
                  o,
            ],
          )
        else
          c,
    ];
  }
}

/// All active group orders across all cooperatives.
final allGroupOrdersProvider = Provider<List<MapEntry<Cooperative, GroupOrder>>>((ref) {
  final coops = ref.watch(cooperativesProvider);
  final orders = <MapEntry<Cooperative, GroupOrder>>[];
  for (final c in coops) {
    for (final o in c.activeOrders) {
      orders.add(MapEntry(c, o));
    }
  }
  return orders;
});
