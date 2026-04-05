import 'dart:convert';
import 'package:sqflite/sqflite.dart';
import '../../domain/entities/profile_settings.dart';
import '../../domain/repositories/profile_repository.dart';
import '../datasource/local/profile_sqlite.dart';

class ProfileRepositoryImpl implements ProfileRepository {
  final ProfileLocalDataSource local;
  final Database db;
  final String userId;

  ProfileRepositoryImpl({required this.local, required this.db, required this.userId});

  @override
  Future<ProfileSettings> getSettings() async {
    return await local.getSettings(userId);
  }

  @override
  Future<void> updateSettings(ProfileSettings settings) async {
    await local.saveSettings(userId, settings);
    await db.insert('sync_queue', {
      'id': 'profile_$userId',
      'type': 'user_profile',
      'payload': jsonEncode({
        'userId': userId,
        'pushNotifications': settings.pushNotifications,
        'smsAlerts': settings.smsAlerts,
        'emailUpdates': settings.emailUpdates,
        'language': settings.language,
      }),
      'retryCount': 0,
    }, conflictAlgorithm: ConflictAlgorithm.replace);
  }
}
