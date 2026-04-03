import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/loan.dart';

/// MVP mock loan data provider — simulates local loan state.
class LoanNotifier extends Notifier<List<Loan>> {
  @override
  List<Loan> build() => _mockLoans;

  void addLoan(Loan loan) {
    state = [...state, loan];
  }

  void updateLoanStatus(String id, LoanStatus status) {
    state = [
      for (final loan in state)
        if (loan.id == id) loan.copyWith(status: status) else loan,
    ];
  }

  static final List<Loan> _mockLoans = [
    Loan(
      id: 'loan-001',
      farmerId: 'farmer-001',
      amount: 1200,
      status: LoanStatus.approved,
      createdAt: DateTime(2026, 1, 15),
      isSynced: true,
      farmName: 'Moyo Family Farm',
      cropType: 'Maize',
      purpose: 'Input Purchase',
      repaymentPeriod: '6 months',
      farmSize: 12,
      amountRepaid: 480,
      lenderName: 'AgriFinance ZW',
    ),
    Loan(
      id: 'loan-002',
      farmerId: 'farmer-001',
      amount: 3500,
      status: LoanStatus.pending,
      createdAt: DateTime(2026, 3, 1),
      isSynced: true,
      farmName: 'Moyo Family Farm',
      cropType: 'Soya Beans',
      purpose: 'Irrigation',
      repaymentPeriod: '12 months',
      farmSize: 12,
      amountRepaid: 0,
      lenderName: 'FarmFund Africa',
    ),
    Loan(
      id: 'loan-003',
      farmerId: 'farmer-001',
      amount: 800,
      status: LoanStatus.completed,
      createdAt: DateTime(2025, 11, 1),
      isSynced: true,
      farmName: 'Moyo Family Farm',
      cropType: 'Soya Beans',
      purpose: 'Input Purchase',
      repaymentPeriod: '6 months',
      farmSize: 12,
      amountRepaid: 800,
      lenderName: 'ZimAgri Micro',
    ),
    Loan(
      id: 'loan-004',
      farmerId: 'farmer-001',
      amount: 450,
      status: LoanStatus.rejected,
      createdAt: DateTime(2025, 10, 10),
      isSynced: true,
      farmName: 'Moyo Family Farm',
      cropType: 'Maize',
      purpose: 'Equipment',
      repaymentPeriod: '3 months',
      farmSize: 12,
      amountRepaid: 0,
      lenderName: 'AgriFinance ZW',
    ),
  ];
}

final loanProvider = NotifierProvider<LoanNotifier, List<Loan>>(
  LoanNotifier.new,
);

/// Active loans (approved, disbursed)
final activeLoansProvider = Provider<List<Loan>>((ref) {
  final loans = ref.watch(loanProvider);
  return loans
      .where(
        (l) =>
            l.status == LoanStatus.approved || l.status == LoanStatus.disbursed,
      )
      .toList();
});

/// Total outstanding balance
final outstandingBalanceProvider = Provider<double>((ref) {
  final active = ref.watch(activeLoansProvider);
  return active.fold(0, (sum, l) => sum + l.outstanding);
});

/// Mock loan offers for comparison screen
final loanOffersProvider = Provider<List<LoanOffer>>((ref) {
  return const [
    LoanOffer(
      id: 'offer-001',
      lenderName: 'AgriFinance ZW',
      interestRate: 12.0,
      amount: 1500,
      repaymentPeriod: '6 months',
      monthlyPayment: 280,
      conditions: 'Must have farm >5 ha',
      isRecommended: true,
    ),
    LoanOffer(
      id: 'offer-002',
      lenderName: 'FarmFund Africa',
      interestRate: 15.0,
      amount: 1500,
      repaymentPeriod: '6 months',
      monthlyPayment: 293,
      conditions: 'First-time borrowers welcome',
    ),
    LoanOffer(
      id: 'offer-003',
      lenderName: 'ZimAgri Micro',
      interestRate: 18.0,
      amount: 1500,
      repaymentPeriod: '6 months',
      monthlyPayment: 308,
      conditions: 'No collateral required',
    ),
    LoanOffer(
      id: 'offer-004',
      lenderName: 'GreenLeaf Capital',
      interestRate: 10.5,
      amount: 1500,
      repaymentPeriod: '12 months',
      monthlyPayment: 147,
      conditions: 'Credit score > 65 required',
    ),
  ];
});
