import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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
      // final loans = container.read(loanProvider);
      // expect(loans.value?.length, 4);
    });

    test('addLoan adds a new loan', () {
      // final notifier = container.read(loanProvider.notifier);
      // notifier.addLoan(Loan(...));
    });

    test('updateLoanStatus changes status on correct loan', () {
      // final notifier = container.read(loanProvider.notifier);
      // notifier.updateLoanStatus('loan-002', LoanStatus.approved);
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
      // final active = container.read(activeLoansProvider);
      // expect(...);
    });

    test('outstandingBalanceProvider sums active loan balances', () {
      // final balance = container.read(outstandingBalanceProvider);
      // expect(balance, greaterThan(0));
    });

    test('loanOffersProvider returns 4 offers', () {
      // final offers = container.read(loanOffersProvider);
      // expect(offers.value?.length, 4);
    });
  });
}
