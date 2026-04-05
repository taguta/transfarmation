import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/repositories/auth_repository.dart';
import '../../infrastructure/datasource/auth_remote_datasource.dart';
import '../../infrastructure/repositories/auth_repository_impl.dart';

final authDataSourceProvider = Provider<AuthRemoteDataSource>((ref) {
  return AuthRemoteDataSourceFirebaseImpl();
});

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  final dataSource = ref.watch(authDataSourceProvider);
  return AuthRepositoryImpl(dataSource);
});
/// Emits the current [User] whenever Firebase Auth state changes
/// (sign-in, sign-out, token refresh).
final authStateProvider = StreamProvider<User?>((ref) {
  return FirebaseAuth.instance.userChanges();
});

/// The signed-in user's uid, used as farmerId throughout the app.
/// Returns null when no user is signed in.
final currentFarmerIdProvider = Provider<String?>((ref) {
  return ref.watch(authStateProvider).valueOrNull?.uid;
});
