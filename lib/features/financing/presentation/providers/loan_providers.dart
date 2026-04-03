import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/loan.dart';

import '../../../../core/providers/data_providers.dart';

final loanProvider = FutureProvider<List<Loan>>((ref) async {
  final repo = ref.watch(loanRepositoryImplProvider);
  return await repo.getLoans('farmer-001');
});

/// Active loans (approved, disbursed)
final activeLoansProvider = Provider<List<Loan>>((ref) {
  final loansAsync = ref.watch(loanProvider);
  final loans = loansAsync.value ?? [];
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
