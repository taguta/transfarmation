import '../entities/diagnosis.dart';

abstract class DiagnosisRepository {
  Future<void> saveDiagnosis(DiagnosisResult result);
  Future<List<DiagnosisResult>> getDiagnosisHistory(String farmerId);

  /// Asks a human agronomist to review a saved diagnosis. Works offline: the
  /// request is queued and sent when the device is back online.
  Future<void> escalate(DiagnosisResult result);
}
