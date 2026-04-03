
import '../entities/loan.dart';

abstract class LoanRepository {
  Future<void> applyLoan(Loan loan);
  Future<List<Loan>> getLoans(String farmerId);
}
