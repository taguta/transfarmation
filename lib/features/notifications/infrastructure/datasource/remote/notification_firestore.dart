import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../domain/entities/notification.dart';

class NotificationRemoteDataSource {
  final FirebaseFirestore firestore;

  NotificationRemoteDataSource(this.firestore);

  Future<List<AppNotification>> fetchNotifications(String userId) async {
    final query = await firestore
        .collection('Users')
        .doc(userId)
        .collection('Notifications')
        .orderBy('timestamp', descending: true)
        .get();

    return query.docs.map((d) => AppNotification.fromFirestore(d)).toList();
  }

  Future<void> sendNotifications(String userId, List<AppNotification> notifications) async {
    final batch = firestore.batch();
    for (final notify in notifications) {
      final docRef = firestore
          .collection('Users')
          .doc(userId)
          .collection('Notifications')
          .doc(notify.id);
      batch.set(docRef, notify.toFirestore());
    }
    await batch.commit();
  }

  Future<void> markAsRead(String userId, String id) async {
    await firestore
        .collection('Users')
        .doc(userId)
        .collection('Notifications')
        .doc(id)
        .update({'isRead': true});
  }

  Future<void> markAllRead(String userId, List<String> allIds) async {
    final batch = firestore.batch();
    for (final id in allIds) {
      final docRef = firestore
          .collection('Users')
          .doc(userId)
          .collection('Notifications')
          .doc(id);
      batch.update(docRef, {'isRead': true});
    }
    await batch.commit();
  }
}
