import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:sqflite/sqflite.dart' show Database, databaseFactory;
import 'package:sqflite_common_ffi_web/sqflite_ffi_web.dart';

import 'firebase_options.dart';

import 'core/account/account_guard.dart';
import 'core/account/local_data_cleaner.dart';
import 'core/providers/data_providers.dart';
import 'core/router/app_router.dart';
import 'core/sync/connectivity_sync_notifier.dart';
import 'core/utils/app_prefs.dart';
import 'theme/app_colors.dart' show Palette;
import 'theme/app_theme.dart';
import 'theme/theme_provider.dart';
import 'features/farm_records/infrastructure/datasource/local/farm_sqlite.dart';
import 'features/financing/infrastructure/datasource/local/loan_sqlite.dart';
import 'core/database/data_seeder.dart';


void main() async {
  final widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);

  await Hive.initFlutter();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  if (kIsWeb) databaseFactory = databaseFactoryFfiWeb;
  final db = await initDatabase();
  // Demo farm and loans exist only for guest browsing (REQUIRE_AUTH=false).
  // A signed-in farmer never sees them, and production builds do not create them.
  if (!requireAuth) {
    await DataSeeder(db, FarmLocalDataSource(db), LoanLocalDataSource(db)).seedIfEmpty();
  }

  // If a different person signed in since this device last held data, clear the
  // previous person's data before any screen can read it.
  final guard = AccountGuard(LocalDataCleaner(db));
  String? startUid;
  try {
    startUid = (await FirebaseAuth.instance
            .authStateChanges()
            .first
            .timeout(const Duration(seconds: 5)))
        ?.uid;
  } catch (_) {}
  await guard.reconcile(startUid);
  if (startUid != null) await AppPrefs.markOnboardingSeen();

  FlutterNativeSplash.remove();

  runApp(AccountScope(db: db, initialUid: startUid));
}

/// Hosts the app's providers and rebuilds them whenever a signed-in person
/// leaves (sign-out or switching accounts), so no screen keeps the previous
/// person's data in memory. Going from signed out to signed in does not reset
/// anything, which keeps sign-up and sign-in flows intact.
class AccountScope extends StatefulWidget {
  final Database db;
  final String? initialUid;
  const AccountScope({super.key, required this.db, required this.initialUid});

  @override
  State<AccountScope> createState() => _AccountScopeState();
}

class _AccountScopeState extends State<AccountScope> {
  int _epoch = 0;
  String? _uid;
  StreamSubscription<User?>? _sub;
  late final AccountGuard _guard = AccountGuard(LocalDataCleaner(widget.db));

  @override
  void initState() {
    super.initState();
    _uid = widget.initialUid;
    _sub = FirebaseAuth.instance.authStateChanges().listen(_onAuth);
  }

  Future<void> _onAuth(User? user) async {
    final uid = user?.uid;
    if (uid == _uid) return;
    final previous = _uid;
    _uid = uid;
    final cleared = await _guard.reconcile(uid);
    if (uid != null) await AppPrefs.markOnboardingSeen();
    if ((previous != null || cleared) && mounted) setState(() => _epoch++);
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ProviderScope(
      key: ValueKey(_epoch),
      overrides: [databaseProvider.overrideWithValue(widget.db)],
      child: const TransfarmationApp(),
    );
  }
}

class TransfarmationApp extends ConsumerStatefulWidget {
  const TransfarmationApp({super.key});

  @override
  ConsumerState<TransfarmationApp> createState() => _TransfarmationAppState();
}

class _TransfarmationAppState extends ConsumerState<TransfarmationApp> {
  @override
  void initState() {
    super.initState();
    // Start watching network connectivity and auto-syncing on reconnect.
    ref.read(connectivitySyncProvider).start();
    // Start real-time Firestore → SQLite listeners (self-starts on auth sign-in).
    ref.read(firestoreListenerProvider).start();
    // Flush any pending queue items accumulated while the app was closed.
    ref.read(syncServiceProvider).processQueue();
  }

  @override
  Widget build(BuildContext context) {
    final themeMode = ref.watch(themeModeProvider);
    final router = ref.watch(appRouterProvider);

    return MaterialApp.router(
      title: 'Transfarmation',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: themeMode,
      routerConfig: router,
      builder: (context, child) {
        final dark = Theme.of(context).brightness == Brightness.dark;
        if (Palette.dark != dark) {
          Palette.dark = dark;
          // Screens read Palette directly and many are const, so they would
          // not repaint on their own: ask every element to rebuild.
          WidgetsBinding.instance.addPostFrameCallback(
            (_) => WidgetsBinding.instance.reassembleApplication(),
          );
        }
        return child ?? const SizedBox.shrink();
      },
    );
  }
}
