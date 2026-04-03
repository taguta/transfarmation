import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../domain/entities/diagnosis.dart';

class DiagnosisRemoteDataSource {
  final FirebaseFirestore firestore;
  DiagnosisRemoteDataSource(this.firestore);

  Future<void> sendDiagnosis(DiagnosisResult result) async {
    await firestore.collection('diagnosis_results').doc(result.id).set({
      'type': result.type,
      'imagePath': result.imagePath,
      'subjectName': result.subjectName,
      'timestamp': result.timestamp.toIso8601String(),
      'notes': result.notes,
      'matches':
          result.matches
              .map(
                (m) => {
                  'name': m.name,
                  'confidence': m.confidence,
                  'description': m.description,
                  'severity': m.severity,
                  'treatment': m.treatment,
                  'prevention': m.prevention,
                },
              )
              .toList(),
    });
  }
}
