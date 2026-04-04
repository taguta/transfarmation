import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/notification.dart';
import '../../../../core/providers/data_providers.dart';

class NotificationNotifier extends AsyncNotifier<List<AppNotification>> {
  @override
  Future<List<AppNotification>> build() async {
    final repo = ref.watch(notificationRepositoryImplProvider);
    return repo.getNotifications('farmer-001');
  }

  Future<void> markAsRead(String id) async {
    final repo = ref.read(notificationRepositoryImplProvider);
    await repo.markAsRead(id);
    ref.invalidateSelf();
  }

  Future<void> markAllRead() async {
    final repo = ref.read(notificationRepositoryImplProvider);
    await repo.markAllRead();
    ref.invalidateSelf();
  }
}

final notificationProvider =
    AsyncNotifierProvider<NotificationNotifier, List<AppNotification>>(
        NotificationNotifier.new);

final unreadCountProvider = Provider<int>((ref) {
  final notificationsAsync = ref.watch(notificationProvider);
  final notifications = notificationsAsync.value ?? [];
  return notifications.where((n) => !n.isRead).length;
});
