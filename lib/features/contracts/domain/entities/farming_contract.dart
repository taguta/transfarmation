/// A contract farming opportunity (buyer-farmer matching).
class FarmingContract {
  final String id;
  final String buyerName;
  final String buyerType; // processor, exporter, retailer, government
  final String commodity;
  final double pricePerUnit;
  final String unit;
  final int minQuantity; // minimum commitment
  final String season;
  final String region;
  final List<String> requirements; // quality specs, certifications
  final List<String> buyerProvides; // inputs, extension, transport
  final DateTime deadline;
  final String status; // open, applied, accepted, active, completed

  const FarmingContract({
    required this.id,
    required this.buyerName,
    required this.buyerType,
    required this.commodity,
    required this.pricePerUnit,
    required this.unit,
    required this.minQuantity,
    required this.season,
    required this.region,
    this.requirements = const [],
    this.buyerProvides = const [],
    required this.deadline,
    required this.status,
  });
}
