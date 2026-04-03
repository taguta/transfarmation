import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'core/providers/data_providers.dart';
import 'core/router/app_router.dart';
import 'core/sync/connectivity_sync_notifier.dart';
import 'core/sync/firestore_listener.dart';
import 'theme/app_theme.dart';
import 'theme/theme_provider.dart';
import 'features/farm_records/infrastructure/datasource/local/farm_sqlite.dart';
import 'features/financing/infrastructure/datasource/local/loan_sqlite.dart';
import 'core/database/data_seeder.dart';


void main() async {
  final widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);

  await Hive.initFlutter();
  // Run `flutterfire configure` to generate lib/firebase_options.dart, then replace
  // the line below with:
  //   await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await Firebase.initializeApp();
  final db = await initDatabase();
  await DataSeeder(db, FarmLocalDataSource(db), LoanLocalDataSource(db)).seedIfEmpty();

  FlutterNativeSplash.remove();


  runApp(
    ProviderScope(
      overrides: [
        databaseProvider.overrideWithValue(db),
      ],
      child: const TransfarmationApp(),
    ),
  );
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
    );
  }
}
