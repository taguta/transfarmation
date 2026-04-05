class TraceabilityBatch {
  final String id;
  final String crop;
  final DateTime harvestDate;
  final String weight;
  final String quality;
  final String farmName;

  const TraceabilityBatch({
    required this.id,
    required this.crop,
    required this.harvestDate,
    required this.weight,
    required this.quality,
    required this.farmName,
  });
}
