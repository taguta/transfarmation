import 'dart:convert';
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
      'farmName': loan.farmName,
      'province': loan.province,
      'farmSize': loan.farmSize,
      'cropType': loan.cropType,
      'farmingType': loan.farmingType,
      'purpose': loan.purpose,
      'repaymentPeriod': loan.repaymentPeriod,
      'amountRepaid': loan.amountRepaid,
      'lenderName': loan.lenderName,
      'decisionNote': loan.decisionNote,
      'planSummary': loan.planSummary == null ? null : jsonEncode(loan.planSummary),
    }, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<List<Loan>> getLoans(String farmerId) async {
    final data = await db.query(
      'loans',
      where: 'farmerId = ?',
      whereArgs: [farmerId],
    );
    // What has been repaid is the sum of the recorded payments.
    final sums = {
      for (final r in await db.rawQuery(
          'SELECT loanId, SUM(amount) AS paid FROM loan_payments WHERE farmerId = ? GROUP BY loanId',
          [farmerId]))
        r['loanId'] as String: (r['paid'] as num).toDouble(),
    };
    return data
        .map(
          (e) => Loan(
            id: e['id'] as String,
            farmerId: e['farmerId'] as String,
            amount: e['amount'] as double,
            status: LoanStatus.values.firstWhere((s) => s.name == e['status']),
            createdAt: DateTime.parse(e['createdAt'] as String),
            isSynced: (e['isSynced'] as int) == 1,
            farmName: e['farmName'] as String?,
            province: e['province'] as String?,
            farmSize: (e['farmSize'] as num?)?.toDouble(),
            cropType: e['cropType'] as String?,
            farmingType: e['farmingType'] as String?,
            purpose: e['purpose'] as String?,
            repaymentPeriod: e['repaymentPeriod'] as String?,
            amountRepaid: sums[e['id'] as String] ?? 0,
            lenderName: e['lenderName'] as String?,
            decisionNote: e['decisionNote'] as String?,
            planSummary: e['planSummary'] == null
                ? null
                : Map<String, dynamic>.from(jsonDecode(e['planSummary'] as String) as Map),
          ),
        )
        .toList();
  }

  Future<void> savePayment(LoanPayment p) async {
    await db.insert('loan_payments', {
      'id': p.id,
      'loanId': p.loanId,
      'farmerId': p.farmerId,
      'amount': p.amount,
      'date': p.date.toIso8601String(),
      'method': p.method,
      'isSynced': p.isSynced ? 1 : 0,
    }, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<List<LoanPayment>> getPayments(String loanId) async {
    final rows = await db.query('loan_payments',
        where: 'loanId = ?', whereArgs: [loanId], orderBy: 'date DESC');
    return [
      for (final e in rows)
        LoanPayment(
          id: e['id'] as String,
          loanId: e['loanId'] as String,
          farmerId: e['farmerId'] as String? ?? '',
          amount: (e['amount'] as num).toDouble(),
          date: DateTime.parse(e['date'] as String),
          method: e['method'] as String? ?? '',
          isSynced: (e['isSynced'] as int?) == 1,
        ),
    ];
  }

  Future<List<LoanOffer>> getLoanOffers() async {
    final data = await db.query('loan_offers', orderBy: 'interestRate ASC');
    return data
        .map(
          (e) => LoanOffer(
            id: e['id'] as String,
            lenderName: e['lenderName'] as String,
            interestRate: (e['interestRate'] as num).toDouble(),
            amount: (e['amount'] as num).toDouble(),
            repaymentPeriod: e['repaymentPeriod'] as String,
            monthlyPayment: (e['monthlyPayment'] as num).toDouble(),
            conditions: e['conditions'] as String?,
            isRecommended: (e['isRecommended'] as int?) == 1,
            isSample: (e['isSample'] as int?) == 1,
            lenderId: e['lenderId'] as String?,
          ),
        )
        .toList();
  }

  /// Replaces the local copy with the offers currently published by lenders.
  Future<void> replaceOffers(List<Map<String, Object?>> rows) async {
    final batch = db.batch();
    batch.delete('loan_offers');
    for (final r in rows) {
      batch.insert('loan_offers', r, conflictAlgorithm: ConflictAlgorithm.replace);
    }
    await batch.commit(noResult: true);
  }
}
