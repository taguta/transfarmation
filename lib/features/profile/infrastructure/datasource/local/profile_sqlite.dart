import 'dart:convert';
import 'package:sqflite/sqflite.dart';
import '../../../domain/entities/profile_settings.dart';

class ProfileLocalDataSource {
  final Database db;

  ProfileLocalDataSource(this.db);

  Future<ProfileSettings> getSettings(String userId) async {
    final rows = await db.query('farm_profile', where: 'id = ?', whereArgs: [userId]);
    if (rows.isEmpty) {
      return const ProfileSettings(); // Defaults
    }
    
    final dataStr = rows.first['data'] as String;
    final map = jsonDecode(dataStr) as Map<String, dynamic>;
    
    return ProfileSettings(
      pushNotifications: map['pushNotifications'] ?? true,
      smsAlerts: map['smsAlerts'] ?? true,
      emailUpdates: map['emailUpdates'] ?? false,
      language: map['language'] ?? 'English',
    );
  }

  Future<void> saveSettings(String userId, ProfileSettings settings) async {
    final map = {
      'pushNotifications': settings.pushNotifications,
      'smsAlerts': settings.smsAlerts,
      'emailUpdates': settings.emailUpdates,
      'language': settings.language,
    };
    
    await db.insert(
      'farm_profile',
      {
        'id': userId,
        'data': jsonEncode(map),
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }
}
