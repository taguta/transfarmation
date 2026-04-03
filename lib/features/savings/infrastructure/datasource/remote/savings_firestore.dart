import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../domain/entities/savings_group.dart';

class SavingsRemoteDataSource {
  final FirebaseFirestore firestore;
  SavingsRemoteDataSource(this.firestore);

  Future<void> sendTransaction(SavingsTransaction txn) async {
    await firestore.collection('savings_transactions').doc(txn.id).set({
      'groupId': txn.groupId,
      'memberId': txn.memberId,
      'memberName': txn.memberName,
      'type': txn.type,
      'amount': txn.amount,
      'date': txn.date.toIso8601String(),
      'isConfirmed': txn.isConfirmed,
    });
  }

  Future<List<SavingsGroup>> fetchGroups() async {
    final snap = await firestore.collection('savings_groups').get();
    return snap.docs.map((doc) {
      final d = doc.data();
      return SavingsGroup(
        id: doc.id,
        name: d['name'] as String? ?? '',
        description: d['description'] as String? ?? '',
        contributionAmount: (d['contributionAmount'] as num?)?.toDouble() ?? 0,
        frequency: d['frequency'] as String? ?? 'monthly',
        memberCount: d['memberCount'] as int? ?? 0,
        maxMembers: d['maxMembers'] as int? ?? 10,
        status: d['status'] as String? ?? 'active',
        nextPayoutDate: d['nextPayoutDate'] != null
            ? (d['nextPayoutDate'] as Timestamp).toDate()
            : DateTime.now(),
        nextRecipient: d['nextRecipient'] as String? ?? '',
        totalPool: (d['totalPool'] as num?)?.toDouble() ?? 0,
      );
    }).toList();
  }
}
