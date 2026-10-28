import 'package:cloud_firestore/cloud_firestore.dart';
import '../domain/escalation.dart';
import '../domain/expert_application.dart';

/// Experts work online, so the desk reads Firestore directly.
class AdvisoryRemoteDataSource {
  final FirebaseFirestore firestore;
  AdvisoryRemoteDataSource(this.firestore);

  CollectionReference<Map<String, dynamic>> get _col =>
      firestore.collection('diagnosis_escalations');

  /// True when an admin has verified this user as an expert. The rules enforce
  /// this too; this check only decides what the UI shows.
  Future<bool> isVerifiedExpert(String uid) async {
    final p = (await verification(uid))?['profession'];
    return p == 'Agronomist' || p == 'Veterinarian';
  }

  Future<bool> isVerifiedLender(String uid) async =>
      (await verification(uid))?['profession'] == 'Lender';

  /// The admin-written verification record (profession, name), if any.
  Future<Map<String, dynamic>?> verification(String uid) async {
    try {
      final d = await firestore.collection('verified_experts').doc(uid).get();
      return d.data();
    } catch (_) {
      return null;
    }
  }

  /// Open requests, oldest first (longest-waiting farmer on top).
  Stream<List<Escalation>> watchOpen() {
    return _col.where('status', isEqualTo: 'open').snapshots().map((s) {
      final list = [for (final d in s.docs) Escalation.fromMap(d.id, d.data())];
      list.sort((a, b) => a.createdAt.compareTo(b.createdAt));
      return list;
    });
  }

  /// Requests this expert has answered, newest first.
  Stream<List<Escalation>> watchAnsweredBy(String uid) {
    return _col.where('repliedBy', isEqualTo: uid).snapshots().map((s) {
      final list = [for (final d in s.docs) Escalation.fromMap(d.id, d.data())];
      list.sort((a, b) => (b.repliedAt ?? b.createdAt).compareTo(a.repliedAt ?? a.createdAt));
      return list;
    });
  }

  Future<void> reply(String id, String text, String expertUid) {
    return _col.doc(id).update({
      'status': 'answered',
      'reply': text,
      'repliedBy': expertUid,
      'repliedAt': DateTime.now().toIso8601String(),
    });
  }

  // ── Expert verification ───────────────────────────────────

  Future<bool> isAdmin(String uid) async {
    try {
      return (await firestore.collection('admins').doc(uid).get()).exists;
    } catch (_) {
      return false;
    }
  }

  DocumentReference<Map<String, dynamic>> _app(String uid) =>
      firestore.collection('expert_applications').doc(uid);

  Stream<ExpertApplication?> watchMyApplication(String uid) {
    return _app(uid).snapshots().map(
      (d) => d.exists ? ExpertApplication.fromMap(uid, d.data()!) : null,
    );
  }

  Future<void> submitApplication(ExpertApplication a) {
    return _app(a.uid).set({
      'uid': a.uid,
      'name': a.name,
      'profession': a.profession,
      'licenceNumber': a.licenceNumber,
      'organisation': a.organisation,
      'email': a.email,
      'status': 'pending',
      'submittedAt': DateTime.now().toIso8601String(),
    });
  }

  /// A rejected applicant clears the old application to apply again.
  Future<void> withdraw(String uid) => _app(uid).delete();

  Stream<List<ExpertApplication>> watchPendingApplications() {
    return firestore
        .collection('expert_applications')
        .where('status', isEqualTo: 'pending')
        .snapshots()
        .map((s) {
          final list = [for (final d in s.docs) ExpertApplication.fromMap(d.id, d.data())];
          list.sort((a, b) => a.submittedAt.compareTo(b.submittedAt));
          return list;
        });
  }

  Future<void> approve(ExpertApplication a, String adminUid) async {
    final now = DateTime.now().toIso8601String();
    final batch = firestore.batch();
    batch.set(firestore.collection('verified_experts').doc(a.uid), {
      'name': a.name,
      'profession': a.profession,
      'licenceNumber': a.licenceNumber,
      'verifiedBy': adminUid,
      'verifiedAt': now,
    });
    batch.update(_app(a.uid), {
      'status': 'approved',
      'reviewedBy': adminUid,
      'reviewedAt': now,
    });
    await batch.commit();
  }

  Future<void> reject(ExpertApplication a, String adminUid, String note) {
    return _app(a.uid).update({
      'status': 'rejected',
      'reviewedBy': adminUid,
      'reviewedAt': DateTime.now().toIso8601String(),
      'reviewNote': note,
    });
  }
}
