import 'package:cloud_firestore/cloud_firestore.dart';

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

  factory AppNotification.fromJson(Map<String, dynamic> json) {
    return AppNotification(
      id: json['id'],
      title: json['title'],
      body: json['body'],
      type: NotificationType.values.firstWhere((e) => e.name == json['type'], orElse: () => NotificationType.system),
      timestamp: DateTime.parse(json['timestamp']),
      isRead: json['isRead'] == 1 || json['isRead'] == true,
      actionRoute: json['actionRoute'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'body': body,
      'type': type.name,
      'timestamp': timestamp.toIso8601String(),
      'isRead': isRead ? 1 : 0,
      'actionRoute': actionRoute,
    };
  }

  factory AppNotification.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return AppNotification.fromJson({...data, 'id': doc.id});
  }

  Map<String, dynamic> toFirestore() {
    final json = toJson();
    json.remove('id');
    json['isRead'] = isRead;
    return json;
  }
}
