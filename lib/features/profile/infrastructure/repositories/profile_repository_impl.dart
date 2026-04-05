import '../../domain/entities/profile_settings.dart';
import '../../domain/repositories/profile_repository.dart';
import '../datasource/profile_remote_datasource.dart';

class ProfileRepositoryImpl implements ProfileRepository {
  final ProfileRemoteDataSource remoteDataSource;
  final String userId;

  ProfileRepositoryImpl(this.remoteDataSource, this.userId);

  @override
  Future<ProfileSettings> getSettings() async {
    return await remoteDataSource.getSettings(userId);
  }

  @override
  Future<void> updateSettings(ProfileSettings settings) async {
    await remoteDataSource.updateSettings(userId, settings);
  }
}
