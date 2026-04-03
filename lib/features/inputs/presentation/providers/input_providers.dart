import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/farm_input.dart';

// ─── Input Products Provider ───────────────────────────
class InputsNotifier extends Notifier<List<FarmInput>> {
  @override
  List<FarmInput> build() => _mockInputs;

  static final List<FarmInput> _mockInputs = const [
    // Seeds
    FarmInput(
      id: 'input-001',
      name: 'SC513 Maize Seed',
      category: 'seeds',
      supplier: 'SeedCo Zimbabwe',
      description:
          'Early maturing hybrid. 120 days. Drought tolerant. Ideal for Regions III-IV.',
      price: 45.00,
      unit: '10kg bag',
      bulkPrice: 38.00,
      bulkMinQuantity: 20,
      isVerified: true,
      inStock: true,
    ),
    FarmInput(
      id: 'input-002',
      name: 'SC727 Maize Seed',
      category: 'seeds',
      supplier: 'SeedCo Zimbabwe',
      description:
          'Medium-late maturity hybrid. High yield potential under good conditions. Regions I-III.',
      price: 52.00,
      unit: '10kg bag',
      bulkPrice: 44.00,
      bulkMinQuantity: 20,
      isVerified: true,
      inStock: true,
    ),
    FarmInput(
      id: 'input-003',
      name: 'PAN53 Maize Seed',
      category: 'seeds',
      supplier: 'Pannar Seeds',
      description:
          'Very early maturing (105 days). Excellent standability. Regions II-IV.',
      price: 48.00,
      unit: '10kg bag',
      isVerified: true,
      inStock: true,
    ),
    FarmInput(
      id: 'input-004',
      name: 'Soya Bean Seed (Soprano)',
      category: 'seeds',
      supplier: 'SeedCo Zimbabwe',
      description:
          'High-yielding soya variety. Good lodging resistance. Inoculate before planting.',
      price: 35.00,
      unit: '25kg bag',
      bulkPrice: 30.00,
      bulkMinQuantity: 10,
      isVerified: true,
      inStock: true,
    ),
    FarmInput(
      id: 'input-005',
      name: 'Sugar Bean Seed (NUA45)',
      category: 'seeds',
      supplier: 'National Tested Seeds',
      description: 'High-yielding sugar bean. Good cooking quality.',
      price: 28.00,
      unit: '10kg bag',
      isVerified: true,
      inStock: false,
    ),

    // Fertilizers
    FarmInput(
      id: 'input-010',
      name: 'Compound D (NPK 7:14:7)',
      category: 'fertilizer',
      supplier: 'ZFC Limited',
      description:
          'Basal fertilizer for maize, sorghum, millet. Apply at planting.',
      price: 42.00,
      unit: '50kg bag',
      bulkPrice: 36.00,
      bulkMinQuantity: 50,
      isVerified: true,
      inStock: true,
    ),
    FarmInput(
      id: 'input-011',
      name: 'Ammonium Nitrate (AN 34.5%)',
      category: 'fertilizer',
      supplier: 'ZFC Limited',
      description: 'Top dressing fertilizer. Apply 4-6 weeks after emergence.',
      price: 38.00,
      unit: '50kg bag',
      bulkPrice: 33.00,
      bulkMinQuantity: 50,
      isVerified: true,
      inStock: true,
    ),
    FarmInput(
      id: 'input-012',
      name: 'Compound L (NPK 5:18:10)',
      category: 'fertilizer',
      supplier: 'Windmill',
      description: 'Basal fertilizer for tobacco. Also suitable for potatoes.',
      price: 55.00,
      unit: '50kg bag',
      isVerified: true,
      inStock: true,
    ),
    FarmInput(
      id: 'input-013',
      name: 'Lime (Dolomitic)',
      category: 'fertilizer',
      supplier: 'Dorowa Minerals',
      description:
          'Soil amendment for acidic soils. Apply 2-3 months before planting.',
      price: 15.00,
      unit: '50kg bag',
      isVerified: true,
      inStock: true,
    ),

    // Chemicals
    FarmInput(
      id: 'input-020',
      name: 'Emamectin Benzoate 5% SG',
      category: 'chemicals',
      supplier: 'Agricura',
      description: 'For Fall Armyworm control in maize. Apply in the whorl.',
      price: 12.00,
      unit: '100g pack',
      isVerified: true,
      inStock: true,
    ),
    FarmInput(
      id: 'input-021',
      name: 'Glyphosate 480 SL',
      category: 'chemicals',
      supplier: 'Agricura',
      description: 'Non-selective herbicide for pre-plant weed control. 3L/ha.',
      price: 8.00,
      unit: 'litre',
      isVerified: true,
      inStock: true,
    ),
    FarmInput(
      id: 'input-022',
      name: 'Dimethoate 400 EC',
      category: 'chemicals',
      supplier: 'Windmill',
      description: 'Systemic insecticide for aphids, thrips on various crops.',
      price: 10.00,
      unit: 'litre',
      isVerified: true,
      inStock: true,
    ),

    // Equipment
    FarmInput(
      id: 'input-030',
      name: 'Knapsack Sprayer 16L',
      category: 'equipment',
      supplier: 'Farm & City',
      description:
          'Manual knapsack sprayer for chemical application. Includes nozzles.',
      price: 35.00,
      unit: 'each',
      isVerified: true,
      inStock: true,
    ),
    FarmInput(
      id: 'input-031',
      name: 'Hoe (Badza)',
      category: 'equipment',
      supplier: 'Local Suppliers',
      description: 'Essential hand tool for land preparation and weeding.',
      price: 5.00,
      unit: 'each',
      isVerified: false,
      inStock: true,
    ),

    // Feed
    FarmInput(
      id: 'input-040',
      name: 'Broiler Starter Mash',
      category: 'feed',
      supplier: 'National Foods',
      description: 'Complete feed for broiler chicks 0-14 days. 22% protein.',
      price: 25.00,
      unit: '50kg bag',
      isVerified: true,
      inStock: true,
    ),
    FarmInput(
      id: 'input-041',
      name: 'Layer Mash',
      category: 'feed',
      supplier: 'ProFeeds',
      description: 'Complete feed for laying hens. 16% protein with calcium.',
      price: 22.00,
      unit: '50kg bag',
      isVerified: true,
      inStock: true,
    ),
    FarmInput(
      id: 'input-042',
      name: 'Stock Feed Concentrate',
      category: 'feed',
      supplier: 'National Foods',
      description:
          'Cattle/goat supplement for dry season. Mix with crop residues.',
      price: 18.00,
      unit: '50kg bag',
      isVerified: true,
      inStock: true,
    ),
  ];
}

final inputsProvider = NotifierProvider<InputsNotifier, List<FarmInput>>(
  InputsNotifier.new,
);

final inputCategoryProvider = Provider.family<List<FarmInput>, String>((
  ref,
  category,
) {
  final inputs = ref.watch(inputsProvider);
  if (category == 'all') return inputs;
  return inputs.where((i) => i.category == category).toList();
});

// ─── Subsidy Programs ──────────────────────────────────
final subsidyProgramsProvider = Provider<List<SubsidyProgram>>((ref) {
  return const [
    SubsidyProgram(
      id: 'sub-001',
      name: 'Presidential Input Scheme 2026/27',
      provider: 'Government of Zimbabwe',
      description:
          'Free input package for vulnerable smallholder farmers. Includes 10kg maize seed, 50kg Compound D, 50kg AN.',
      eligibility: 'Communal farmers with <2 hectares, registered with AGRITEX',
      applicationDeadline: '15 September 2026',
      status: 'open',
      coveredInputs: ['Maize Seed', 'Compound D', 'Ammonium Nitrate'],
      maxAmount: 150.00,
    ),
    SubsidyProgram(
      id: 'sub-002',
      name: 'Pfumvudza/Intwasa Programme',
      provider: 'Government of Zimbabwe',
      description:
          'Conservation agriculture program providing inputs for 0.1ha Pfumvudza plot per household.',
      eligibility: 'All communal area farmers. Must attend Pfumvudza training.',
      applicationDeadline: '30 August 2026',
      status: 'open',
      coveredInputs: ['Maize Seed', 'Compound D', 'AN', 'Lime'],
      maxAmount: 80.00,
    ),
    SubsidyProgram(
      id: 'sub-003',
      name: 'Command Agriculture Soya Bean',
      provider: 'CBZ Agro-Yield / Government',
      description:
          'Contract farming scheme for soya bean production. Full input package provided on loan.',
      eligibility:
          'Farmers with >5 hectares irrigated land. Must have title deed or offer letter.',
      applicationDeadline: '31 October 2026',
      status: 'open',
      coveredInputs: ['Soya Seed', 'Fertilizer', 'Chemicals', 'Fuel'],
      maxAmount: 2000.00,
    ),
    SubsidyProgram(
      id: 'sub-004',
      name: 'FAO Livestock Support Programme',
      provider: 'FAO / UN',
      description:
          'Support for smallholder livestock farmers with veterinary supplies and feed supplements.',
      eligibility: 'Smallholder farmers in Regions IV-V with livestock',
      applicationDeadline: '28 February 2026',
      status: 'closed',
      coveredInputs: ['Vaccines', 'Dipping chemicals', 'Mineral licks'],
      maxAmount: 200.00,
    ),
  ];
});

// ─── Subsidy Applications ──────────────────────────────
class SubsidyApplicationsNotifier extends Notifier<List<SubsidyApplication>> {
  @override
  List<SubsidyApplication> build() => [
    SubsidyApplication(
      id: 'app-001',
      programId: 'sub-002',
      programName: 'Pfumvudza/Intwasa Programme',
      status: 'approved',
      appliedDate: DateTime(2026, 7, 15),
      amountApproved: 80.00,
      notes: 'Collect inputs at Mhondoro AGRITEX depot',
    ),
  ];

  void apply(SubsidyApplication application) {
    state = [...state, application];
  }
}

final subsidyApplicationsProvider =
    NotifierProvider<SubsidyApplicationsNotifier, List<SubsidyApplication>>(
      SubsidyApplicationsNotifier.new,
    );
