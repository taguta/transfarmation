import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:transfarmation/features/financing/domain/entities/loan.dart';
import 'package:transfarmation/features/financing/presentation/providers/loan_providers.dart';
import 'package:transfarmation/features/financing/infrastructure/repositories/loan_repository_impl.dart';
import 'package:transfarmation/core/providers/data_providers.dart';
import 'package:sqflite/sqflite.dart';
import 'package:transfarmation/features/financing/infrastructure/datasource/local/loan_sqlite.dart';
import 'package:transfarmation/features/financing/infrastructure/datasource/remote/loan_firestore.dart';

class FakeLoanRepository implements LoanRepositoryImpl {
  @override
  final LoanLocalDataSource local = null as dynamic;
  @override
  final LoanRemoteDataSource remote = null as dynamic;
  @override
  final Database db = null as dynamic;

  @override
  Future<void> applyLoan(Loan loan) async {}

  @override
  Future<List<Loan>> getLoans(String farmerId) async {
    return [
      Loan(id: 'loan-001', farmerId: 'farmer-001', cropType: 'Maize', amount: 500, amountRepaid: 250, status: LoanStatus.disbursed, createdAt: DateTime.now(), isSynced: true),
      Loan(id: 'loan-002', farmerId: 'farmer-001', cropType: 'Soy', amount: 1000, amountRepaid: 0, status: LoanStatus.approved, createdAt: DateTime.now(), isSynced: true),
    ];
  }

  @override
  Future<List<LoanOffer>> getLoanOffers() async {
    return [
      LoanOffer(id: 'off-1', lenderName: 'AgriBank', interestRate: 5, amount: 1000, repaymentPeriod: '12 months', monthlyPayment: 85, conditions: 'Good credit'),
    ];
  }
}

void main() {
  group('Loan Providers Tests', () {
    test('loanProvider fetches loans correctly', () async {
      final container = ProviderContainer(
        overrides: [
          loanRepositoryImplProvider.overrideWith((ref) => FakeLoanRepository()),
        ],
      );
      
      final loans = await container.read(loanProvider.future);
      expect(loans.length, 2);
    });

    test('activeLoansProvider filters approved and disbursed loans', () async {
      final container = ProviderContainer(
        overrides: [
          loanRepositoryImplProvider.overrideWith((ref) => FakeLoanRepository()),
        ],
      );
      
      await container.read(loanProvider.future);
      final active = container.read(activeLoansProvider);
      
      expect(active.length, 2);
    });

    test('outstandingBalanceProvider sums active loan balances correctly', () async {
      final container = ProviderContainer(
        overrides: [
          loanRepositoryImplProvider.overrideWith((ref) => FakeLoanRepository()),
        ],
      );
      
      await container.read(loanProvider.future);
      final total = container.read(outstandingBalanceProvider);
      
      expect(total, 1250); // 250 + 1000
    });

    test('loanOffersProvider fetches offers correctly', () async {
      final container = ProviderContainer(
        overrides: [
          loanRepositoryImplProvider.overrideWith((ref) => FakeLoanRepository()),
        ],
      );
      
      final offers = await container.read(loanOffersProvider.future);
      expect(offers.length, 1);
      expect(offers.first.lenderName, 'AgriBank');
    });
  });
}
