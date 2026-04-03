import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:sqflite/sqflite.dart';

/// Listens to Firestore collections for the signed-in user and writes
/// changes back into SQLite.
///
/// Conflict resolution — "local-pending-wins":
///   - If a local row has isSynced = 0 (unsynced edits), the server version
///     is ignored so the user's pending changes are never overwritten.
///   - If isSynced = 1 (already synced), the server is authoritative and
///     the local row is updated.
///   - New documents from the server (no local row yet) are inserted with
///     isSynced = 1.
class FirestoreListener {
  final FirebaseFirestore firestore;
  final Database db;

  StreamSubscription<User?>? _authSub;
  final List<StreamSubscription<QuerySnapshot>> _collectionSubs = [];

  FirestoreListener(this.firestore, this.db);

  /// Starts watching Firebase Auth state. Collection listeners are started
  /// automatically when a user signs in and cancelled when they sign out.
  void start() {
    _authSub = FirebaseAuth.instance.authStateChanges().listen((user) {
      _cancelCollectionSubs();
      if (user != null) {
        _startCollectionListeners(user.uid);
      }
    });
  }

  void _startCollectionListeners(String farmerId) {
    // ── User-owned data (filtered by farmerId) ──────────────
    _collectionSubs.add(
      firestore
          .collection('loans')
          .where('farmerId', isEqualTo: farmerId)
          .snapshots()
          .listen(_onLoansSnapshot),
    );

    _collectionSubs.add(
      firestore
          .collection('farms')
          .where('farmerId', isEqualTo: farmerId)
          .snapshots()
          .listen(_onFarmsSnapshot),
    );

    _collectionSubs.add(
      firestore
          .collection('savings_transactions')
          .where('memberId', isEqualTo: farmerId)
          .snapshots()
          .listen(_onSavingsTransactionsSnapshot),
    );

    _collectionSubs.add(
      firestore
          .collection('diagnosis_results')
          .where('farmerId', isEqualTo: farmerId)
          .snapshots()
          .listen(_onDiagnosisSnapshot),
    );

    _collectionSubs.add(
      firestore
          .collection('subsidy_applications')
          .where('farmerId', isEqualTo: farmerId)
          .snapshots()
          .listen(_onSubsidySnapshot),
    );
  }

  // ── Snapshot handlers ───────────────────────────────────────

  Future<void> _onLoansSnapshot(QuerySnapshot snap) async {
    for (final change in snap.docChanges) {
      if (change.type == DocumentChangeType.removed) {
        await db.delete('loans', where: 'id = ?', whereArgs: [change.doc.id]);
        continue;
      }
      final d = change.doc.data() as Map<String, dynamic>;
      await _upsertIfNotPending('loans', change.doc.id, {
        'id': change.doc.id,
        'farmerId': d['farmerId'] as String? ?? '',
        'amount': (d['amount'] as num?)?.toDouble() ?? 0.0,
        'status': d['status'] as String? ?? 'pending',
        'createdAt': d['createdAt'] as String? ?? '',
      });
    }
  }

  Future<void> _onFarmsSnapshot(QuerySnapshot snap) async {
    for (final change in snap.docChanges) {
      if (change.type == DocumentChangeType.removed) {
        await db.delete('farms', where: 'id = ?', whereArgs: [change.doc.id]);
        continue;
      }
      final d = change.doc.data() as Map<String, dynamic>;
      final updatedAt = d['updatedAt'];
      await _upsertIfNotPending('farms', change.doc.id, {
        'id': change.doc.id,
        'name': d['name'] as String? ?? '',
        'farmerId': d['farmerId'] as String? ?? '',
        'totalHectares': (d['totalHectares'] as num?)?.toDouble(),
        'region': d['region'] as String?,
        'soilType': d['soilType'] as String?,
        'waterSource': d['waterSource'] as String?,
        'latitude': (d['latitude'] as num?)?.toDouble(),
        'longitude': (d['longitude'] as num?)?.toDouble(),
        'address': d['address'] as String?,
        'updatedAt': updatedAt is Timestamp
            ? updatedAt.toDate().toIso8601String()
            : updatedAt as String?,
      });
    }
  }

  Future<void> _onSavingsTransactionsSnapshot(QuerySnapshot snap) async {
    for (final change in snap.docChanges) {
      if (change.type == DocumentChangeType.removed) {
        await db.delete('savings_transactions', where: 'id = ?', whereArgs: [change.doc.id]);
        continue;
      }
      final d = change.doc.data() as Map<String, dynamic>;
      await _upsertIfNotPending('savings_transactions', change.doc.id, {
        'id': change.doc.id,
        'groupId': d['groupId'] as String? ?? '',
        'memberId': d['memberId'] as String?,
        'memberName': d['memberName'] as String?,
        'type': d['type'] as String? ?? '',
        'amount': (d['amount'] as num?)?.toDouble() ?? 0.0,
        'date': d['date'] as String? ?? '',
        'isConfirmed': (d['isConfirmed'] as bool? ?? false) ? 1 : 0,
      });
    }
  }

  Future<void> _onDiagnosisSnapshot(QuerySnapshot snap) async {
    for (final change in snap.docChanges) {
      if (change.type == DocumentChangeType.removed) {
        await db.delete('diagnosis_results', where: 'id = ?', whereArgs: [change.doc.id]);
        continue;
      }
      final d = change.doc.data() as Map<String, dynamic>;
      final matches = d['matches'] as List<dynamic>? ?? [];
      final top = matches.isNotEmpty ? matches.first as Map : null;
      await _upsertIfNotPending('diagnosis_results', change.doc.id, {
        'id': change.doc.id,
        'imagePath': d['imagePath'] as String?,
        'type': d['type'] as String?,
        'timestamp': d['timestamp'] as String? ?? '',
        'topMatchName': top?['name'] as String?,
        'topMatchConfidence': (top?['confidence'] as num?)?.toDouble(),
        'topMatchSeverity': top?['severity'] as String?,
        'topMatchTreatment': top?['treatment'] as String?,
      });
    }
  }

  Future<void> _onSubsidySnapshot(QuerySnapshot snap) async {
    for (final change in snap.docChanges) {
      if (change.type == DocumentChangeType.removed) {
        await db.delete('subsidy_applications', where: 'id = ?', whereArgs: [change.doc.id]);
        continue;
      }
      final d = change.doc.data() as Map<String, dynamic>;
      await _upsertIfNotPending('subsidy_applications', change.doc.id, {
        'id': change.doc.id,
        'programId': d['programId'] as String? ?? '',
        'programName': d['programName'] as String?,
        'status': d['status'] as String? ?? 'submitted',
        'appliedAt': d['appliedDate'] as String?,
      });
    }
  }

  // ── Conflict resolution helper ──────────────────────────────

  /// Inserts or updates [data] in [table] for [id], respecting pending local edits.
  ///
  /// - No local row → insert (new record from another device).
  /// - Local isSynced = 1 → server is authoritative; overwrite.
  /// - Local isSynced = 0 → user has unsent edits; skip server version.
  Future<void> _upsertIfNotPending(
    String table,
    String id,
    Map<String, dynamic> data,
  ) async {
    final existing = await db.query(
      table,
      columns: ['isSynced'],
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );

    if (existing.isEmpty) {
      await db.insert(
        table,
        {...data, 'isSynced': 1},
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    } else {
      final isSynced = existing.first['isSynced'] as int? ?? 0;
      if (isSynced == 1) {
        await db.update(
          table,
          {...data, 'isSynced': 1},
          where: 'id = ?',
          whereArgs: [id],
        );
      }
      // isSynced = 0 → pending local edit → skip
    }
  }

  void _cancelCollectionSubs() {
    for (final sub in _collectionSubs) {
      sub.cancel();
    }
    _collectionSubs.clear();
  }

  void dispose() {
    _authSub?.cancel();
    _cancelCollectionSubs();
  }
}
