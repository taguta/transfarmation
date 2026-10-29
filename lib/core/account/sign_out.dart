import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../providers/data_providers.dart';
import 'account_guard.dart';
import 'local_data_cleaner.dart';

/// Signs out and removes this person's data from the device.
///
/// First tries to send anything still waiting to sync. If some of it cannot be
/// sent (for example there is no signal), the person is told it would be lost
/// and must confirm.
Future<void> signOutAndClear(BuildContext context, WidgetRef ref) async {
  final messenger = ScaffoldMessenger.of(context);
  final router = GoRouter.of(context);
  final db = ref.read(databaseProvider);
  final cleaner = LocalDataCleaner(db);

  try {
    await ref.read(syncServiceProvider).processQueue();
  } catch (_) {}

  final pending = await cleaner.pendingChanges();
  if (pending > 0) {
    if (!context.mounted) return;
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Sign out and lose unsent changes?'),
        content: Text(
          '$pending change${pending == 1 ? '' : 's'} on this phone '
          '${pending == 1 ? 'has' : 'have'} not been sent yet, probably because there is no '
          'signal. If you sign out now, ${pending == 1 ? 'it' : 'they'} will be deleted. '
          'Connect to the internet and try again to keep ${pending == 1 ? 'it' : 'them'}.',
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Stay signed in')),
          FilledButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Sign out anyway')),
        ],
      ),
    );
    if (ok != true) return;
  }

  try {
    // Clear first, so the screens rebuilt after sign-out find an empty database.
    await AccountGuard(cleaner).clearForSignOut();
    await FirebaseAuth.instance.signOut();
    try {
      await GoogleSignIn().signOut();
    } catch (_) {}
    router.go('/login');
    messenger.showSnackBar(const SnackBar(content: Text('Signed out. Data removed from this phone.')));
  } catch (e) {
    messenger.showSnackBar(SnackBar(content: Text('Error signing out: $e')));
  }
}
