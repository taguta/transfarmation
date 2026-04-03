import 'package:sqflite/sqflite.dart';
import '../../../domain/entities/diagnosis.dart';

class DiagnosisLocalDataSource {
  final Database db;
  DiagnosisLocalDataSource(this.db);

  Future<void> saveDiagnosis(DiagnosisResult result) async {
    await db.insert('diagnosis_results', {
      'id': result.id,
      'type': result.type,
      'imagePath': result.imagePath,
      'subjectName': result.subjectName,
      'timestamp': result.timestamp.toIso8601String(),
      'notes': result.notes,
      'matchCount': result.matches.length,
      'topMatchName':
          result.matches.isNotEmpty ? result.matches.first.name : null,
      'topMatchConfidence':
          result.matches.isNotEmpty ? result.matches.first.confidence : null,
      'isSynced': 0,
    }, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<List<DiagnosisResult>> getDiagnosisHistory() async {
    final rows = await db.query('diagnosis_results', orderBy: 'timestamp DESC');
    return rows.map((r) {
      final topName = r['topMatchName'] as String?;
      final topConf = (r['topMatchConfidence'] as num?)?.toDouble();
      return DiagnosisResult(
        id: r['id'] as String,
        type: r['type'] as String,
        imagePath: r['imagePath'] as String? ?? '',
        subjectName: r['subjectName'] as String? ?? '',
        timestamp: DateTime.parse(r['timestamp'] as String),
        notes: r['notes'] as String?,
        matches:
            topName != null
                ? [
                  DiagnosisMatch(
                    name: topName,
                    confidence: topConf ?? 0,
                    description: '',
                    severity: '',
                    treatment: '',
                    prevention: '',
                  ),
                ]
                : [],
      );
    }).toList();
  }
}
