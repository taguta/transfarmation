import 'dart:convert';
import 'package:sqflite/sqflite.dart';
import '../../../domain/entities/diagnosis.dart';

class DiagnosisLocalDataSource {
  final Database db;
  DiagnosisLocalDataSource(this.db);

  Future<void> saveDiagnosis(DiagnosisResult result) async {
    final top = result.matches.isNotEmpty ? result.matches.first : null;
    await db.insert('diagnosis_results', {
      'id': result.id,
      'type': result.type,
      'imagePath': result.imagePath,
      'subjectName': result.subjectName,
      'timestamp': result.timestamp.toIso8601String(),
      'notes': result.notes,
      'symptoms': jsonEncode(result.symptoms),
      'escalatedAt': result.escalatedAt?.toIso8601String(),
      'matchCount': result.matches.length,
      'topMatchName': top?.name,
      'topMatchConfidence': top?.confidence,
      'topMatchSeverity': top?.severity,
      'topMatchTreatment': top?.treatment,
      'topMatchDescription': top?.description,
      'isSynced': 0,
    }, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<void> markEscalated(String id, DateTime at) async {
    await db.update(
      'diagnosis_results',
      {'escalatedAt': at.toIso8601String()},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<List<DiagnosisResult>> getDiagnosisHistory() async {
    final rows = await db.query('diagnosis_results', orderBy: 'timestamp DESC');
    return rows.map((r) {
      final topName = r['topMatchName'] as String?;
      List<String> symptoms = const [];
      try {
        final raw = r['symptoms'] as String?;
        if (raw != null) symptoms = List<String>.from(jsonDecode(raw) as List);
      } catch (_) {}
      final escalated = r['escalatedAt'] as String?;
      return DiagnosisResult(
        id: r['id'] as String,
        type: r['type'] as String? ?? 'crop',
        imagePath: r['imagePath'] as String? ?? '',
        subjectName: r['subjectName'] as String? ?? '',
        timestamp: DateTime.parse(r['timestamp'] as String),
        notes: r['notes'] as String?,
        symptoms: symptoms,
        escalatedAt: escalated == null ? null : DateTime.tryParse(escalated),
        expertReply: r['expertReply'] as String?,
        repliedAt: r['repliedAt'] == null ? null : DateTime.tryParse(r['repliedAt'] as String),
        matches: topName == null
            ? const []
            : [
                DiagnosisMatch(
                  name: topName,
                  confidence: (r['topMatchConfidence'] as num?)?.toDouble() ?? 0,
                  description: r['topMatchDescription'] as String? ?? '',
                  severity: r['topMatchSeverity'] as String? ?? '',
                  treatment: r['topMatchTreatment'] as String? ?? '',
                  prevention: '',
                ),
              ],
      );
    }).toList();
  }
}
