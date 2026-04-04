import 'package:sqflite/sqflite.dart';
import '../../domain/entities/notification.dart';
import '../../domain/repositories/notification_repository.dart';
import '../datasource/local/notification_sqlite.dart';
import '../datasource/remote/notification_firestore.dart';

class NotificationRepositoryImpl implements NotificationRepository {
  final NotificationLocalDataSource local;
  final NotificationRemoteDataSource remote;
  final Database db;

  NotificationRepositoryImpl(this.local, this.remote, this.db);

  @override
  Future<List<AppNotification>> getNotifications(String userId) async {
    try {
      final remoteData = await remote.fetchNotifications(userId);
      await local.saveNotifications(remoteData);
      return remoteData;
    } catch (_) {
      return local.getNotifications();
    }
  }

  @override
  Future<void> markAsRead(String id) async {
    await local.markAsRead(id);
    try {
      await remote.markAsRead('farmer-001', id);
    } catch (_) {
      // Offline sync handling can be ignored for small actions
    }
  }

  @override
  Future<void> markAllRead() async {
    final localNotes = await local.getNotifications();
    final ids = localNotes.map((e) => e.id).toList();
    await local.markAllRead();
    try {
      await remote.markAllRead('farmer-001', ids);
    } catch (_) {}
  }

  @override
  Future<void> saveNotifications(List<AppNotification> notifications) async {
    await local.saveNotifications(notifications);
    try {
      await remote.sendNotifications('farmer-001', notifications);
    } catch (_) {}
  }
}
