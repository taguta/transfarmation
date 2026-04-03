import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/data_providers.dart';

/// Watches network connectivity and triggers [SyncService.processQueue]
/// automatically whenever the device comes back online.
class ConnectivitySyncNotifier {
  final Ref _ref;
  StreamSubscription<List<ConnectivityResult>>? _subscription;

  ConnectivitySyncNotifier(this._ref);

  void start() {
    _subscription = Connectivity().onConnectivityChanged.listen((results) {
      final isOnline = results.any((r) => r != ConnectivityResult.none);
      if (!_wasOnline && isOnline) {
        _ref.read(syncServiceProvider).processQueue();
      }
      _wasOnline = isOnline;
    });
  }

  bool _wasOnline = true; // assume online at start; processQueue() in initState handles initial flush

  void dispose() {
    _subscription?.cancel();
  }
}

final connectivitySyncProvider = Provider<ConnectivitySyncNotifier>((ref) {
  final notifier = ConnectivitySyncNotifier(ref);
  ref.onDispose(notifier.dispose);
  return notifier;
});
