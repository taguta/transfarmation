/// The outcome of a symptom check, kept in the farmer's history.
class DiagnosisResult {
  final String id;
  final String type; // crop, livestock
  final String imagePath;
  final String subjectName; // e.g., "Maize", "Cattle"
  final DateTime timestamp;
  final List<DiagnosisMatch> matches;
  final String? notes;

  /// Labels of the symptoms the farmer reported.
  final List<String> symptoms;

  /// Set once the farmer asked a human agronomist to review this case.
  final DateTime? escalatedAt;

  /// The agronomist's answer, once one has replied.
  final String? expertReply;
  final DateTime? repliedAt;

  const DiagnosisResult({
    required this.id,
    required this.type,
    required this.imagePath,
    required this.subjectName,
    required this.timestamp,
    required this.matches,
    this.notes,
    this.symptoms = const [],
    this.escalatedAt,
    this.expertReply,
    this.repliedAt,
  });

  bool get hasReply => expertReply != null && expertReply!.isNotEmpty;
  bool get isEscalated => escalatedAt != null;

  DiagnosisResult copyWith({DateTime? escalatedAt}) => DiagnosisResult(
    id: id,
    type: type,
    imagePath: imagePath,
    subjectName: subjectName,
    timestamp: timestamp,
    matches: matches,
    notes: notes,
    symptoms: symptoms,
    escalatedAt: escalatedAt ?? this.escalatedAt,
    expertReply: expertReply,
    repliedAt: repliedAt,
  );
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
