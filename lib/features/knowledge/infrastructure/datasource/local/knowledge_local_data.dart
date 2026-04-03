import '../../../domain/entities/crop.dart';
import '../../../domain/entities/livestock.dart';
import '../../../domain/entities/pest_disease.dart';

/// Bundled offline knowledge data for Zimbabwe and Southern Africa.
/// This serves as the local data source — no internet required.
class KnowledgeLocalData {
  static const List<Crop> crops = [
    // ─── Grains ──────────────────────────────────────
    Crop(
      id: 'crop-001',
      name: 'Maize',
      category: 'grain',
      scientificName: 'Zea mays',
      description:
          'Zimbabwe\'s staple food crop. Grown by over 80% of smallholder farmers. '
          'Used for sadza (thick porridge), animal feed, and brewing.',
      plantingSeason: 'October – December (with first rains)',
      harvestSeason: 'April – June',
      waterRequirements: '500–800mm rainfall; sensitive to drought at tasseling stage',
      soilType: 'Well-drained loamy soils, pH 5.5–7.0',
      regions: ['II', 'III', 'IV'],
      growthDuration: '120–150 days',
      spacing: '90cm between rows, 25–30cm in-row',
      yieldPerHectare: '1–3 tonnes (smallholder), 6–10 tonnes (irrigated)',
      commonPests: ['Fall Armyworm', 'Stalk Borer', 'Maize Weevil'],
      commonDiseases: ['Gray Leaf Spot', 'Maize Streak Virus', 'Northern Leaf Blight'],
      tips: [
        CropTip(title: 'Conservation Farming', content: 'Use Pfumvudza/Intwasa method with planting basins for higher yields with less water.'),
        CropTip(title: 'Fall Armyworm Control', content: 'Scout early (first 3 weeks). Apply Bt-based biopesticides or approved chemicals in the whorl.'),
        CropTip(title: 'Seed Selection', content: 'Use certified hybrid seed (SC513, SC727, PAN53) for better yields. Keep 10% extra for replanting gaps.'),
      ],
    ),
    Crop(
      id: 'crop-002',
      name: 'Sorghum',
      category: 'grain',
      scientificName: 'Sorghum bicolor',
      description:
          'Drought-tolerant grain ideal for semi-arid regions. '
          'Used for sadza, traditional beer (hwahwa), and livestock feed.',
      plantingSeason: 'November – December',
      harvestSeason: 'May – June',
      waterRequirements: '400–600mm; highly drought-tolerant',
      soilType: 'Tolerates poor, sandy soils; pH 5.5–8.0',
      regions: ['III', 'IV', 'V'],
      growthDuration: '100–130 days',
      spacing: '75cm between rows, 15–20cm in-row',
      yieldPerHectare: '0.5–1.5 tonnes (smallholder), 3–5 tonnes (commercial)',
      commonPests: ['Stem Borer', 'Quelea Birds', 'Aphids'],
      commonDiseases: ['Anthracnose', 'Leaf Blight', 'Smut'],
      tips: [
        CropTip(title: 'Bird Control', content: 'Plant at the same time as neighbors to minimize quelea bird damage. Early planting helps.'),
        CropTip(title: 'Intercropping', content: 'Intercrop with cowpeas or groundnuts for nitrogen fixation and better land use.'),
      ],
    ),
    Crop(
      id: 'crop-003',
      name: 'Pearl Millet (Mhunga)',
      category: 'indigenous',
      scientificName: 'Pennisetum glaucum',
      description:
          'Traditional indigenous grain with excellent drought tolerance. '
          'Highly nutritious, gluten-free. Staple in Regions IV and V.',
      plantingSeason: 'November – December',
      harvestSeason: 'April – May',
      waterRequirements: '300–500mm; most drought-tolerant cereal',
      soilType: 'Sandy soils, tolerates low fertility',
      regions: ['IV', 'V'],
      growthDuration: '85–110 days',
      spacing: '50cm between rows, 15cm in-row',
      yieldPerHectare: '0.3–0.8 tonnes (smallholder)',
      commonPests: ['Birds', 'Stem Borer'],
      commonDiseases: ['Downy Mildew', 'Ergot', 'Smut'],
      tips: [
        CropTip(title: 'Food Security Crop', content: 'Ideal for food security in dry areas where maize fails. Stores well for years.'),
      ],
    ),
    Crop(
      id: 'crop-004',
      name: 'Finger Millet (Rapoko)',
      category: 'indigenous',
      scientificName: 'Eleusine coracana',
      description:
          'Traditional small grain rich in calcium, iron, and amino acids. '
          'Used for porridge, maheu (traditional drink), and brewing. Cultural significance in Zimbabwe.',
      plantingSeason: 'November – December',
      harvestSeason: 'April – May',
      waterRequirements: '400–600mm',
      soilType: 'Well-drained sandy loam',
      regions: ['III', 'IV'],
      growthDuration: '100–130 days',
      spacing: 'Broadcast or 30cm rows, thin to 10cm',
      yieldPerHectare: '0.3–0.8 tonnes',
      commonPests: ['Birds', 'Shoot Fly'],
      commonDiseases: ['Blast', 'Leaf Spot'],
      tips: [
        CropTip(title: 'High Nutrition', content: 'Contains 3x more calcium than milk per weight. Excellent for child nutrition programs.'),
      ],
    ),

    // ─── Cash Crops ──────────────────────────────────
    Crop(
      id: 'crop-005',
      name: 'Tobacco',
      category: 'cash_crop',
      scientificName: 'Nicotiana tabacum',
      description:
          'Zimbabwe\'s largest foreign currency earner. Flue-cured variety '
          'dominant. Sold through auction floors and contract farming.',
      plantingSeason: 'Seedbeds: August. Transplant: October–November',
      harvestSeason: 'January – April (sequential leaf picking)',
      waterRequirements: '600–900mm; irrigation critical during curing',
      soilType: 'Sandy loam, well-drained, pH 5.0–6.5',
      regions: ['I', 'II', 'III'],
      growthDuration: '120–150 days (transplant to final harvest)',
      spacing: '120cm between rows, 50–60cm in-row',
      yieldPerHectare: '1.5–2.5 tonnes (dry leaf)',
      commonPests: ['Aphids', 'Cutworm', 'Budworm', 'Nematodes'],
      commonDiseases: ['Angular Leaf Spot', 'Wildfire', 'Alternaria', 'Root Rot'],
      tips: [
        CropTip(title: 'TIMB Registration', content: 'Register with Tobacco Industry Marketing Board (TIMB) before planting. Mandatory for selling.'),
        CropTip(title: 'Curing Quality', content: 'Proper curing determines 60% of price. Monitor barn temperature (35-70°C progression) carefully.'),
      ],
    ),
    Crop(
      id: 'crop-006',
      name: 'Soya Beans',
      category: 'cash_crop',
      scientificName: 'Glycine max',
      description:
          'High-protein oilseed. Growing demand for stockfeed and cooking oil. '
          'Excellent rotation crop with maize (fixes nitrogen).',
      plantingSeason: 'November – mid December',
      harvestSeason: 'April – May',
      waterRequirements: '500–700mm; sensitive to waterlogging',
      soilType: 'Well-drained loamy soils, pH 6.0–6.5',
      regions: ['II', 'III'],
      growthDuration: '110–140 days',
      spacing: '45–50cm between rows, 5–7cm in-row',
      yieldPerHectare: '1–2 tonnes (smallholder), 2.5–4 tonnes (commercial)',
      commonPests: ['Bean Fly', 'Pod Borer', 'Stink Bug'],
      commonDiseases: ['Soybean Rust', 'Bacterial Pustule', 'Frogeye Leaf Spot'],
      tips: [
        CropTip(title: 'Inoculation', content: 'Always inoculate seed with Bradyrhizobium japonicum for nitrogen fixation. Doubles yield in new fields.'),
        CropTip(title: 'Rotation Benefit', content: 'Plant soya after maize. Residual nitrogen boosts next maize crop by 30-50kg N/ha.'),
      ],
    ),
    Crop(
      id: 'crop-007',
      name: 'Cotton',
      category: 'cash_crop',
      scientificName: 'Gossypium hirsutum',
      description:
          'Major smallholder cash crop in low-rainfall areas. '
          'Grown under contract farming (Cottco, Alliance Ginneries).',
      plantingSeason: 'Late October – November',
      harvestSeason: 'May – July (multiple pickings)',
      waterRequirements: '500–700mm; drought tolerant after establishment',
      soilType: 'Deep clay loam soils, pH 5.5–7.0',
      regions: ['III', 'IV'],
      growthDuration: '150–180 days',
      spacing: '90cm between rows, 30cm in-row',
      yieldPerHectare: '0.5–1.0 tonnes seed cotton (smallholder)',
      commonPests: ['Bollworm', 'Aphids', 'Jassid', 'Red Spider Mite'],
      commonDiseases: ['Bacterial Blight', 'Alternaria Leaf Spot', 'Verticillium Wilt'],
      tips: [
        CropTip(title: 'Contract Farming', content: 'Register with ginning companies for input support and guaranteed market. Check payment terms carefully.'),
      ],
    ),
    Crop(
      id: 'crop-008',
      name: 'Groundnuts',
      category: 'cash_crop',
      scientificName: 'Arachis hypogaea',
      description:
          'Dual-purpose crop for food and income. Rich in protein, oil. '
          'Improves soil fertility through nitrogen fixation.',
      plantingSeason: 'November – December',
      harvestSeason: 'April – May',
      waterRequirements: '500–600mm; sensitive to waterlogging at harvest',
      soilType: 'Light sandy loam, well-drained, pH 5.5–6.5',
      regions: ['II', 'III', 'IV'],
      growthDuration: '120–150 days',
      spacing: '45cm between rows, 10–15cm in-row',
      yieldPerHectare: '0.5–1.0 tonnes (unshelled, smallholder)',
      commonPests: ['Aphids', 'Termites', 'Leaf Miner'],
      commonDiseases: ['Aflatoxin (Aspergillus)', 'Early Leaf Spot', 'Late Leaf Spot', 'Rosette Virus'],
      tips: [
        CropTip(title: 'Aflatoxin Prevention', content: 'Harvest on time, dry quickly to <8% moisture. Store in cool, dry conditions. Aflatoxin is a serious health risk.'),
        CropTip(title: 'Seed Quality', content: 'Use Natal Common, Falcon, or Valencia Red. Avoid planting cracked or discolored seed.'),
      ],
    ),

    // ─── Horticulture ────────────────────────────────
    Crop(
      id: 'crop-009',
      name: 'Tomatoes',
      category: 'horticulture',
      scientificName: 'Solanum lycopersicum',
      description:
          'High-value vegetable crop. Grown for fresh market and processing. '
          'Can be highly profitable with proper management.',
      plantingSeason: 'Year-round with irrigation; main season Sept–Nov',
      harvestSeason: '60–90 days after transplant',
      waterRequirements: 'Regular irrigation, 600–800mm; drip preferred',
      soilType: 'Rich loamy soil, pH 6.0–6.8',
      regions: ['I', 'II', 'III'],
      growthDuration: '90–120 days',
      spacing: '60–90cm between rows, 45–60cm in-row',
      yieldPerHectare: '20–60 tonnes (open field)',
      commonPests: ['Tuta absoluta', 'Whitefly', 'Red Spider Mite', 'Bollworm'],
      commonDiseases: ['Early Blight', 'Late Blight', 'Bacterial Wilt', 'Fusarium Wilt'],
      tips: [
        CropTip(title: 'Tuta absoluta Management', content: 'Use pheromone traps, neem-based sprays, and resistant varieties. Destroy crop residues after harvest.'),
        CropTip(title: 'Staking', content: 'Always stake/trellis tomatoes. Reduces disease, improves fruit quality, and makes spraying easier.'),
      ],
    ),
    Crop(
      id: 'crop-010',
      name: 'Onions',
      category: 'horticulture',
      scientificName: 'Allium cepa',
      description:
          'Essential vegetable with good storage life. '
          'High demand year-round. Suitable for smallholder production.',
      plantingSeason: 'Seedbed: March–April. Transplant: May–June',
      harvestSeason: 'September – October',
      waterRequirements: 'Regular irrigation, reduce before harvest for curing',
      soilType: 'Rich, well-drained loam, pH 6.0–7.0',
      regions: ['I', 'II', 'III'],
      growthDuration: '120–150 days (transplant to harvest)',
      spacing: '30cm between rows, 10cm in-row',
      yieldPerHectare: '15–40 tonnes',
      commonPests: ['Thrips', 'Onion Fly', 'Cutworm'],
      commonDiseases: ['Purple Blotch', 'Downy Mildew', 'Basal Rot'],
      tips: [
        CropTip(title: 'Curing', content: 'Cure onions in shade for 7–14 days after harvest. Proper curing extends storage life to 3–6 months.'),
      ],
    ),
    Crop(
      id: 'crop-011',
      name: 'Butternut Squash',
      category: 'horticulture',
      scientificName: 'Cucurbita moschata',
      description:
          'Popular vegetable rich in vitamin A. Stores well without refrigeration. '
          'Highly suited for food security programs.',
      plantingSeason: 'September – November',
      harvestSeason: 'January – March',
      waterRequirements: '400–600mm; moderate water needs',
      soilType: 'Rich, well-drained soil, pH 6.0–7.0',
      regions: ['I', 'II', 'III', 'IV'],
      growthDuration: '90–110 days',
      spacing: '200cm between rows, 100cm in-row',
      yieldPerHectare: '15–30 tonnes',
      commonPests: ['Pumpkin Fly', 'Aphids', 'Red Spider Mite'],
      commonDiseases: ['Powdery Mildew', 'Downy Mildew'],
      tips: [
        CropTip(title: 'Storage', content: 'Harvest when stem is dry and skin is hard. Stores up to 6 months in cool, dry conditions.'),
      ],
    ),
    Crop(
      id: 'crop-012',
      name: 'Sugar Beans',
      category: 'grain',
      scientificName: 'Phaseolus vulgaris',
      description:
          'Most consumed legume in Zimbabwe. Excellent protein source. '
          'Grown widely by smallholders for food and income.',
      plantingSeason: 'January – February (late season crop)',
      harvestSeason: 'April – May',
      waterRequirements: '300–500mm; sensitive to waterlogging',
      soilType: 'Well-drained loamy soil, pH 5.5–6.5',
      regions: ['II', 'III'],
      growthDuration: '80–100 days',
      spacing: '45cm between rows, 10cm in-row',
      yieldPerHectare: '0.8–1.5 tonnes',
      commonPests: ['Bean Fly', 'Aphids', 'Pod Borer'],
      commonDiseases: ['Angular Leaf Spot', 'Rust', 'Common Blight'],
      tips: [
        CropTip(title: 'Relay Cropping', content: 'Plant beans between maize rows in January for extra harvest from the same land.'),
      ],
    ),
  ];

  static const List<Livestock> livestock = [
    // ─── Cattle ──────────────────────────────────────
    Livestock(
      id: 'lstock-001',
      name: 'Mashona Cattle',
      category: 'cattle',
      breed: 'Mashona (Indigenous)',
      description:
          'Zimbabwe\'s premier indigenous breed. Highly adapted to local conditions. '
          'Heat tolerant, tick resistant, good foragers on poor grazing. Medium-sized.',
      feedRequirements: 'Grazes on natural veld; supplement with crop residues in dry season. '
          'Requires 8–12kg dry matter/day.',
      housingRequirements: 'Kraal/pen with shade. Dip tank access for tick control every 2 weeks.',
      breedingCycle: 'Calving interval: 12–14 months. First calving: 30–36 months. Bull:cow ratio 1:25.',
      averageWeight: 'Cows: 350–400kg, Bulls: 500–600kg',
      maturityAge: '24–30 months',
      productionOutput: 'Beef: 50–55% dressing percentage. Also used as draught power.',
      commonDiseases: ['Theileriosis (January Disease)', 'Anaplasmosis', 'Babesiosis', 'Lumpy Skin Disease', 'Foot and Mouth Disease'],
      vaccinations: ['Anthrax (annual)', 'Blackleg/Botulism (annual)', 'Lumpy Skin Disease', 'Brucellosis (heifers 4–8 months)'],
      tips: [
        LivestockTip(title: 'Tick Control', content: 'Dip every 14 days. January Disease (Theileriosis) kills more cattle than any other disease in Zimbabwe.'),
        LivestockTip(title: 'Breeding Value', content: 'Use Mashona bulls in crossbreeding programs. Their adaptability improves hardiness in crossbred offspring.'),
      ],
    ),
    Livestock(
      id: 'lstock-002',
      name: 'Brahman Cattle',
      category: 'cattle',
      breed: 'Brahman (Bos indicus)',
      description:
          'Heat-tolerant breed popular with commercial farmers. '
          'Good growth rate. Often crossed with indigenous breeds.',
      feedRequirements: 'Grazing + supplementary feeding for optimal growth. '
          'Feedlot finishing: 10–15kg concentrate/day.',
      housingRequirements: 'Paddock system with handling facilities. Regular dipping required.',
      breedingCycle: 'Calving interval: 12–15 months. First calving: 24–30 months. Bull:cow ratio 1:30.',
      averageWeight: 'Cows: 450–550kg, Bulls: 700–900kg',
      maturityAge: '18–24 months',
      productionOutput: 'Beef: 55–60% dressing. Excellent feedlot performance.',
      commonDiseases: ['Theileriosis', 'Heartwater', 'Foot and Mouth Disease', 'Bovine Tuberculosis'],
      vaccinations: ['Anthrax (annual)', 'Blackleg/Botulism (annual)', 'Lumpy Skin Disease'],
      tips: [
        LivestockTip(title: 'Crossbreeding', content: 'Brahman x Mashona produces excellent F1 crosses with hybrid vigor for both commercial and communal use.'),
      ],
    ),
    Livestock(
      id: 'lstock-003',
      name: 'Tuli Cattle',
      category: 'cattle',
      breed: 'Tuli (Indigenous)',
      description:
          'Indigenous Sanga breed from Matabeleland. Excellent fertility, '
          'heat tolerance, and walking ability. Docile temperament.',
      feedRequirements: 'Thrives on natural veld grazing even in Region V. Minimal supplementation needed.',
      housingRequirements: 'Basic kraaling. Very low maintenance breed.',
      breedingCycle: 'Calving interval: 12 months. First calving: 24 months. Excellent fertility.',
      averageWeight: 'Cows: 400–450kg, Bulls: 600–700kg',
      maturityAge: '18–24 months',
      productionOutput: 'Beef: 52–56% dressing. Known for tender, well-marbled meat.',
      commonDiseases: ['Theileriosis', 'Anaplasmosis', 'Heartwater'],
      vaccinations: ['Anthrax (annual)', 'Blackleg/Botulism (annual)'],
      tips: [
        LivestockTip(title: 'Conservation', content: 'Tuli is a rare breed. Consider registering with Tuli Cattle Breeders Association of Zimbabwe for genetic preservation.'),
      ],
    ),

    // ─── Goats ───────────────────────────────────────
    Livestock(
      id: 'lstock-004',
      name: 'Indigenous Goats (Matebele)',
      category: 'goats',
      breed: 'Matebele / Small East African',
      description:
          'Widely kept in communal areas. Hardy, disease-resistant. '
          'Important for food security, cultural ceremonies, and income.',
      feedRequirements: 'Browse on shrubs, bushes, and crop residues. Supplement with mineral licks.',
      housingRequirements: 'Simple raised shelter to protect from predators and rain. Must be well-ventilated.',
      breedingCycle: 'Kidding interval: 8–10 months. Twins common. Buck:doe ratio 1:25.',
      averageWeight: 'Does: 25–35kg, Bucks: 35–50kg',
      maturityAge: '8–12 months',
      productionOutput: 'Meat: 45–50% dressing. Also milk (0.5–1L/day) in some breeds.',
      commonDiseases: ['Heartwater', 'Pneumonia', 'Orf (Sore Mouth)', 'Internal Parasites (Worms)'],
      vaccinations: ['Pulpy Kidney/Enterotoxaemia', 'Pasteurellosis'],
      tips: [
        LivestockTip(title: 'Deworming', content: 'Deworm every 3 months. Rotate anthelmintics to prevent resistance. Use FAMACHA scoring for targeted treatment.'),
        LivestockTip(title: 'Quick Income', content: 'Goats reproduce faster than cattle and provide quicker returns. Ideal for smallholder farmers starting out.'),
      ],
    ),
    Livestock(
      id: 'lstock-005',
      name: 'Boer Goats',
      category: 'goats',
      breed: 'Boer',
      description:
          'Premium meat breed from South Africa. Fast growth rate. '
          'Popular for crossbreeding with indigenous goats.',
      feedRequirements: 'Good grazing + supplementary feeding for maximum growth. Needs quality browse.',
      housingRequirements: 'Sheltered housing with good ventilation. Paddock system preferred.',
      breedingCycle: 'Kidding interval: 8–9 months. Triplets possible. Buck:doe ratio 1:30.',
      averageWeight: 'Does: 55–75kg, Bucks: 90–120kg',
      maturityAge: '6–8 months',
      productionOutput: 'Meat: 50–55% dressing. Premium meat prices.',
      commonDiseases: ['Heartwater', 'Pneumonia', 'Internal Parasites', 'Foot Rot'],
      vaccinations: ['Pulpy Kidney', 'Pasteurellosis', 'CDT Vaccine'],
      tips: [
        LivestockTip(title: 'Crossbreeding', content: 'Boer x Indigenous first-cross does are excellent mothers with improved meat yield.'),
      ],
    ),

    // ─── Poultry ─────────────────────────────────────
    Livestock(
      id: 'lstock-006',
      name: 'Road Runner Chickens',
      category: 'poultry',
      breed: 'Indigenous / Road Runner',
      description:
          'Zimbabwe\'s free-range indigenous chickens. Hardy, self-sufficient. '
          'Every rural household keeps them. Cultural and economic importance.',
      feedRequirements: 'Scavenging + supplementary grain (maize, sunflower). '
          '50–80g feed/day if supplemented.',
      housingRequirements: 'Simple chicken house, raised from ground, predator-proof. Lock up at night.',
      breedingCycle: 'Hens brood naturally 3–4 times/year. 8–12 eggs per clutch. 21-day incubation.',
      averageWeight: 'Hens: 1.2–1.8kg, Roosters: 1.8–2.5kg',
      maturityAge: '5–6 months',
      productionOutput: 'Eggs: 60–80/year. Meat: Premium prices for free-range. Highly sought for ceremonies.',
      commonDiseases: ['Newcastle Disease', 'Fowl Pox', 'Coccidiosis', 'Respiratory infections'],
      vaccinations: ['Newcastle Disease (Lasota vaccine every 3 months)', 'Fowl Pox (wing web at 8 weeks)'],
      tips: [
        LivestockTip(title: 'Newcastle Prevention', content: 'Vaccinate with Lasota in drinking water every 3 months. Newcastle wipes out entire flocks if unvaccinated.'),
        LivestockTip(title: 'Improved Housing', content: 'Simple housing reduces predator losses by 80%. Use wire mesh, raised floor, and locks.'),
      ],
    ),
    Livestock(
      id: 'lstock-007',
      name: 'Broiler Chickens',
      category: 'poultry',
      breed: 'Ross 308 / Cobb 500',
      description:
          'Fast-growing meat birds. Ready for market in 6 weeks. '
          'Popular peri-urban and rural enterprise.',
      feedRequirements: 'Starter mash (0–2 weeks), grower mash (2–4 weeks), finisher (4–6 weeks). '
          '4.5kg total feed per bird to slaughter.',
      housingRequirements: 'Deep litter system. 10 birds/m². Temperature control critical for chicks (32°C reducing to 24°C).',
      breedingCycle: 'N/A — purchase day-old chicks every cycle. 6-week production cycle.',
      averageWeight: '1.8–2.5kg live weight at 6 weeks',
      maturityAge: '35–42 days (slaughter)',
      productionOutput: 'Meat: 70–75% dressing. FCR: 1.7–1.9.',
      commonDiseases: ['Newcastle Disease', 'Coccidiosis', 'Infectious Bronchitis', 'Ascites'],
      vaccinations: ['Newcastle (Day 1, Day 14)', 'Gumboro (Day 7, Day 21)', 'Infectious Bronchitis'],
      tips: [
        LivestockTip(title: 'Biosecurity', content: 'Footbath at entrance. No visitors in poultry house. All-in-all-out system between batches.'),
        LivestockTip(title: 'Costing', content: 'Feed is 70% of cost. Calculate break-even price before starting. Need minimum 100 birds for viability.'),
      ],
    ),
    Livestock(
      id: 'lstock-008',
      name: 'Layer Chickens',
      category: 'poultry',
      breed: 'Hyline Brown / Lohmann Brown',
      description:
          'Egg-laying hens producing 280–320 eggs per year. '
          'Steady income from daily egg sales.',
      feedRequirements: 'Layer mash: 110–120g/bird/day. Must contain calcium (oyster shell/limestone).',
      housingRequirements: 'Deep litter or cage system. Nest boxes (1 per 4 hens). 16 hours light/day for maximum production.',
      breedingCycle: 'Start laying at 18–20 weeks. Peak production at 28–32 weeks. Laying cycle: 12–18 months.',
      averageWeight: '1.6–2.0kg',
      maturityAge: '18–20 weeks (point of lay)',
      productionOutput: 'Eggs: 280–320/year. Spent hens sold for meat at end of cycle.',
      commonDiseases: ['Newcastle Disease', 'Egg Drop Syndrome', 'Infectious Bronchitis', 'Marek\'s Disease'],
      vaccinations: ['Newcastle (every 3 months)', 'Marek\'s (Day 1)', 'Gumboro', 'Egg Drop Syndrome'],
      tips: [
        LivestockTip(title: 'Lighting', content: 'Provide 16 hours of light per day. Use a timer with low-watt bulbs. Never decrease light during laying period.'),
      ],
    ),

    // ─── Pigs ────────────────────────────────────────
    Livestock(
      id: 'lstock-009',
      name: 'Pigs',
      category: 'pigs',
      breed: 'Large White / Landrace / Crosses',
      description:
          'Fast-growing livestock with excellent feed conversion. '
          'Growing demand in urban and peri-urban areas. Can use kitchen waste.',
      feedRequirements: 'Pig grower: 2–3kg/day. Can supplement with kitchen waste, crop residues, '
          'brewery waste. Clean water essential.',
      housingRequirements: 'Concrete-floored pen with shade and wallow. Separate boar, sows, and growers. 2m²/pig.',
      breedingCycle: 'Gestation: 114 days. Litter size: 8–12 piglets. 2 litters/year possible.',
      averageWeight: 'Market weight: 90–110kg at 5–6 months',
      maturityAge: '5–6 months (slaughter), 8 months (breeding)',
      productionOutput: 'Meat: 72–78% dressing. Pork, bacon, sausages.',
      commonDiseases: ['African Swine Fever (ASF)', 'Swine Erysipelas', 'Internal Parasites', 'Mange'],
      vaccinations: ['Erysipelas (bi-annual)', 'Iron injection (piglets Day 3)'],
      tips: [
        LivestockTip(title: 'ASF Alert', content: 'African Swine Fever has NO vaccine and is 100% fatal. Strict biosecurity. No feeding swill from other farms.'),
        LivestockTip(title: 'Profitability', content: 'Pigs have the highest feed conversion of any livestock. 3kg feed = 1kg weight gain.'),
      ],
    ),

    // ─── Rabbits ─────────────────────────────────────
    Livestock(
      id: 'lstock-010',
      name: 'Rabbits',
      category: 'rabbits',
      breed: 'New Zealand White / Californian / Chinchilla',
      description:
          'Small-space, low-cost livestock. High reproduction rate. '
          'White meat is lean, healthy. Growing market in urban areas.',
      feedRequirements: 'Pellets + hay/grass. 100–150g pellets/day. Green vegetables as supplement.',
      housingRequirements: 'Wire cages raised off ground. 0.5m² per rabbit. Shade essential. Clean water always.',
      breedingCycle: 'Gestation: 31 days. Litter size: 6–10 kits. Can breed every 2 months.',
      averageWeight: '2.5–4.0kg at market age',
      maturityAge: '3–4 months (slaughter), 5 months (breeding)',
      productionOutput: 'Meat: 55–60% dressing. Skins for crafts. Manure for gardens.',
      commonDiseases: ['Coccidiosis', 'Pasteurellosis (Snuffles)', 'Ear Canker', 'Myxomatosis'],
      vaccinations: ['Myxomatosis (where available)', 'Coccidiosis prevention in water'],
      tips: [
        LivestockTip(title: 'Starter Livestock', content: 'Start with 1 buck and 3 does. Within 6 months you can have 50+ rabbits. Minimal space and capital needed.'),
      ],
    ),

    // ─── Fish ────────────────────────────────────────
    Livestock(
      id: 'lstock-011',
      name: 'Tilapia (Bream)',
      category: 'fish',
      breed: 'Nile Tilapia / Mozambique Tilapia',
      description:
          'Most popular freshwater fish in Zimbabwe. '
          'Pond culture growing rapidly. High protein, low cholesterol.',
      feedRequirements: 'Commercial fish pellets (32% protein) or farm-made feed. '
          '2–3% of body weight per day. Fertilize ponds for natural food.',
      housingRequirements: 'Earth ponds (minimum 200m²), concrete tanks, or cages in dams. '
          'Water depth 1–1.5m. Good water quality essential.',
      breedingCycle: 'Females breed every 6–8 weeks in warm months. Mouth brooders. '
          'Control breeding by mono-sex culture (all males grow faster).',
      averageWeight: '300–500g at harvest (6–9 months)',
      maturityAge: '6–9 months (market size)',
      productionOutput: '3–5 tonnes/hectare/year in ponds. Higher in intensive systems.',
      commonDiseases: ['Bacterial infections', 'Parasites (gill flukes)', 'Columnaris', 'Streptococcosis'],
      vaccinations: [],
      tips: [
        LivestockTip(title: 'Integrated Farming', content: 'Combine fish ponds with chicken houses — chicken manure fertilizes the pond, growing natural fish food (algae/plankton).'),
        LivestockTip(title: 'Water Quality', content: 'Test pH (6.5–8.5) and dissolved oxygen regularly. Morning fish gasping at surface = low oxygen. Add fresh water immediately.'),
      ],
    ),
  ];

  static const List<PestDisease> pestsDiseases = [
    // ─── Crop Pests ──────────────────────────────────
    PestDisease(
      id: 'pd-001',
      name: 'Fall Armyworm',
      type: 'pest',
      affects: 'crop',
      description: 'Invasive pest that devastates maize crops across Africa. '
          'Larvae feed in the whorl and on developing ears.',
      symptoms: 'Ragged holes in leaves, windowpane feeding, frass (sawdust-like droppings) in whorl, '
          'larvae visible feeding inside whorl.',
      treatment: 'Apply Bt-based biopesticides (Dipel, Thuricide) into whorl. '
          'Approved chemicals: emamectin benzoate, chlorantraniliprole. '
          'Apply early morning or late afternoon.',
      prevention: 'Early planting, crop rotation, intercrop with legumes, '
          'use push-pull technology (Desmodium border). Scout weekly from 2 weeks after emergence.',
      severity: 'critical',
      affectedCrops: ['Maize', 'Sorghum', 'Millet'],
    ),
    PestDisease(
      id: 'pd-002',
      name: 'Tuta absoluta',
      type: 'pest',
      affects: 'crop',
      description: 'South American tomato leaf miner that arrived in Zimbabwe in 2016. '
          'Can cause 80–100% crop loss if uncontrolled.',
      symptoms: 'Irregular mines/tunnels in leaves, pin-sized holes in fruit, '
          'larvae inside leaf tissue and fruit. Mines start whitish, turn brown.',
      treatment: 'Rotate insecticides: spinosad, emamectin benzoate, cyantraniliprole. '
          'Combine with pheromone traps (Delta traps with TUA-Optima lures).',
      prevention: 'Crop rotation (avoid solanaceae succession), remove crop residues, '
          'use pheromone traps for monitoring (5 traps/hectare). Trap catches >30/trap/week = spray threshold.',
      severity: 'critical',
      affectedCrops: ['Tomatoes', 'Peppers', 'Potatoes', 'Eggplant'],
    ),
    PestDisease(
      id: 'pd-003',
      name: 'Quelea Birds',
      type: 'pest',
      affects: 'crop',
      description: 'Red-billed quelea — the most destructive bird pest in Africa. '
          'Flocks of millions can destroy an entire field in hours.',
      symptoms: 'Stripped grain heads, damaged panicles, massive bird flocks descending on fields.',
      treatment: 'Community-level control through AGRITEX coordination. '
          'Report large roosts/nesting colonies to authorities.',
      prevention: 'Plant early with neighbors (synchronized planting). '
          'Use bird scarers, reflective tape, noise makers. '
          'Short-duration, compact-headed varieties reduce damage.',
      severity: 'high',
      affectedCrops: ['Sorghum', 'Millet', 'Wheat', 'Rice'],
    ),

    // ─── Crop Diseases ───────────────────────────────
    PestDisease(
      id: 'pd-004',
      name: 'Maize Streak Virus',
      type: 'disease',
      affects: 'crop',
      description: 'Transmitted by leafhoppers. Causes stunting and severe yield loss. '
          'Most important viral disease of maize in Africa.',
      symptoms: 'Pale yellow streaks along leaf veins, stunted growth, '
          'poor ear development, plants may be barren.',
      treatment: 'No cure once infected. Remove and destroy infected plants. '
          'Control leafhopper vectors with approved insecticides.',
      prevention: 'Plant MSV-resistant varieties (most modern hybrids have resistance). '
          'Control leafhopper populations. Avoid late planting.',
      severity: 'high',
      affectedCrops: ['Maize'],
    ),
    PestDisease(
      id: 'pd-005',
      name: 'Soybean Rust',
      type: 'disease',
      affects: 'crop',
      description: 'Fungal disease that can cause 50–80% yield loss. '
          'Spreads rapidly in warm, humid conditions.',
      symptoms: 'Small tan to dark brown lesions on undersides of leaves, '
          'premature defoliation, shriveled pods.',
      treatment: 'Triazole + strobilurin fungicides at R1–R3 growth stage. '
          'Two applications may be needed in severe cases.',
      prevention: 'Plant early to escape peak infection period. Use tolerant varieties. '
          'Scout from R1 (early flowering) stage.',
      severity: 'high',
      affectedCrops: ['Soya Beans'],
    ),

    // ─── Livestock Diseases ──────────────────────────
    PestDisease(
      id: 'pd-006',
      name: 'Theileriosis (January Disease)',
      type: 'disease',
      affects: 'livestock',
      description: 'The number one cattle killer in Zimbabwe, especially in communal areas. '
          'Caused by Theileria parva parasite transmitted by brown ear tick.',
      symptoms: 'High fever (41°C+), swollen lymph nodes (especially parotid), '
          'loss of appetite, labored breathing, nasal discharge, death within 10–14 days.',
      treatment: 'Buparvaquone (Butalex) injection if caught early. Treatment is expensive '
          'and not always effective in advanced cases. Supportive therapy with fluids.',
      prevention: 'Regular dipping every 14 days (especially Oct–April). '
          'Hand-spray ears between dips. Immunization available in some areas (Muguga cocktail).',
      severity: 'critical',
      affectedLivestock: ['Cattle'],
    ),
    PestDisease(
      id: 'pd-007',
      name: 'Newcastle Disease',
      type: 'disease',
      affects: 'livestock',
      description: 'Highly contagious viral disease that kills 70–100% of unvaccinated flocks. '
          'The most important poultry disease in Africa.',
      symptoms: 'Greenish diarrhea, coughing/sneezing, twisted neck (torticollis), '
          'drooping wings, drop in egg production, sudden death.',
      treatment: 'No cure. Supportive care only. Cull severely affected birds. '
          'Disinfect housing thoroughly.',
      prevention: 'Vaccinate with Lasota (I-2 strain) in drinking water every 3 months. '
          'Keep new birds quarantined for 2 weeks before mixing with flock.',
      severity: 'critical',
      affectedLivestock: ['Poultry'],
    ),
    PestDisease(
      id: 'pd-008',
      name: 'African Swine Fever',
      type: 'disease',
      affects: 'livestock',
      description: 'Highly contagious, always fatal viral disease of pigs. '
          'No vaccine exists. Major constraint to pig production in Africa.',
      symptoms: 'High fever, purple discoloration of ears/snout/belly, '
          'bloody diarrhea, vomiting, death within 2–7 days.',
      treatment: 'No treatment. 100% mortality. Must report to veterinary authorities. '
          'Infected and in-contact pigs must be destroyed.',
      prevention: 'Strict biosecurity: No visitors, no feeding swill from other farms, '
          'double fencing, footbaths. Do NOT buy pigs from unknown sources.',
      severity: 'critical',
      affectedLivestock: ['Pigs'],
    ),
    PestDisease(
      id: 'pd-009',
      name: 'Foot and Mouth Disease',
      type: 'disease',
      affects: 'livestock',
      description: 'Highly contagious viral disease of cloven-hoofed animals. '
          'Zimbabwe maintains strict control zones. Outbreaks restrict beef exports.',
      symptoms: 'Blisters on mouth/tongue/feet, excessive drooling, lameness, '
          'reluctance to eat, drop in milk production.',
      treatment: 'No specific treatment. Supportive care: soft feed, clean water, '
          'foot baths. Report immediately to veterinary services.',
      prevention: 'Vaccination in endemic areas (government program). '
          'Movement controls. Do not move cattle without permits.',
      severity: 'critical',
      affectedLivestock: ['Cattle', 'Goats', 'Pigs'],
    ),
    PestDisease(
      id: 'pd-010',
      name: 'Internal Parasites (Worms)',
      type: 'disease',
      affects: 'livestock',
      description: 'Roundworms, tapeworms, and flukes affecting all livestock. '
          'Causes poor growth, weight loss, and death in severe cases.',
      symptoms: 'Weight loss despite eating, rough coat, pot belly, '
          'diarrhea, anemia (pale membranes), bottle jaw (swelling under chin).',
      treatment: 'Broad-spectrum anthelmintics: albendazole, ivermectin, levamisole. '
          'Treat based on fecal egg counts. Rotate drug classes.',
      prevention: 'Rotational grazing, pasture rest periods, strategic deworming '
          '(start of rains + mid wet season). FAMACHA scoring for sheep & goats.',
      severity: 'high',
      affectedLivestock: ['Cattle', 'Goats', 'Sheep', 'Pigs'],
    ),
  ];
}
