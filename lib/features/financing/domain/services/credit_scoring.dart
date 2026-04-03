import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Rule-based credit scoring engine — Phase 1 (per spec section 6).
///
/// Score range: 0–100.
/// Factors: farm size, crop type, historical repayment, input usage, farming type.
class CreditScore {
  final int score;
  final String grade;
  final Map<String, int> breakdown;

  const CreditScore({
    required this.score,
    required this.grade,
    required this.breakdown,
  });

  static CreditScore calculate({
    required double farmSize,
    required String cropType,
    required String farmingType,
    required int loansCompleted,
    required int loansDefaulted,
    required double totalRepaid,
  }) {
    final breakdown = <String, int>{};

    // Farm size score (0–20)
    final farmScore =
        farmSize >= 20
            ? 20
            : farmSize >= 10
            ? 16
            : farmSize >= 5
            ? 12
            : farmSize >= 2
            ? 8
            : 4;
    breakdown['Farm Size'] = farmScore;

    // Crop type score (0–15) — cash crops score higher
    final cropScore = switch (cropType.toLowerCase()) {
      'tobacco' => 15,
      'soya beans' || 'soya' => 14,
      'cotton' => 13,
      'maize' => 12,
      'wheat' => 12,
      'sugar cane' => 11,
      'groundnuts' => 10,
      'sunflower' => 10,
      _ => 8,
    };
    breakdown['Crop Type'] = cropScore;

    // Farming type (0–10)
    final farmingScore = switch (farmingType.toLowerCase()) {
      'irrigated' => 10,
      'mixed' => 7,
      'rainfed' => 5,
      _ => 3,
    };
    breakdown['Farming Method'] = farmingScore;

    // Repayment history (0–35)
    int repaymentScore;
    if (loansCompleted == 0 && loansDefaulted == 0) {
      repaymentScore = 15; // No history — neutral
    } else {
      final total = loansCompleted + loansDefaulted;
      final successRate = loansCompleted / total;
      repaymentScore = (successRate * 35).round();
    }
    breakdown['Repayment History'] = repaymentScore;

    // Total repaid volume bonus (0–20)
    final volumeScore =
        totalRepaid >= 5000
            ? 20
            : totalRepaid >= 2000
            ? 16
            : totalRepaid >= 1000
            ? 12
            : totalRepaid >= 500
            ? 8
            : totalRepaid > 0
            ? 4
            : 0;
    breakdown['Repayment Volume'] = volumeScore;

    final total = breakdown.values.fold(0, (a, b) => a + b);

    final grade =
        total >= 80
            ? 'A'
            : total >= 65
            ? 'B'
            : total >= 50
            ? 'C'
            : total >= 35
            ? 'D'
            : 'E';

    return CreditScore(score: total, grade: grade, breakdown: breakdown);
  }
}

/// Provides the current farmer's credit score.
final creditScoreProvider = Provider<CreditScore>((ref) {
  return CreditScore.calculate(
    farmSize: 12,
    cropType: 'Maize',
    farmingType: 'Rainfed',
    loansCompleted: 1,
    loansDefaulted: 0,
    totalRepaid: 800,
  );
});
