/// A professional's request to be verified as an agronomist or vet.
class ExpertApplication {
  final String uid;
  final String name;
  final String profession; // Agronomist | Veterinarian
  final String licenceNumber;
  final String organisation;
  final String email;
  final String status; // pending | approved | rejected
  final DateTime submittedAt;
  final String? reviewNote;

  const ExpertApplication({
    required this.uid,
    required this.name,
    required this.profession,
    required this.licenceNumber,
    required this.organisation,
    required this.email,
    required this.status,
    required this.submittedAt,
    this.reviewNote,
  });

  bool get isPending => status == 'pending';
  bool get isRejected => status == 'rejected';

  factory ExpertApplication.fromMap(String uid, Map<String, dynamic> d) =>
      ExpertApplication(
        uid: uid,
        name: d['name'] as String? ?? '',
        profession: d['profession'] as String? ?? '',
        licenceNumber: d['licenceNumber'] as String? ?? '',
        organisation: d['organisation'] as String? ?? '',
        email: d['email'] as String? ?? '',
        status: d['status'] as String? ?? 'pending',
        submittedAt: DateTime.tryParse(d['submittedAt'] as String? ?? '') ?? DateTime.now(),
        reviewNote: d['reviewNote'] as String?,
      );
}
