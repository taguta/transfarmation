import '../entities/notification.dart';

abstract class NotificationRepository {
  Future<List<AppNotification>> getNotifications(String userId);
  Future<void> markAsRead(String id);
  Future<void> markAllRead();
  Future<void> saveNotifications(List<AppNotification> notifications);
}
