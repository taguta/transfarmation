import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/data_providers.dart';

/// Watches network connectivity and triggers [SyncService.processQueue]
/// automatically whenever the device comes back online.
class ConnectivitySyncNotifier {
  final Ref _ref;
  StreamSubscription<List<ConnectivityResult>>? _subscription;
  StreamSubscription<User?>? _authSub;
  Timer? _timer;

  /// How often queued changes are pushed while the app is open. Without this
  /// a change saved while online would wait for the next launch.
  static const interval = Duration(seconds: 45);

  ConnectivitySyncNotifier(this._ref);

  void start() {
    _subscription = Connectivity().onConnectivityChanged.listen((results) {
      final isOnline = results.any((r) => r != ConnectivityResult.none);
      if (!_wasOnline && isOnline) {
        _ref.read(syncServiceProvider).processQueue();
      }
      _wasOnline = isOnline;
    });

    // Changes made while signed out wait in the queue: push them on sign-in.
    _authSub = FirebaseAuth.instance.authStateChanges().listen((user) {
      if (user != null) _ref.read(syncServiceProvider).processQueue();
    });

    _timer = Timer.periodic(interval, (_) {
      _ref.read(syncServiceProvider).processQueue();
    });
  }

  bool _wasOnline = true; // assume online at start; processQueue() in initState handles initial flush

  void dispose() {
    _subscription?.cancel();
    _authSub?.cancel();
    _timer?.cancel();
  }
}

final connectivitySyncProvider = Provider<ConnectivitySyncNotifier>((ref) {
  final notifier = ConnectivitySyncNotifier(ref);
  ref.onDispose(notifier.dispose);
  return notifier;
});
