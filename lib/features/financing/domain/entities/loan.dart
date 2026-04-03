enum LoanStatus { draft, pending, approved, rejected, disbursed, completed }

class Loan {
  final String id;
  final String farmerId;
  final double amount;
  final LoanStatus status;
  final DateTime createdAt;
  final bool isSynced;
  final String? farmName;
  final String? cropType;
  final String? purpose;
  final String? repaymentPeriod;
  final double? farmSize;
  final double amountRepaid;
  final String? lenderName;

  Loan({
    required this.id,
    required this.farmerId,
    required this.amount,
    required this.status,
    required this.createdAt,
    required this.isSynced,
    this.farmName,
    this.cropType,
    this.purpose,
    this.repaymentPeriod,
    this.farmSize,
    this.amountRepaid = 0,
    this.lenderName,
  });

  double get repaidPercent =>
      amount > 0 ? (amountRepaid / amount).clamp(0, 1) : 0;
  double get outstanding => amount - amountRepaid;

  Loan copyWith({
    String? id,
    String? farmerId,
    double? amount,
    LoanStatus? status,
    DateTime? createdAt,
    bool? isSynced,
    String? farmName,
    String? cropType,
    String? purpose,
    String? repaymentPeriod,
    double? farmSize,
    double? amountRepaid,
    String? lenderName,
  }) {
    return Loan(
      id: id ?? this.id,
      farmerId: farmerId ?? this.farmerId,
      amount: amount ?? this.amount,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      isSynced: isSynced ?? this.isSynced,
      farmName: farmName ?? this.farmName,
      cropType: cropType ?? this.cropType,
      purpose: purpose ?? this.purpose,
      repaymentPeriod: repaymentPeriod ?? this.repaymentPeriod,
      farmSize: farmSize ?? this.farmSize,
      amountRepaid: amountRepaid ?? this.amountRepaid,
      lenderName: lenderName ?? this.lenderName,
    );
  }
}

class LoanOffer {
  final String id;
  final String lenderName;
  final double interestRate;
  final double amount;
  final String repaymentPeriod;
  final double monthlyPayment;
  final String? conditions;
  final bool isRecommended;

  const LoanOffer({
    required this.id,
    required this.lenderName,
    required this.interestRate,
    required this.amount,
    required this.repaymentPeriod,
    required this.monthlyPayment,
    this.conditions,
    this.isRecommended = false,
  });
}

class Repayment {
  final String id;
  final String loanId;
  final double amount;
  final DateTime date;
  final bool isPaid;

  const Repayment({
    required this.id,
    required this.loanId,
    required this.amount,
    required this.date,
    required this.isPaid,
  });
}
