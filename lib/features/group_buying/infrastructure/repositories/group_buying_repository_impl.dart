import 'dart:convert';
import 'package:sqflite/sqflite.dart';
import '../../domain/entities/cooperative.dart';
import '../../domain/repositories/group_buying_repository.dart';
import '../datasource/local/group_buying_sqlite.dart';
import '../datasource/remote/group_buying_firestore.dart';

class GroupBuyingRepositoryImpl implements GroupBuyingRepository {
  final GroupBuyingLocalDataSource local;
  final GroupBuyingRemoteDataSource remote;
  final Database db;

  GroupBuyingRepositoryImpl(this.local, this.remote, this.db);

  @override
  Future<List<Cooperative>> getCooperatives(String region) async {
    return local.getCooperatives();
  }

  @override
  Future<void> joinOrder(String orderId, String farmerId, int quantity) async {
    await db.insert('sync_queue', {
      'id': '${orderId}_$farmerId',
      'type': 'group_order_join',
      'payload': jsonEncode({
        'orderId': orderId,
        'farmerId': farmerId,
        'quantity': quantity,
      }),
      'retryCount': 0,
    });
  }

  @override
  Future<List<GroupOrder>> getActiveOrders() => local.getActiveOrders();
}
