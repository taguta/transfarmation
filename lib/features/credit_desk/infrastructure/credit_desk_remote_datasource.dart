import 'package:cloud_firestore/cloud_firestore.dart';
import '../domain/loan_application.dart';

/// Lenders work online, so the desk reads Firestore directly.
class CreditDeskRemoteDataSource {
  final FirebaseFirestore firestore;
  CreditDeskRemoteDataSource(this.firestore);

  CollectionReference<Map<String, dynamic>> get _loans => firestore.collection('loans');

  List<LoanApplication> _map(QuerySnapshot<Map<String, dynamic>> s) =>
      [for (final d in s.docs) LoanApplication.fromMap(d.id, d.data())];

  /// Pending applications, oldest first.
  Stream<List<LoanApplication>> watchPending() {
    return _loans.where('status', isEqualTo: 'pending').snapshots().map((s) {
      final list = _map(s);
      list.sort((a, b) => a.createdAt.compareTo(b.createdAt));
      return list;
    });
  }

  /// Applications this lender has decided, newest first.
  Stream<List<LoanApplication>> watchDecidedBy(String lenderUid) {
    return _loans.where('lenderId', isEqualTo: lenderUid).snapshots().map((s) {
      final list = _map(s);
      list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return list;
    });
  }

  CollectionReference<Map<String, dynamic>> get _offers => firestore.collection('loan_offers');

  Stream<List<Map<String, dynamic>>> watchMyOffers(String lenderUid) {
    return _offers.where('lenderId', isEqualTo: lenderUid).snapshots().map(
      (s) => [for (final d in s.docs) {...d.data(), 'id': d.id}],
    );
  }

  Future<void> publishOffer({
    required String lenderUid,
    required String lenderName,
    required double amount,
    required double annualRatePct,
    required int months,
    required String conditions,
  }) {
    final r = annualRatePct / 100 / 12;
    final monthly = r == 0
        ? amount / months
        : amount * r / (1 - _pow(1 + r, -months));
    return _offers.add({
      'lenderId': lenderUid,
      'lenderName': lenderName,
      'amount': amount,
      'interestRate': annualRatePct,
      'repaymentPeriod': '$months months',
      'monthlyPayment': double.parse(monthly.toStringAsFixed(2)),
      'conditions': conditions,
      'isRecommended': false,
      'isSample': false,
      'createdAt': DateTime.now().toIso8601String(),
    });
  }

  Future<void> withdrawOffer(String id) => _offers.doc(id).delete();

  static double _pow(double base, int exp) {
    var result = 1.0;
    final n = exp.abs();
    for (var i = 0; i < n; i++) {
      result *= base;
    }
    return exp < 0 ? 1 / result : result;
  }

  Future<void> decide({
    required String loanId,
    required bool approve,
    required String lenderUid,
    required String lenderName,
    required String note,
  }) {
    final now = DateTime.now().toIso8601String();
    return _loans.doc(loanId).update({
      'status': approve ? 'approved' : 'rejected',
      'lenderId': lenderUid,
      'lenderName': lenderName,
      'decisionNote': note,
      'decidedAt': now,
      'updatedAt': now,
    });
  }
}
