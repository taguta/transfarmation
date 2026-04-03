/// A farm input product (seeds, fertilizer, chemicals, equipment).
class FarmInput {
  final String id;
  final String name;
  final String category; // seeds, fertilizer, chemicals, equipment, feed
  final String supplier;
  final String description;
  final double price;
  final String unit; // kg, bag, litre, each
  final double? bulkPrice; // price for group/cooperative buying
  final int? bulkMinQuantity;
  final bool isVerified;
  final bool inStock;
  final String? certificationCode; // QR verification code
  final String? imageAsset;

  const FarmInput({
    required this.id,
    required this.name,
    required this.category,
    required this.supplier,
    required this.description,
    required this.price,
    required this.unit,
    this.bulkPrice,
    this.bulkMinQuantity,
    this.isVerified = false,
    this.inStock = true,
    this.certificationCode,
    this.imageAsset,
  });

  double get bulkDiscount =>
      bulkPrice != null ? ((price - bulkPrice!) / price * 100) : 0;
}

/// A government subsidy program.
class SubsidyProgram {
  final String id;
  final String name;
  final String provider; // Government, NGO, etc.
  final String description;
  final String eligibility;
  final String applicationDeadline;
  final String status; // open, closed, pending_results
  final List<String> coveredInputs;
  final double? maxAmount;
  final String? applicationUrl;

  const SubsidyProgram({
    required this.id,
    required this.name,
    required this.provider,
    required this.description,
    required this.eligibility,
    required this.applicationDeadline,
    required this.status,
    required this.coveredInputs,
    this.maxAmount,
    this.applicationUrl,
  });
}

/// Tracks a farmer's subsidy application.
class SubsidyApplication {
  final String id;
  final String programId;
  final String programName;
  final String status; // applied, under_review, approved, rejected, disbursed
  final DateTime appliedDate;
  final double? amountApproved;
  final String? notes;

  const SubsidyApplication({
    required this.id,
    required this.programId,
    required this.programName,
    required this.status,
    required this.appliedDate,
    this.amountApproved,
    this.notes,
  });
}
