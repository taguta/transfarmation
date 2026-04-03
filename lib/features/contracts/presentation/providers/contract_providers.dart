import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/farming_contract.dart';

final contractsProvider = NotifierProvider<ContractNotifier, List<FarmingContract>>(
  ContractNotifier.new,
);

class ContractNotifier extends Notifier<List<FarmingContract>> {
  @override
  List<FarmingContract> build() {
    return [
      FarmingContract(
        id: '1',
        buyerName: 'National Foods Ltd',
        buyerType: 'processor',
        commodity: 'White Maize',
        pricePerUnit: 400,
        unit: 'per tonne',
        minQuantity: 5,
        season: '2025/26',
        region: 'Mashonaland East & Central',
        deadline: DateTime(2025, 9, 30),
        status: 'open',
        requirements: [
          'Moisture content below 12.5%',
          'No aflatoxin contamination',
          'Minimum 95% purity',
        ],
        buyerProvides: [
          'Seed (SeedCo SC 513)',
          'Compound D and AN fertilizer',
          'Extension officer visits',
        ],
      ),
      FarmingContract(
        id: '2',
        buyerName: 'Mashonaland Tobacco Company',
        buyerType: 'exporter',
        commodity: 'Flue-Cured Tobacco',
        pricePerUnit: 4.20,
        unit: 'per kg',
        minQuantity: 500,
        season: '2025/26',
        region: 'Mashonaland Central & West',
        deadline: DateTime(2025, 8, 15),
        status: 'open',
        requirements: [
          'Minimum 2 years tobacco experience',
          'Own curing barn (min 2 units)',
          'Registered with TIMB',
        ],
        buyerProvides: [
          'Seedbed materials',
          'All chemicals and fertilizers',
          'Technical support throughout season',
          'Transport to auction floors',
        ],
      ),
      FarmingContract(
        id: '3',
        buyerName: 'Cottco',
        buyerType: 'processor',
        commodity: 'Seed Cotton',
        pricePerUnit: 0.90,
        unit: 'per kg',
        minQuantity: 1000,
        season: '2025/26',
        region: 'Nationwide (Regions III-V)',
        deadline: DateTime(2025, 10, 15),
        status: 'open',
        requirements: [
          'Minimum 2 hectares',
          'Previous cotton growing experience preferred',
        ],
        buyerProvides: [
          'Certified seed',
          'Chemicals (pesticides)',
          'Extension support',
          'Collection from designated points',
        ],
      ),
      FarmingContract(
        id: '4',
        buyerName: 'Surface Wilmar',
        buyerType: 'processor',
        commodity: 'Soya Beans',
        pricePerUnit: 700,
        unit: 'per tonne',
        minQuantity: 3,
        season: '2025/26',
        region: 'Mashonaland East',
        deadline: DateTime(2025, 9, 15),
        status: 'applied',
        requirements: [
          'Moisture content below 13%',
          'Oil content above 18%',
          'No foreign material',
        ],
        buyerProvides: [
          'Inoculant at cost',
        ],
      ),
      FarmingContract(
        id: '5',
        buyerName: 'Dairibord',
        buyerType: 'processor',
        commodity: 'Fresh Milk',
        pricePerUnit: 0.65,
        unit: 'per litre',
        minQuantity: 50,
        season: 'Ongoing',
        region: 'Mashonaland',
        deadline: DateTime(2025, 12, 31),
        status: 'active',
        requirements: [
          'Dairy cattle (min 5 cows)',
          'Milking parlour with cold chain',
          'HACCP compliance',
        ],
        buyerProvides: [
          'Collection truck (daily)',
          'Veterinary support',
          'AI services',
        ],
      ),
    ];
  }

  void applyForContract(String contractId) {
    state = [
      for (final c in state)
        if (c.id == contractId)
          FarmingContract(
            id: c.id,
            buyerName: c.buyerName,
            buyerType: c.buyerType,
            commodity: c.commodity,
            pricePerUnit: c.pricePerUnit,
            unit: c.unit,
            minQuantity: c.minQuantity,
            season: c.season,
            region: c.region,
            requirements: c.requirements,
            buyerProvides: c.buyerProvides,
            deadline: c.deadline,
            status: 'applied',
          )
        else
          c,
    ];
  }
}

// --- Filter ---
final contractFilterProvider = StateProvider<String>((ref) => 'all'); // all, open, applied, active

final filteredContractsProvider = Provider<List<FarmingContract>>((ref) {
  final all = ref.watch(contractsProvider);
  final filter = ref.watch(contractFilterProvider);
  if (filter == 'all') return all;
  return all.where((c) => c.status == filter).toList();
});
