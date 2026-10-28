import '../../financing/domain/services/credit_scoring.dart';

/// A farmer's loan application as a lender sees it.
class LoanApplication {
  final String id;
  final String farmerId;
  final double amount;
  final String status; // pending | approved | rejected
  final DateTime createdAt;
  final String farmName;
  final String province;
  final double? farmSize;
  final String cropType;
  final String farmingType;
  final String purpose;
  final String repaymentPeriod;
  final Map<String, dynamic>? plan; // shared with the farmer's consent
  final String? lenderName;
  final String? decisionNote;

  const LoanApplication({
    required this.id,
    required this.farmerId,
    required this.amount,
    required this.status,
    required this.createdAt,
    required this.farmName,
    required this.province,
    required this.farmSize,
    required this.cropType,
    required this.farmingType,
    required this.purpose,
    required this.repaymentPeriod,
    this.plan,
    this.lenderName,
    this.decisionNote,
  });

  bool get isPending => status == 'pending';

  /// Indicative only: the platform has no repayment history for a first-time
  /// borrower, so history is scored as "none".
  CreditScore get indicativeScore => CreditScore.calculate(
    farmSize: farmSize ?? 0,
    cropType: cropType,
    farmingType: farmingType,
    loansCompleted: 0,
    loansDefaulted: 0,
    totalRepaid: 0,
  );

  factory LoanApplication.fromMap(String id, Map<String, dynamic> d) =>
      LoanApplication(
        id: id,
        farmerId: d['farmerId'] as String? ?? '',
        amount: (d['amount'] as num?)?.toDouble() ?? 0,
        status: d['status'] as String? ?? 'pending',
        createdAt: DateTime.tryParse(d['createdAt'] as String? ?? '') ?? DateTime.now(),
        farmName: d['farmName'] as String? ?? '',
        province: d['province'] as String? ?? '',
        farmSize: (d['farmSize'] as num?)?.toDouble(),
        cropType: d['cropType'] as String? ?? '',
        farmingType: d['farmingType'] as String? ?? '',
        purpose: d['purpose'] as String? ?? '',
        repaymentPeriod: d['repaymentPeriod'] as String? ?? '',
        plan: d['planSummary'] == null ? null : Map<String, dynamic>.from(d['planSummary'] as Map),
        lenderName: d['lenderName'] as String?,
        decisionNote: d['decisionNote'] as String?,
      );
}
