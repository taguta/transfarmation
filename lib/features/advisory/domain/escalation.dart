/// A farmer's request for a human agronomist to review a symptom check.
class Escalation {
  final String id;
  final String diagnosisId;
  final String farmerId;
  final String type; // crop | livestock
  final String subjectName;
  final List<String> symptoms;
  final List<EscalationMatch> matches;
  final String status; // open | answered
  final DateTime createdAt;
  final String? reply;
  final DateTime? repliedAt;

  /// Compressed photo sent by the farmer, base64-encoded.
  final String? photoBase64;

  const Escalation({
    required this.id,
    required this.diagnosisId,
    required this.farmerId,
    required this.type,
    required this.subjectName,
    required this.symptoms,
    required this.matches,
    required this.status,
    required this.createdAt,
    this.reply,
    this.repliedAt,
    this.photoBase64,
  });

  bool get isOpen => status == 'open';

  /// How long the farmer has been waiting (or waited, if answered).
  Duration get waiting => (repliedAt ?? DateTime.now()).difference(createdAt);

  factory Escalation.fromMap(String id, Map<String, dynamic> d) => Escalation(
    id: id,
    diagnosisId: d['diagnosisId'] as String? ?? '',
    farmerId: d['farmerId'] as String? ?? '',
    type: d['type'] as String? ?? 'crop',
    subjectName: d['subjectName'] as String? ?? '',
    symptoms: List<String>.from(d['symptoms'] as List? ?? const []),
    matches: [
      for (final m in (d['matches'] as List? ?? const []))
        EscalationMatch.fromMap(Map<String, dynamic>.from(m as Map)),
    ],
    status: d['status'] as String? ?? 'open',
    createdAt: DateTime.tryParse(d['createdAt'] as String? ?? '') ?? DateTime.now(),
    reply: d['reply'] as String?,
    repliedAt: DateTime.tryParse(d['repliedAt'] as String? ?? ''),
    photoBase64: d['photoBase64'] as String?,
  );
}

class EscalationMatch {
  final String name;
  final double confidence;
  final String severity;
  const EscalationMatch(this.name, this.confidence, this.severity);

  factory EscalationMatch.fromMap(Map<String, dynamic> m) => EscalationMatch(
    m['name'] as String? ?? '',
    (m['confidence'] as num?)?.toDouble() ?? 0,
    m['severity'] as String? ?? '',
  );
}
