
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

    try {
      await remote.sendLoan(loan);
    } catch (_) {
      await db.insert('sync_queue', {
        'id': loan.id,
        'type': 'loan',
        'payload': jsonEncode({
          'id': loan.id,
          'farmerId': loan.farmerId,
          'amount': loan.amount,
          'createdAt': loan.createdAt.toIso8601String(),
        }),
        'retryCount': 0
      });
    }
  }

  @override
  Future<List<Loan>> getLoans(String farmerId) {
    return local.getLoans();
  }
}
