import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/profile_settings.dart';

abstract class ProfileRemoteDataSource {
  Future<ProfileSettings> getSettings(String userId);
  Future<void> updateSettings(String userId, ProfileSettings settings);
}

class ProfileRemoteDataSourceFirestoreImpl implements ProfileRemoteDataSource {
  final FirebaseFirestore firestore;
  ProfileRemoteDataSourceFirestoreImpl(this.firestore);

  @override
  Future<ProfileSettings> getSettings(String userId) async {
    final doc = await firestore.collection('user_profiles').doc(userId).get();
    if (!doc.exists || doc.data() == null) return const ProfileSettings();
    final data = doc.data()!;
    return ProfileSettings(
      pushNotifications: data['pushNotifications'] ?? true,
      smsAlerts: data['smsAlerts'] ?? true,
      emailUpdates: data['emailUpdates'] ?? false,
      language: data['language'] ?? 'English',
    );
  }

  @override
  Future<void> updateSettings(String userId, ProfileSettings settings) async {
    await firestore.collection('user_profiles').doc(userId).set({
      'pushNotifications': settings.pushNotifications,
      'smsAlerts': settings.smsAlerts,
      'emailUpdates': settings.emailUpdates,
      'language': settings.language,
    }, SetOptions(merge: true));
  }
}
