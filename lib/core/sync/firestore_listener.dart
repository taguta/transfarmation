import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:sqflite/sqflite.dart';

/// Pulls data from Firestore collections for the signed-in user and writes
/// changes back into SQLite. Utilizes Delta Polling (only fetching changes since last sync)
/// to drastically reduce billable reads.
class FirestoreListener {
  final FirebaseFirestore firestore;
  final Database db;

  StreamSubscription<User?>? _authSub;
  Timer? _pollingTimer;

  FirestoreListener(this.firestore, this.db);

  /// Starts watching Firebase Auth state. The delta poller is started
  /// automatically when a user signs in and cancelled when they sign out.
  void start() {
    _authSub = FirebaseAuth.instance.authStateChanges().listen((user) {
      _stopPolling();
      if (user != null) {
        _pullAllChanges(user.uid);
        // Poll every 5 minutes while the app is alive
        _pollingTimer = Timer.periodic(const Duration(minutes: 5), (_) {
          _pullAllChanges(user.uid);
        });
      }
    });
  }

  Future<String?> _getLastSync(String collection) async {
    final result = await db.query(
      'sync_metadata',
      where: 'collection = ?',
      whereArgs: [collection],
      limit: 1,
    );
    if (result.isNotEmpty) {
      return result.first['lastSyncAt'] as String?;
    }
    return null;
  }

  Future<void> _setLastSync(String collection, String timestamp) async {
    await db.insert(
      'sync_metadata',
      {'collection': collection, 'lastSyncAt': timestamp},
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> _pullAllChanges(String farmerId) async {
    await Future.wait([
      _pullLoans(farmerId),
      _pullFarms(farmerId),
      _pullSavingsTransactions(farmerId),
      _pullDiagnosis(farmerId),
      _pullSubsidies(farmerId),
      _pullFarmInputs(),
      _pullCommodityPrices(),
      _pullWeatherAlerts(),
      _pullNotifications(farmerId),
      _pullFarmWorkers(farmerId),
      _pullFarmTasks(farmerId),
      _pullIotSensors(farmerId),
      _pullForumPosts(),
    ]);
  }


  Future<void> _pullLoans(String farmerId) async {
    final lastSync = await _getLastSync('loans');
    Query<Map<String, dynamic>> query = firestore.collection('loans')
      .where('farmerId', isEqualTo: farmerId);
    
    if (lastSync != null) {
      query = query.where('updatedAt', isGreaterThan: lastSync);
    }
    
    final snap = await query.get();
    if (snap.docs.isNotEmpty) {
      for (final doc in snap.docs) {
        final d = doc.data();
        await _upsertIfNotPending('loans', doc.id, {
          'id': doc.id,
          'farmerId': d['farmerId'] as String? ?? '',
          'amount': (d['amount'] as num?)?.toDouble() ?? 0.0,
          'status': d['status'] as String? ?? 'pending',
          'createdAt': d['createdAt'] as String? ?? '',
        });
      }
      await _setLastSync('loans', DateTime.now().toIso8601String());
    }
  }

  Future<void> _pullFarms(String farmerId) async {
    final lastSync = await _getLastSync('farms');
    Query<Map<String, dynamic>> query = firestore.collection('farms')
      .where('farmerId', isEqualTo: farmerId);
    
    if (lastSync != null) {
      query = query.where('updatedAt', isGreaterThan: lastSync);
    }
    
    final snap = await query.get();
    if (snap.docs.isNotEmpty) {
      for (final doc in snap.docs) {
        final d = doc.data();
        final updatedAt = d['updatedAt'];
        await _upsertIfNotPending('farms', doc.id, {
          'id': doc.id,
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
      await _setLastSync('farms', DateTime.now().toIso8601String());
    }
  }

  Future<void> _pullSavingsTransactions(String farmerId) async {
    final lastSync = await _getLastSync('savings_transactions');
    Query<Map<String, dynamic>> query = firestore.collection('savings_transactions')
      .where('memberId', isEqualTo: farmerId);
    
    if (lastSync != null) {
      query = query.where('updatedAt', isGreaterThan: lastSync);
    }
    
    final snap = await query.get();
    if (snap.docs.isNotEmpty) {
      for (final doc in snap.docs) {
        final d = doc.data();
        await _upsertIfNotPending('savings_transactions', doc.id, {
          'id': doc.id,
          'groupId': d['groupId'] as String? ?? '',
          'memberId': d['memberId'] as String?,
          'memberName': d['memberName'] as String?,
          'type': d['type'] as String? ?? '',
          'amount': (d['amount'] as num?)?.toDouble() ?? 0.0,
          'date': d['date'] as String? ?? '',
          'isConfirmed': (d['isConfirmed'] as bool? ?? false) ? 1 : 0,
        });
      }
      await _setLastSync('savings_transactions', DateTime.now().toIso8601String());
    }
  }

  Future<void> _pullDiagnosis(String farmerId) async {
    final lastSync = await _getLastSync('diagnosis_results');
    Query<Map<String, dynamic>> query = firestore.collection('diagnosis_results')
      .where('farmerId', isEqualTo: farmerId);
    
    if (lastSync != null) {
      query = query.where('updatedAt', isGreaterThan: lastSync);
    }
    
    final snap = await query.get();
    if (snap.docs.isNotEmpty) {
      for (final doc in snap.docs) {
        final d = doc.data();
        final matches = d['matches'] as List<dynamic>? ?? [];
        final top = matches.isNotEmpty ? matches.first as Map : null;
        await _upsertIfNotPending('diagnosis_results', doc.id, {
          'id': doc.id,
          'imagePath': d['imagePath'] as String?,
          'type': d['type'] as String?,
          'timestamp': d['timestamp'] as String? ?? '',
          'topMatchName': top?['name'] as String?,
          'topMatchConfidence': (top?['confidence'] as num?)?.toDouble(),
          'topMatchSeverity': top?['severity'] as String?,
          'topMatchTreatment': top?['treatment'] as String?,
        });
      }
      await _setLastSync('diagnosis_results', DateTime.now().toIso8601String());
    }
  }

  Future<void> _pullSubsidies(String farmerId) async {
    final lastSync = await _getLastSync('subsidy_applications');
    Query<Map<String, dynamic>> query = firestore.collection('subsidy_applications')
      .where('farmerId', isEqualTo: farmerId);
    
    if (lastSync != null) {
      query = query.where('updatedAt', isGreaterThan: lastSync);
    }
    
    final snap = await query.get();
    if (snap.docs.isNotEmpty) {
      for (final doc in snap.docs) {
        final d = doc.data();
        await _upsertIfNotPending('subsidy_applications', doc.id, {
          'id': doc.id,
          'programId': d['programId'] as String? ?? '',
          'programName': d['programName'] as String?,
          'status': d['status'] as String? ?? 'submitted',
          'appliedAt': d['appliedDate'] as String?,
        });
      }
      await _setLastSync('subsidy_applications', DateTime.now().toIso8601String());
    }
  }

  Future<void> _pullFarmInputs() async {
    final snap = await firestore.collection('farm_inputs').get();
    if (snap.docs.isNotEmpty) {
      for (final doc in snap.docs) {
        final d = doc.data();
        await _upsertIfNotPending('farm_inputs', doc.id, {
          'id': doc.id,
          'name': d['name'] as String? ?? '',
          'category': d['category'] as String?,
          'supplier': d['supplier'] as String?,
          'price': (d['price'] as num?)?.toDouble() ?? 0.0,
          'bulkPrice': (d['bulkPrice'] as num?)?.toDouble(),
          'unit': d['unit'] as String?,
          'description': d['description'] as String?,
          'isVerified': (d['isVerified'] as bool? ?? false) ? 1 : 0,
        });
      }
    }
  }

  Future<void> _pullCommodityPrices() async {
    final snap = await firestore.collection('commodity_prices').get();
    if (snap.docs.isNotEmpty) {
      for (final doc in snap.docs) {
        final d = doc.data();
        await _upsertIfNotPending('commodity_prices', doc.id, {
          'id': doc.id,
          'commodityName': d['commodityName'] as String? ?? '',
          'category': d['category'] as String?,
          'unit': d['unit'] as String?,
          'price': (d['price'] as num?)?.toDouble() ?? 0.0,
          'previousPrice': (d['previousPrice'] as num?)?.toDouble() ?? 0.0,
          'fetchedAt': DateTime.now().toIso8601String(),
        });
      }
    }
  }

  Future<void> _pullWeatherAlerts() async {
    final snap = await firestore.collection('weather_alerts').get();
    if (snap.docs.isNotEmpty) {
      for (final doc in snap.docs) {
        final d = doc.data();
        await _upsertIfNotPending('weather_alerts', doc.id, {
          'id': doc.id,
          'title': d['title'] as String? ?? '',
          'description': d['description'] as String?,
          'severity': d['severity'] as String?,
          'region': d['region'] as String?,
          'fetchedAt': DateTime.now().toIso8601String(),
        });
      }
    }
  }

  Future<void> _pullNotifications(String farmerId) async {
    final snap = await firestore.collection('notifications').where('farmerId', isEqualTo: farmerId).get();
    if (snap.docs.isNotEmpty) {
      for (final doc in snap.docs) {
        final d = doc.data();
        await _upsertIfNotPending('notifications', doc.id, {
          'id': doc.id,
          'title': d['title'] as String? ?? '',
          'body': d['body'] as String? ?? '',
          'type': d['type'] as String? ?? '',
          'timestamp': d['timestamp'] as String? ?? DateTime.now().toIso8601String(),
          'isRead': (d['isRead'] as bool? ?? false) ? 1 : 0,
        });
      }
    }
  }

  Future<void> _pullFarmWorkers(String farmerId) async {
    final lastSync = await _getLastSync('farm_workers');
    Query<Map<String, dynamic>> query = firestore.collection('farm_workers').where('farmId', isEqualTo: farmerId);
    if (lastSync != null) query = query.where('updatedAt', isGreaterThan: lastSync);
    
    final snap = await query.get();
    if (snap.docs.isNotEmpty) {
      for (final doc in snap.docs) {
        final d = doc.data();
        await _upsertIfNotPending('farm_workers', doc.id, {
          'id': doc.id,
          'farmId': d['farmId'] as String? ?? '',
          'name': d['name'] as String? ?? '',
          'role': d['role'] as String?,
          'dailyWage': (d['dailyWage'] as num?)?.toDouble() ?? 0.0,
          'phone': d['phone'] as String?,
        });
      }
      await _setLastSync('farm_workers', DateTime.now().toIso8601String());
    }
  }

  Future<void> _pullFarmTasks(String farmerId) async {
    final lastSync = await _getLastSync('farm_tasks');
    Query<Map<String, dynamic>> query = firestore.collection('farm_tasks').where('farmId', isEqualTo: farmerId);
    if (lastSync != null) query = query.where('updatedAt', isGreaterThan: lastSync);
    
    final snap = await query.get();
    if (snap.docs.isNotEmpty) {
      for (final doc in snap.docs) {
        final d = doc.data();
        await _upsertIfNotPending('farm_tasks', doc.id, {
          'id': doc.id,
          'farmId': d['farmId'] as String? ?? '',
          'name': d['name'] as String? ?? '',
          'assignedWorkerId': d['assignedWorkerId'] as String?,
          'date': d['date'] as String? ?? DateTime.now().toIso8601String(),
          'status': d['status'] as String? ?? 'pending',
          'estimatedCost': (d['estimatedCost'] as num?)?.toDouble() ?? 0.0,
        });
      }
      await _setLastSync('farm_tasks', DateTime.now().toIso8601String());
    }
  }

  Future<void> _pullIotSensors(String farmerId) async {
    final snap = await firestore.collection('iot_sensors').where('farmId', isEqualTo: farmerId).get();
    if (snap.docs.isNotEmpty) {
      for (final doc in snap.docs) {
        final d = doc.data();
        await _upsertIfNotPending('iot_sensors', doc.id, {
          'id': doc.id,
          'farmId': d['farmId'] as String?,
          'name': d['name'] as String? ?? '',
          'type': d['type'] as String?,
          'status': d['status'] as String? ?? 'offline',
          'battery': (d['battery'] as num?)?.toInt() ?? 0,
          'currentValue': d['currentValue'] as String?,
          'trend': d['trend'] as String?,
          'lastUpdated': d['lastUpdated'] as String? ?? DateTime.now().toIso8601String(),
        });
      }
    }
  }

  Future<void> _pullForumPosts() async {
    final snap = await firestore.collection('forum_posts')
        .orderBy('time', descending: true)
        .limit(20)
        .get();
        
    if (snap.docs.isNotEmpty) {
      for (final doc in snap.docs) {
        final d = doc.data();
        await _upsertIfNotPending('forum_posts', doc.id, {
          'id': doc.id,
          'author': d['author'] as String? ?? 'Unknown',
          'region': d['region'] as String? ?? '',
          'title': d['title'] as String? ?? '',
          'content': d['content'] as String? ?? '',
          'replies': (d['replies'] as num?)?.toInt() ?? 0,
          'tagsData': d['tagsData'] as String? ?? '[]',
          'isAlert': (d['isAlert'] as bool? ?? false) ? 1 : 0,
          'time': d['time'] as String? ?? DateTime.now().toIso8601String(),
        });
      }
    }
  }

  /// Inserts or updates [data] in [table] for [id], respecting pending local edits.
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
    }
  }

  void _stopPolling() {
    _pollingTimer?.cancel();
    _pollingTimer = null;
  }

  void dispose() {
    _authSub?.cancel();
    _stopPolling();
  }
}
