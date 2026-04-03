import '../entities/savings_group.dart';

abstract class SavingsRepository {
  Future<List<SavingsGroup>> getGroups(String farmerId);
  Future<void> joinGroup(String groupId, String farmerId);
  Future<void> recordTransaction(SavingsTransaction transaction);
  Future<List<SavingsTransaction>> getTransactions(String groupId);
}
