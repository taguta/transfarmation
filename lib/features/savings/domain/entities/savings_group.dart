/// A savings group (mukando/stokvel) — rotating savings club.
class SavingsGroup {
  final String id;
  final String name;
  final String description;
  final double contributionAmount;
  final String frequency; // weekly, biweekly, monthly
  final int memberCount;
  final int maxMembers;
  final String status; // active, full, completed
  final DateTime nextPayoutDate;
  final String nextRecipient;
  final double totalPool;
  final List<SavingsGroupMember> members;

  const SavingsGroup({
    required this.id,
    required this.name,
    required this.description,
    required this.contributionAmount,
    required this.frequency,
    required this.memberCount,
    required this.maxMembers,
    required this.status,
    required this.nextPayoutDate,
    required this.nextRecipient,
    required this.totalPool,
    this.members = const [],
  });
}

class SavingsGroupMember {
  final String id;
  final String name;
  final int payoutOrder;
  final bool hasReceivedPayout;
  final double totalContributed;
  final bool isCurrentPayer;

  const SavingsGroupMember({
    required this.id,
    required this.name,
    required this.payoutOrder,
    required this.hasReceivedPayout,
    required this.totalContributed,
    this.isCurrentPayer = false,
  });
}

class SavingsTransaction {
  final String id;
  final String groupId;
  final String memberId;
  final String memberName;
  final String type; // contribution, payout
  final double amount;
  final DateTime date;
  final bool isConfirmed;

  const SavingsTransaction({
    required this.id,
    required this.groupId,
    required this.memberId,
    required this.memberName,
    required this.type,
    required this.amount,
    required this.date,
    required this.isConfirmed,
  });
}
