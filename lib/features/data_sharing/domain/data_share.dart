/// What a farmer can choose to share. Each scope is described in plain words,
/// because the farmer must understand exactly what the other person will see.
enum ShareScope {
  ledgerSummary(
    'ledger_summary',
    'Money in and out',
    'Your total income, total costs, biggest costs and what you still owe on loans.',
  ),
  plan(
    'plan',
    'Feasibility plan',
    'The numbers from the farm plan you built: expected income, costs and loan repayments.',
  ),
  farmLocation(
    'farm_location',
    'Farm location',
    'Where your farm and fields are, including GPS points.',
  ),
  loanFile(
    'loan_file',
    'Loan file',
    'The loan file PDF: your loan request, farm details and the summary of your records.',
  );

  final String code;
  final String title;
  final String description;
  const ShareScope(this.code, this.title, this.description);

  static ShareScope? fromCode(String? code) {
    for (final s in values) {
      if (s.code == code) return s;
    }
    return null;
  }
}

/// A farmer's permission for one named recipient to see one kind of data.
/// Each grant has its own id, so granting again after a revoke keeps the history.
class DataShare {
  final String id;
  final String farmerId;
  final String recipientName;

  /// Set when the recipient is a Transfarmation user (for example a verified
  /// lender), so access can be enforced on the server. Null for outside parties.
  final String? recipientId;
  final ShareScope scope;
  final DateTime grantedAt;
  final DateTime? revokedAt;

  /// Version of the consent wording the farmer saw when granting.
  final String consentVersion;
  final bool isSynced;

  const DataShare({
    required this.id,
    required this.farmerId,
    required this.recipientName,
    this.recipientId,
    required this.scope,
    required this.grantedAt,
    this.revokedAt,
    required this.consentVersion,
    this.isSynced = false,
  });

  bool get isActive => revokedAt == null;

  static const currentConsentVersion = '2026-10-share-v1';

  /// Names are compared ignoring case and surrounding spaces.
  static String normalise(String name) => name.trim().toLowerCase();

  bool isFor(String recipient, ShareScope s) =>
      scope == s && normalise(recipientName) == normalise(recipient);

  Map<String, dynamic> toMap() => {
    'id': id,
    'farmerId': farmerId,
    'recipientName': recipientName,
    'recipientId': recipientId,
    'scope': scope.code,
    'grantedAt': grantedAt.toUtc().toIso8601String(),
    'revokedAt': revokedAt?.toUtc().toIso8601String(),
    'consentVersion': consentVersion,
  };

  static DataShare? fromMap(Map<String, Object?> r) {
    final scope = ShareScope.fromCode(r['scope'] as String?);
    if (scope == null) return null;
    return DataShare(
      id: r['id'] as String,
      farmerId: r['farmerId'] as String,
      recipientName: r['recipientName'] as String? ?? '',
      recipientId: r['recipientId'] as String?,
      scope: scope,
      grantedAt: DateTime.parse(r['grantedAt'] as String),
      revokedAt: r['revokedAt'] == null ? null : DateTime.parse(r['revokedAt'] as String),
      consentVersion: r['consentVersion'] as String? ?? '',
      isSynced: (r['isSynced'] as int? ?? 0) == 1,
    );
  }
}

/// Questions the app and future server code ask about a farmer's shares.
class DataSharing {
  /// True when [recipient] currently holds an unrevoked share for [scope].
  static bool allows(Iterable<DataShare> shares, String recipient, ShareScope scope) =>
      shares.any((s) => s.isActive && s.isFor(recipient, scope));

  static List<DataShare> active(Iterable<DataShare> shares) =>
      shares.where((s) => s.isActive).toList();
}
