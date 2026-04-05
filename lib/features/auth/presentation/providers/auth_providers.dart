import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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
