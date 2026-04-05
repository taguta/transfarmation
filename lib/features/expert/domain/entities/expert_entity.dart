class ExpertEntity {
  final String id;
  final String name;
  final String specialization; // e.g., 'Soil Health', 'Crop Diseases'
  final double rating;
  final int reviewsCount;
  final double consultationFee;
  final bool isAvailable;

  const ExpertEntity({
    required this.id,
    required this.name,
    required this.specialization,
    required this.rating,
    required this.reviewsCount,
    required this.consultationFee,
    required this.isAvailable,
  });
}
