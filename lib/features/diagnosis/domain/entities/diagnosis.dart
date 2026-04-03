/// A diagnosis result from the AI engine.
class DiagnosisResult {
  final String id;
  final String type; // crop, livestock
  final String imagePath;
  final String subjectName; // e.g., "Maize", "Cattle"
  final DateTime timestamp;
  final List<DiagnosisMatch> matches;
  final String? notes;

  const DiagnosisResult({
    required this.id,
    required this.type,
    required this.imagePath,
    required this.subjectName,
    required this.timestamp,
    required this.matches,
    this.notes,
  });
}

class DiagnosisMatch {
  final String name;
  final double confidence; // 0.0–1.0
  final String description;
  final String severity;
  final String treatment;
  final String prevention;

  const DiagnosisMatch({
    required this.name,
    required this.confidence,
    required this.description,
    required this.severity,
    required this.treatment,
    required this.prevention,
  });
}
