import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/providers/data_providers.dart';
import '../../infrastructure/datasource/profile_remote_datasource.dart';
import '../../infrastructure/repositories/profile_repository_impl.dart';
import '../../domain/repositories/profile_repository.dart';
import '../../domain/entities/profile_settings.dart';
import '../../../auth/presentation/providers/auth_providers.dart';

final profileRemoteDataSourceProvider = Provider<ProfileRemoteDataSource>((ref) {
  return ProfileRemoteDataSourceFirestoreImpl(ref.watch(firestoreProvider));
});

final profileRepositoryProvider = Provider<ProfileRepository>((ref) {
  final userId = ref.watch(authStateProvider).valueOrNull?.uid ?? 'guest';
  return ProfileRepositoryImpl(ref.watch(profileRemoteDataSourceProvider), userId);
});

final profileSettingsProvider = FutureProvider<ProfileSettings>((ref) {
  return ref.watch(profileRepositoryProvider).getSettings();
});
