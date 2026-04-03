/// Represents a crop in the knowledge base.
class Crop {
  final String id;
  final String name;
  final String category; // grain, cash_crop, horticulture, indigenous
  final String scientificName;
  final String description;
  final String plantingSeason;
  final String harvestSeason;
  final String waterRequirements;
  final String soilType;
  final List<String> regions; // agro-ecological regions I-V
  final String growthDuration;
  final String spacing;
  final String yieldPerHectare;
  final List<String> commonPests;
  final List<String> commonDiseases;
  final String imageAsset;
  final List<CropTip> tips;

  const Crop({
    required this.id,
    required this.name,
    required this.category,
    required this.scientificName,
    required this.description,
    required this.plantingSeason,
    required this.harvestSeason,
    required this.waterRequirements,
    required this.soilType,
    required this.regions,
    required this.growthDuration,
    required this.spacing,
    required this.yieldPerHectare,
    required this.commonPests,
    required this.commonDiseases,
    this.imageAsset = '',
    this.tips = const [],
  });
}

class CropTip {
  final String title;
  final String content;

  const CropTip({required this.title, required this.content});
}
