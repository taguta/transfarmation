import 'package:flutter_test/flutter_test.dart';
import 'package:transfarmation/features/financing/domain/entities/loan.dart';

void main() {
  group('Loan entity', () {
    test('creates loan with required fields', () {
      final loan = Loan(
        id: 'loan-001',
        farmerId: 'farmer-001',
        amount: 1200,
        status: LoanStatus.pending,
        createdAt: DateTime(2026, 1, 15),
        isSynced: false,
      );

      expect(loan.id, 'loan-001');
      expect(loan.amount, 1200);
      expect(loan.status, LoanStatus.pending);
      expect(loan.isSynced, false);
    });

    test('outstanding calculated correctly', () {
      final loan = Loan(
        id: 'loan-001',
        farmerId: 'farmer-001',
        amount: 1200,
        status: LoanStatus.approved,
        createdAt: DateTime(2026, 1, 15),
        isSynced: true,
        amountRepaid: 480,
      );

      expect(loan.outstanding, 720);
    });

    test('repaid percent is correct', () {
      final loan = Loan(
        id: 'loan-001',
        farmerId: 'farmer-001',
        amount: 1000,
        status: LoanStatus.approved,
        createdAt: DateTime(2026, 1, 15),
        isSynced: true,
        amountRepaid: 250,
      );

      expect(loan.repaidPercent, 0.25);
    });
  });

  group('LoanStatus', () {
    test('all statuses are defined', () {
      expect(LoanStatus.values, contains(LoanStatus.pending));
      expect(LoanStatus.values, contains(LoanStatus.approved));
      expect(LoanStatus.values, contains(LoanStatus.rejected));
      expect(LoanStatus.values, contains(LoanStatus.completed));
    });
  });
}
