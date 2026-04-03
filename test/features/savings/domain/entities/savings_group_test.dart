import 'package:flutter_test/flutter_test.dart';
import 'package:transfarmation/features/savings/domain/entities/savings_group.dart';

void main() {
  group('SavingsGroup entity', () {
    test('creates group with members', () {
      final group = SavingsGroup(
        id: 'sg-001',
        name: 'Mhondoro Farmers Mukando',
        description: 'Monthly savings group',
        contributionAmount: 50,
        frequency: 'monthly',
        memberCount: 12,
        maxMembers: 12,
        status: 'active',
        nextPayoutDate: DateTime(2026, 5, 1),
        nextRecipient: 'Grace Mutasa',
        totalPool: 600,
        members: const [
          SavingsGroupMember(
            id: 'm1',
            name: 'Tendai Moyo',
            payoutOrder: 1,
            hasReceivedPayout: true,
            totalContributed: 200,
          ),
          SavingsGroupMember(
            id: 'm2',
            name: 'Grace Mutasa',
            payoutOrder: 2,
            hasReceivedPayout: false,
            totalContributed: 200,
            isCurrentPayer: true,
          ),
        ],
      );

      expect(group.members.length, 2);
      expect(group.contributionAmount, 50);
      expect(group.totalPool, 600);
    });
  });

  group('SavingsTransaction entity', () {
    test('creates contribution transaction', () {
      final txn = SavingsTransaction(
        id: 'st-001',
        groupId: 'sg-001',
        memberId: 'm1',
        memberName: 'Tendai Moyo',
        type: 'contribution',
        amount: 50,
        date: DateTime(2026, 4, 1),
        isConfirmed: true,
      );

      expect(txn.type, 'contribution');
      expect(txn.amount, 50);
      expect(txn.isConfirmed, true);
    });

    test('creates payout transaction', () {
      final txn = SavingsTransaction(
        id: 'st-002',
        groupId: 'sg-001',
        memberId: 'm1',
        memberName: 'Tendai Moyo',
        type: 'payout',
        amount: 600,
        date: DateTime(2026, 3, 1),
        isConfirmed: true,
      );

      expect(txn.type, 'payout');
      expect(txn.amount, 600);
    });
  });
}
