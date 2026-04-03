import 'dart:convert';
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

  @override
  Future<void> saveDiagnosis(DiagnosisResult result) async {
    await local.saveDiagnosis(result);
    try {
      await remote.sendDiagnosis(result);
    } catch (_) {
      await db.insert('sync_queue', {
        'id': result.id,
        'type': 'diagnosis',
        'payload': jsonEncode({
          'id': result.id,
          'type': result.type,
          'subjectName': result.subjectName,
          'timestamp': result.timestamp.toIso8601String(),
        }),
        'retryCount': 0,
      });
    }
  }

  @override
  Future<List<DiagnosisResult>> getDiagnosisHistory(String farmerId) {
    return local.getDiagnosisHistory();
  }
}
