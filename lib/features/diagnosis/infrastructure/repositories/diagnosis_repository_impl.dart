import 'dart:convert';
import 'dart:io';
import 'package:sqflite/sqflite.dart';
import '../../domain/entities/diagnosis.dart';
import '../../domain/repositories/diagnosis_repository.dart';
import '../datasource/local/diagnosis_sqlite.dart';
import '../datasource/remote/diagnosis_firestore.dart';

class DiagnosisRepositoryImpl implements DiagnosisRepository {
  final DiagnosisLocalDataSource local;
  final DiagnosisRemoteDataSource remote;
  final Database db;

  DiagnosisRepositoryImpl(this.local, this.remote, this.db);

  Map<String, dynamic> _summary(DiagnosisResult r) {
    final top = r.matches.isNotEmpty ? r.matches.first : null;
    return {
      'type': r.type,
      'subjectName': r.subjectName,
      'symptoms': r.symptoms,
      'timestamp': r.timestamp.toIso8601String(),
      'matches': [
        for (final m in r.matches)
          {
            'name': m.name,
            'confidence': m.confidence,
            'severity': m.severity,
            'treatment': m.treatment,
          },
      ],
      'topMatchName': top?.name,
      'topMatchConfidence': top?.confidence,
    };
  }

  @override
  Future<void> saveDiagnosis(DiagnosisResult result) async {
    await local.saveDiagnosis(result);
    await db.insert('sync_queue', {
      'id': result.id,
      'type': 'diagnosis',
      'payload': jsonEncode({'id': result.id, ..._summary(result)}),
      'retryCount': 0,
    }, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  /// Photos larger than this are left out: a Firestore document must stay
  /// under 1 MB and base64 adds a third.
  static const maxPhotoBytes = 500 * 1024;

  Future<String?> _photoBase64(String path) async {
    if (path.isEmpty) return null;
    try {
      final file = File(path);
      if (!await file.exists() || await file.length() > maxPhotoBytes) return null;
      return base64Encode(await file.readAsBytes());
    } catch (_) {
      return null;
    }
  }

  @override
  Future<void> escalate(DiagnosisResult result) async {
    final now = DateTime.now();
    final photo = await _photoBase64(result.imagePath);
    await local.markEscalated(result.id, now);
    await db.insert('sync_queue', {
      'id': 'esc_${result.id}',
      'type': 'diagnosis_escalation',
      'payload': jsonEncode({
        'id': 'esc_${result.id}',
        'diagnosisId': result.id,
        'status': 'open',
        'createdAt': now.toIso8601String(),
        if (photo != null) 'photoBase64': photo,
        ..._summary(result),
      }),
      'retryCount': 0,
    }, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  @override
  Future<List<DiagnosisResult>> getDiagnosisHistory(String farmerId) {
    return local.getDiagnosisHistory();
  }
}
