import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../domain/entities/loan.dart';

class LoanRemoteDataSource {
  final FirebaseFirestore firestore;

  LoanRemoteDataSource(this.firestore);

  Future<void> sendLoan(Loan loan) async {
    await firestore.collection('loans').doc(loan.id).set({
      'farmerId': loan.farmerId,
      'amount': loan.amount,
      'status': loan.status.name,
      'createdAt': loan.createdAt.toIso8601String(),
    });
  }
}
