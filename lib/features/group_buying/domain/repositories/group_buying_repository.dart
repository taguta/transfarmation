import '../entities/cooperative.dart';

abstract class GroupBuyingRepository {
  Future<List<Cooperative>> getCooperatives(String region);
  Future<void> joinOrder(String orderId, String farmerId, int quantity);
  Future<List<GroupOrder>> getActiveOrders();
}
