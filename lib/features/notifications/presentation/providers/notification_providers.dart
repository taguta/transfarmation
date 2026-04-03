import 'package:flutter_riverpod/flutter_riverpod.dart';

enum NotificationType { loan, market, advisory, system }

class AppNotification {
  final String id;
  final String title;
  final String body;
  final NotificationType type;
  final DateTime timestamp;
  final bool isRead;
  final String? actionRoute;

  const AppNotification({
    required this.id,
    required this.title,
    required this.body,
    required this.type,
    required this.timestamp,
    this.isRead = false,
    this.actionRoute,
  });

  AppNotification copyWith({bool? isRead}) => AppNotification(
        id: id,
        title: title,
        body: body,
        type: type,
        timestamp: timestamp,
        isRead: isRead ?? this.isRead,
        actionRoute: actionRoute,
      );
}

class NotificationNotifier extends Notifier<List<AppNotification>> {
  @override
  List<AppNotification> build() => _mockNotifications;

  void markAsRead(String id) {
    state = [
      for (final n in state)
        if (n.id == id) n.copyWith(isRead: true) else n,
    ];
  }

  void markAllRead() {
    state = [for (final n in state) n.copyWith(isRead: true)];
  }

  static final _mockNotifications = [
    AppNotification(
      id: 'n-001',
      title: 'Loan Approved!',
      body: 'Your Maize Input Loan of \$1,200 from AgriFinance ZW has been approved.',
      type: NotificationType.loan,
      timestamp: DateTime.now().subtract(const Duration(hours: 2)),
      actionRoute: '/financing',
    ),
    AppNotification(
      id: 'n-002',
      title: 'New Buyer Offer',
      body: 'A buyer from Harare is interested in your Grade A maize at \$290/ton.',
      type: NotificationType.market,
      timestamp: DateTime.now().subtract(const Duration(hours: 5)),
      actionRoute: '/marketplace',
    ),
    AppNotification(
      id: 'n-003',
      title: 'Rain Forecast — Mashonaland East',
      body: 'Heavy rainfall expected this weekend. Ideal time for top-dressing fertilizer.',
      type: NotificationType.advisory,
      timestamp: DateTime.now().subtract(const Duration(days: 1)),
    ),
    AppNotification(
      id: 'n-004',
      title: 'Repayment Reminder',
      body: 'Your next loan repayment of \$120 is due in 5 days.',
      type: NotificationType.loan,
      timestamp: DateTime.now().subtract(const Duration(days: 1, hours: 3)),
      actionRoute: '/financing/repayments',
    ),
    AppNotification(
      id: 'n-005',
      title: 'Soya Price Up 5.2%',
      body: 'Soya beans market price increased to \$520/ton. Consider selling.',
      type: NotificationType.market,
      timestamp: DateTime.now().subtract(const Duration(days: 2)),
      actionRoute: '/marketplace',
    ),
    AppNotification(
      id: 'n-006',
      title: 'New Loan Offer Available',
      body: 'GreenLeaf Capital is offering 10.5% rates for farms with Credit Score B or above.',
      type: NotificationType.loan,
      timestamp: DateTime.now().subtract(const Duration(days: 3)),
      actionRoute: '/financing/offers',
    ),
    AppNotification(
      id: 'n-007',
      title: 'Welcome to Transfarmation!',
      body: 'Your account has been set up. Start by recording your farm details.',
      type: NotificationType.system,
      timestamp: DateTime.now().subtract(const Duration(days: 7)),
      isRead: true,
      actionRoute: '/farm',
    ),
  ];
}

final notificationProvider =
    NotifierProvider<NotificationNotifier, List<AppNotification>>(
        NotificationNotifier.new);

final unreadCountProvider = Provider<int>((ref) {
  final notifications = ref.watch(notificationProvider);
  return notifications.where((n) => !n.isRead).length;
});
