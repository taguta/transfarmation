import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/savings_group.dart';

class SavingsGroupNotifier extends Notifier<List<SavingsGroup>> {
  @override
  List<SavingsGroup> build() => _mockGroups;

  void createGroup(SavingsGroup group) {
    state = [...state, group];
  }

  static final _mockGroups = [
    SavingsGroup(
      id: 'sg-001',
      name: 'Mhondoro Farmers Mukando',
      description:
          'Monthly savings group for input purchases. Each member receives payout in rotation.',
      contributionAmount: 50.00,
      frequency: 'monthly',
      memberCount: 12,
      maxMembers: 12,
      status: 'active',
      nextPayoutDate: DateTime(2026, 5, 1),
      nextRecipient: 'Grace Mutasa',
      totalPool: 600.00,
      members: const [
        SavingsGroupMember(
          id: 'm1',
          name: 'Tendai Moyo',
          payoutOrder: 1,
          hasReceivedPayout: true,
          totalContributed: 200.00,
        ),
        SavingsGroupMember(
          id: 'm2',
          name: 'Grace Mutasa',
          payoutOrder: 2,
          hasReceivedPayout: false,
          totalContributed: 200.00,
          isCurrentPayer: true,
        ),
        SavingsGroupMember(
          id: 'm3',
          name: 'Peter Ncube',
          payoutOrder: 3,
          hasReceivedPayout: false,
          totalContributed: 200.00,
        ),
        SavingsGroupMember(
          id: 'm4',
          name: 'Rudo Chigwedere',
          payoutOrder: 4,
          hasReceivedPayout: false,
          totalContributed: 200.00,
        ),
        SavingsGroupMember(
          id: 'm5',
          name: 'John Maposa',
          payoutOrder: 5,
          hasReceivedPayout: false,
          totalContributed: 200.00,
        ),
        SavingsGroupMember(
          id: 'm6',
          name: 'Memory Dube',
          payoutOrder: 6,
          hasReceivedPayout: false,
          totalContributed: 150.00,
        ),
        SavingsGroupMember(
          id: 'm7',
          name: 'Tapiwa Manyika',
          payoutOrder: 7,
          hasReceivedPayout: false,
          totalContributed: 150.00,
        ),
        SavingsGroupMember(
          id: 'm8',
          name: 'Loveness Hove',
          payoutOrder: 8,
          hasReceivedPayout: false,
          totalContributed: 150.00,
        ),
        SavingsGroupMember(
          id: 'm9',
          name: 'Charles Zuze',
          payoutOrder: 9,
          hasReceivedPayout: false,
          totalContributed: 100.00,
        ),
        SavingsGroupMember(
          id: 'm10',
          name: 'Esther Gumbo',
          payoutOrder: 10,
          hasReceivedPayout: false,
          totalContributed: 100.00,
        ),
        SavingsGroupMember(
          id: 'm11',
          name: 'Simon Pfuma',
          payoutOrder: 11,
          hasReceivedPayout: false,
          totalContributed: 50.00,
        ),
        SavingsGroupMember(
          id: 'm12',
          name: 'Agnes Tembo',
          payoutOrder: 12,
          hasReceivedPayout: false,
          totalContributed: 50.00,
        ),
      ],
    ),
    SavingsGroup(
      id: 'sg-002',
      name: 'Chitungwiza Poultry Club',
      description:
          'Bi-weekly savings for bulk poultry feed purchasing. Group discount of 15% from ProFeeds.',
      contributionAmount: 25.00,
      frequency: 'biweekly',
      memberCount: 8,
      maxMembers: 15,
      status: 'active',
      nextPayoutDate: DateTime(2026, 4, 15),
      nextRecipient: 'Martha Chiriga',
      totalPool: 200.00,
    ),
  ];
}

final savingsGroupsProvider =
    NotifierProvider<SavingsGroupNotifier, List<SavingsGroup>>(
      SavingsGroupNotifier.new,
    );

final savingsTransactionsProvider = Provider<List<SavingsTransaction>>((ref) {
  return [
    SavingsTransaction(
      id: 'st-001',
      groupId: 'sg-001',
      memberId: 'm1',
      memberName: 'Tendai Moyo',
      type: 'contribution',
      amount: 50.00,
      date: DateTime(2026, 4, 1),
      isConfirmed: true,
    ),
    SavingsTransaction(
      id: 'st-002',
      groupId: 'sg-001',
      memberId: 'm2',
      memberName: 'Grace Mutasa',
      type: 'contribution',
      amount: 50.00,
      date: DateTime(2026, 4, 1),
      isConfirmed: true,
    ),
    SavingsTransaction(
      id: 'st-003',
      groupId: 'sg-001',
      memberId: 'm1',
      memberName: 'Tendai Moyo',
      type: 'payout',
      amount: 600.00,
      date: DateTime(2026, 3, 1),
      isConfirmed: true,
    ),
  ];
});
