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
    return local.getNotifications();
  }

  @override
  Future<void> markAsRead(String id) async {
    await local.markAsRead(id);
    await db.insert('sync_queue', {
      'id': id,
      'type': 'notification_read',
      'payload': '{"id": "$id"}',
      'retryCount': 0,
    });
  }

  @override
  Future<void> markAllRead() async {
    await local.markAllRead();
    await db.insert('sync_queue', {
      'id': DateTime.now().toIso8601String(),
      'type': 'notification_mark_all_read',
      'payload': '{}',
      'retryCount': 0,
    });
  }

  @override
  Future<void> saveNotifications(List<AppNotification> notifications) async {
    await local.saveNotifications(notifications);
  }
}
