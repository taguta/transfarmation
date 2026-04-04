import 'package:sqflite/sqflite.dart';
import '../../../domain/entities/notification.dart';

class NotificationLocalDataSource {
  final Database db;

  NotificationLocalDataSource(this.db);

  Future<void> saveNotifications(List<AppNotification> notifications) async {
    final batch = db.batch();
    for (final notify in notifications) {
      batch.insert(
        'notifications',
        notify.toJson(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }
    await batch.commit(noResult: true);
  }

  Future<List<AppNotification>> getNotifications() async {
    final result = await db.query(
      'notifications',
      orderBy: 'timestamp DESC',
    );
    return result.map((e) => AppNotification.fromJson(e)).toList();
  }

  Future<void> markAsRead(String id) async {
    await db.update(
      'notifications',
      {'isRead': 1},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> markAllRead() async {
    await db.update(
      'notifications',
      {'isRead': 1},
    );
  }
}
