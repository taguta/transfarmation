/// Pest or disease entry in the knowledge base.
class PestDisease {
  final String id;
  final String name;
  final String type; // pest, disease
  final String affects; // crop, livestock, both
  final String description;
  final String symptoms;
  final String treatment;
  final String prevention;
  final String severity; // low, medium, high, critical
  final List<String> affectedCrops;
  final List<String> affectedLivestock;
  final String imageAsset;

  const PestDisease({
    required this.id,
    required this.name,
    required this.type,
    required this.affects,
    required this.description,
    required this.symptoms,
    required this.treatment,
    required this.prevention,
    required this.severity,
    this.affectedCrops = const [],
    this.affectedLivestock = const [],
    this.imageAsset = '',
  });
}
