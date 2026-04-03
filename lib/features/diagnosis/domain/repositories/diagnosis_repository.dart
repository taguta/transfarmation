import '../entities/diagnosis.dart';

abstract class DiagnosisRepository {
  Future<void> saveDiagnosis(DiagnosisResult result);
  Future<List<DiagnosisResult>> getDiagnosisHistory(String farmerId);
}
