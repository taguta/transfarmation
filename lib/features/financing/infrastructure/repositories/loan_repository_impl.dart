import 'dart:convert';
import 'package:sqflite/sqflite.dart';
import '../../domain/entities/loan.dart';
import '../../domain/repositories/loan_repository.dart';
import '../datasource/local/loan_sqlite.dart';
import '../datasource/remote/loan_firestore.dart';

class LoanRepositoryImpl implements LoanRepository {
  final LoanLocalDataSource local;
  final LoanRemoteDataSource remote;
  final Database db;

  LoanRepositoryImpl(this.local, this.remote, this.db);

  @override
  Future<void> applyLoan(Loan loan) async {
    await local.saveLoan(loan);
    await db.insert('sync_queue', {
      'id': loan.id,
      'type': 'loan',
      'payload': jsonEncode({
        'id': loan.id,
        'farmerId': loan.farmerId,
        'amount': loan.amount,
        'status': 'pending',
        'createdAt': loan.createdAt.toIso8601String(),
        'farmName': loan.farmName,
        'province': loan.province,
        'farmSize': loan.farmSize,
        'cropType': loan.cropType,
        'farmingType': loan.farmingType,
        'purpose': loan.purpose,
        'repaymentPeriod': loan.repaymentPeriod,
        'planSummary': loan.planSummary,
      }),
      'retryCount': 0
    }, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  @override
  Future<List<Loan>> getLoans(String farmerId) {
    return local.getLoans(farmerId);
  }

  @override
  Future<void> recordPayment(LoanPayment p) async {
    await local.savePayment(p);
    await db.insert('sync_queue', {
      'id': p.id,
      'type': 'loan_payment',
      'payload': jsonEncode({
        'id': p.id,
        'loanId': p.loanId,
        'farmerId': p.farmerId,
        'amount': p.amount,
        'date': p.date.toIso8601String(),
        'method': p.method,
      }),
      'retryCount': 0
    }, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  @override
  Future<List<LoanPayment>> getPayments(String loanId) => local.getPayments(loanId);

  @override
  Future<List<LoanOffer>> getLoanOffers() {
    return local.getLoanOffers();
  }
}

