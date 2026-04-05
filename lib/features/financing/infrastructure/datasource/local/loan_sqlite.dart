import 'package:sqflite/sqflite.dart';
import '../../../domain/entities/loan.dart';

class LoanLocalDataSource {
  final Database db;

  LoanLocalDataSource(this.db);

  Future<void> saveLoan(Loan loan) async {
    await db.insert('loans', {
      'id': loan.id,
      'farmerId': loan.farmerId,
      'amount': loan.amount,
      'status': loan.status.name,
      'createdAt': loan.createdAt.toIso8601String(),
      'isSynced': loan.isSynced ? 1 : 0,
    }, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<List<Loan>> getLoans(String farmerId) async {
    final data = await db.query(
      'loans',
      where: 'farmerId = ?',
      whereArgs: [farmerId],
    );
    return data
        .map(
          (e) => Loan(
            id: e['id'] as String,
            farmerId: e['farmerId'] as String,
            amount: e['amount'] as double,
            status: LoanStatus.values.firstWhere((s) => s.name == e['status']),
            createdAt: DateTime.parse(e['createdAt'] as String),
            isSynced: (e['isSynced'] as int) == 1,
          ),
        )
        .toList();
  }

  Future<List<LoanOffer>> getLoanOffers() async {
    final data = await db.query('loan_offers');
    
    if (data.isEmpty) {
      return [
        LoanOffer(
          id: 'lo1',
          lenderName: 'AgriBank ZW',
          interestRate: 8.5,
          amount: 5000.0,
          repaymentPeriod: '12 Months',
          monthlyPayment: 452.0,
          conditions: 'Requires 2 years farming history. Equipment collateral.',
          isRecommended: true,
        ),
        LoanOffer(
          id: 'lo2',
          lenderName: 'MicroFinance Coop',
          interestRate: 12.0,
          amount: 1500.0,
          repaymentPeriod: '6 Months',
          monthlyPayment: 268.0,
          conditions: 'No collateral. Fast approval.',
          isRecommended: false,
        ),
      ];
    }

    return data
        .map(
          (e) => LoanOffer(
            id: e['id'] as String,
            lenderName: e['lenderName'] as String,
            interestRate: e['interestRate'] as double,
            amount: e['amount'] as double,
            repaymentPeriod: e['repaymentPeriod'] as String,
            monthlyPayment: e['monthlyPayment'] as double,
            conditions: e['conditions'] as String,
            isRecommended: (e['isRecommended'] as int?) == 1,
          ),
        )
        .toList();
  }
}
