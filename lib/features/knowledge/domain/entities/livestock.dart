/// Represents a livestock type in the knowledge base.
class Livestock {
  final String id;
  final String name;
  final String category; // cattle, goats, poultry, pigs, rabbits, fish
  final String breed;
  final String description;
  final String feedRequirements;
  final String housingRequirements;
  final String breedingCycle;
  final String averageWeight;
  final String maturityAge;
  final String productionOutput; // milk, eggs, meat yield
  final List<String> commonDiseases;
  final List<String> vaccinations;
  final String imageAsset;
  final List<LivestockTip> tips;

  const Livestock({
    required this.id,
    required this.name,
    required this.category,
    required this.breed,
    required this.description,
    required this.feedRequirements,
    required this.housingRequirements,
    required this.breedingCycle,
    required this.averageWeight,
    required this.maturityAge,
    required this.productionOutput,
    required this.commonDiseases,
    required this.vaccinations,
    this.imageAsset = '',
    this.tips = const [],
  });
}

class LivestockTip {
  final String title;
  final String content;

  const LivestockTip({required this.title, required this.content});
}
