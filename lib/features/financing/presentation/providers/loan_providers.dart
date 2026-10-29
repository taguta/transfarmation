import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/loan.dart';

import '../../../../core/providers/data_providers.dart';
import '../../../auth/presentation/providers/auth_providers.dart';

final loanProvider = FutureProvider<List<Loan>>((ref) async {
  ref.watch(syncTickProvider);
  final repo = ref.watch(loanRepositoryImplProvider);
  return await repo.getLoans(ref.watch(activeFarmerIdProvider));
});

/// Payments recorded against one loan, newest first.
final loanPaymentsProvider =
    FutureProvider.family<List<LoanPayment>, String>((ref, loanId) async {
  ref.watch(syncTickProvider);
  return ref.watch(loanRepositoryImplProvider).getPayments(loanId);
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
  ref.watch(syncTickProvider);
  final repo = ref.watch(loanRepositoryImplProvider);
  return repo.getLoanOffers();
});
