import '../entities/profile_settings.dart';
abstract class ProfileRepository {
  Future<ProfileSettings> getSettings();
  Future<void> updateSettings(ProfileSettings settings);
}
