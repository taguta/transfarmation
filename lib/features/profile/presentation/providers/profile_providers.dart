import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/providers/data_providers.dart';
import '../../infrastructure/datasource/local/profile_sqlite.dart';
import '../../infrastructure/repositories/profile_repository_impl.dart';
import '../../domain/repositories/profile_repository.dart';
import '../../domain/entities/profile_settings.dart';
import '../../../auth/presentation/providers/auth_providers.dart';

final profileLocalDataSourceProvider = Provider<ProfileLocalDataSource>((ref) {
  return ProfileLocalDataSource(ref.watch(databaseProvider));
});

final profileRepositoryProvider = Provider<ProfileRepository>((ref) {
  final userId = ref.watch(authStateProvider).valueOrNull?.uid ?? 'guest';
  return ProfileRepositoryImpl(
    local: ref.watch(profileLocalDataSourceProvider),
    db: ref.watch(databaseProvider),
    userId: userId,
  );
});

final profileSettingsProvider = FutureProvider<ProfileSettings>((ref) {
  return ref.watch(profileRepositoryProvider).getSettings();
});
