import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:transfarmation/features/financing/presentation/providers/loan_providers.dart';
import 'package:transfarmation/features/financing/domain/entities/loan.dart';

void main() {
  group('LoanNotifier', () {
    late ProviderContainer container;

    setUp(() {
      container = ProviderContainer();
    });

    tearDown(() {
      container.dispose();
    });

    test('initial state has 4 mock loans', () {
      final loans = container.read(loanProvider);
      expect(loans.length, 4);
    });

    test('addLoan adds a new loan', () {
      final notifier = container.read(loanProvider.notifier);
      notifier.addLoan(Loan(
        id: 'loan-new',
        farmerId: 'farmer-001',
        amount: 500,
        status: LoanStatus.pending,
        createdAt: DateTime.now(),
        isSynced: false,
      ));

      final loans = container.read(loanProvider);
      expect(loans.length, 5);
    });

    test('updateLoanStatus changes status on correct loan', () {
      final notifier = container.read(loanProvider.notifier);
      notifier.updateLoanStatus('loan-002', LoanStatus.approved);

      final loans = container.read(loanProvider);
      final updated = loans.firstWhere((l) => l.id == 'loan-002');
      expect(updated.status, LoanStatus.approved);
    });
  });

  group('Derived providers', () {
    late ProviderContainer container;

    setUp(() {
      container = ProviderContainer();
    });

    tearDown(() {
      container.dispose();
    });

    test('activeLoansProvider returns approved/disbursed loans', () {
      final active = container.read(activeLoansProvider);
      expect(
        active.every(
          (l) =>
              l.status == LoanStatus.approved ||
              l.status == LoanStatus.disbursed,
        ),
        true,
      );
    });

    test('outstandingBalanceProvider sums active loan balances', () {
      final balance = container.read(outstandingBalanceProvider);
      expect(balance, greaterThan(0));
    });

    test('loanOffersProvider returns 4 offers', () {
      final offers = container.read(loanOffersProvider);
      expect(offers.length, 4);
    });
  });
}
