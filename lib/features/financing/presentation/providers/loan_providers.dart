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

final loanOffersProvider = FutureProvider<List<LoanOffer>>((ref) async {
  final repo = ref.watch(loanRepositoryImplProvider);
  return repo.getLoanOffers();
});
