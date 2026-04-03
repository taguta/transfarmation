import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sqflite/sqflite.dart';

import '../database/sqlite_service.dart'; // SqliteService.init()
import '../database/data_seeder.dart';


// Loan
import '../../features/financing/infrastructure/datasource/local/loan_sqlite.dart';
import '../../features/financing/infrastructure/datasource/remote/loan_firestore.dart';
import '../../features/financing/infrastructure/repositories/loan_repository_impl.dart';
import '../sync/sync_service.dart';
import '../sync/firestore_listener.dart';

// Farm records
import '../../features/farm_records/infrastructure/datasource/local/farm_sqlite.dart';
import '../../features/farm_records/infrastructure/datasource/remote/farm_firestore.dart';
import '../../features/farm_records/infrastructure/repositories/farm_repository_impl.dart';

// Savings
import '../../features/savings/infrastructure/datasource/local/savings_sqlite.dart';
import '../../features/savings/infrastructure/datasource/remote/savings_firestore.dart';
import '../../features/savings/infrastructure/repositories/savings_repository_impl.dart';

// Group buying
import '../../features/group_buying/infrastructure/datasource/local/group_buying_sqlite.dart';
import '../../features/group_buying/infrastructure/datasource/remote/group_buying_firestore.dart';
import '../../features/group_buying/infrastructure/repositories/group_buying_repository_impl.dart';

// Contracts
import '../../features/contracts/infrastructure/datasource/local/contract_sqlite.dart';
import '../../features/contracts/infrastructure/datasource/remote/contract_firestore.dart';
import '../../features/contracts/infrastructure/repositories/contract_repository_impl.dart';

// Diagnosis
import '../../features/diagnosis/infrastructure/datasource/local/diagnosis_sqlite.dart';
import '../../features/diagnosis/infrastructure/datasource/remote/diagnosis_firestore.dart';
import '../../features/diagnosis/infrastructure/repositories/diagnosis_repository_impl.dart';

// Inputs
import '../../features/inputs/infrastructure/datasource/local/input_sqlite.dart';
import '../../features/inputs/infrastructure/datasource/remote/input_firestore.dart';
import '../../features/inputs/infrastructure/repositories/input_repository_impl.dart';

// Market prices
import '../../features/market_prices/infrastructure/datasource/local/commodity_sqlite.dart';
import '../../features/market_prices/infrastructure/datasource/remote/commodity_firestore.dart';
import '../../features/market_prices/infrastructure/repositories/market_price_repository_impl.dart';

// Weather
import '../../features/weather/infrastructure/datasource/local/weather_sqlite.dart';
import '../../features/weather/infrastructure/datasource/remote/weather_firestore.dart';
import '../../features/weather/infrastructure/repositories/weather_repository_impl.dart';

// ── Core infrastructure providers ──────────────────────────

/// The app-wide SQLite database instance.
/// Must be initialised before use (via ProviderScope override or .init()).
final databaseProvider = Provider<Database>((ref) {
  throw UnimplementedError(
    'databaseProvider must be overridden with a real Database instance at startup.',
  );
});

/// The Firestore instance (uses default Firebase app).
final firestoreProvider = Provider<FirebaseFirestore>((ref) {
  return FirebaseFirestore.instance;
});

/// Initialises the SQLite database and returns the Database instance.
/// Call this once at app startup and override databaseProvider.
Future<Database> initDatabase() => SqliteService.init();

final dataSeederProvider = Provider<DataSeeder>((ref) {
  return DataSeeder(
    ref.watch(databaseProvider),
    ref.watch(farmLocalDataSourceProvider),
    ref.watch(loanLocalDataSourceProvider),
  );
});

// ── Loan ────────────────────────────────────────────────────


final loanLocalDataSourceProvider = Provider<LoanLocalDataSource>((ref) {
  return LoanLocalDataSource(ref.watch(databaseProvider));
});

final loanRemoteDataSourceProvider = Provider<LoanRemoteDataSource>((ref) {
  return LoanRemoteDataSource(ref.watch(firestoreProvider));
});

final loanRepositoryImplProvider = Provider<LoanRepositoryImpl>((ref) {
  return LoanRepositoryImpl(
    ref.watch(loanLocalDataSourceProvider),
    ref.watch(loanRemoteDataSourceProvider),
    ref.watch(databaseProvider),
  );
});

// ── Sync service ────────────────────────────────────────────

final syncServiceProvider = Provider<SyncService>((ref) {
  return SyncService(
    ref.watch(databaseProvider),
    ref.watch(loanRemoteDataSourceProvider),
    ref.watch(firestoreProvider),
  );
});

final firestoreListenerProvider = Provider<FirestoreListener>((ref) {
  final listener = FirestoreListener(
    ref.watch(firestoreProvider),
    ref.watch(databaseProvider),
  );
  ref.onDispose(listener.dispose);
  return listener;
});

// ── Farm records ────────────────────────────────────────────

final farmLocalDataSourceProvider = Provider<FarmLocalDataSource>((ref) {
  return FarmLocalDataSource(ref.watch(databaseProvider));
});

final farmRemoteDataSourceProvider = Provider<FarmRemoteDataSource>((ref) {
  return FarmRemoteDataSource(ref.watch(firestoreProvider));
});

final farmRepositoryImplProvider = Provider<FarmRepositoryImpl>((ref) {
  return FarmRepositoryImpl(
    ref.watch(farmLocalDataSourceProvider),
    ref.watch(farmRemoteDataSourceProvider),
    ref.watch(databaseProvider),
  );
});

// ── Savings ─────────────────────────────────────────────────

final savingsLocalDataSourceProvider = Provider<SavingsLocalDataSource>((ref) {
  return SavingsLocalDataSource(ref.watch(databaseProvider));
});

final savingsRemoteDataSourceProvider = Provider<SavingsRemoteDataSource>((
  ref,
) {
  return SavingsRemoteDataSource(ref.watch(firestoreProvider));
});

final savingsRepositoryImplProvider = Provider<SavingsRepositoryImpl>((ref) {
  return SavingsRepositoryImpl(
    ref.watch(savingsLocalDataSourceProvider),
    ref.watch(savingsRemoteDataSourceProvider),
    ref.watch(databaseProvider),
  );
});

// ── Group buying ────────────────────────────────────────────

final groupBuyingLocalDataSourceProvider = Provider<GroupBuyingLocalDataSource>(
  (ref) {
    return GroupBuyingLocalDataSource(ref.watch(databaseProvider));
  },
);

final groupBuyingRemoteDataSourceProvider =
    Provider<GroupBuyingRemoteDataSource>((ref) {
      return GroupBuyingRemoteDataSource(ref.watch(firestoreProvider));
    });

final groupBuyingRepositoryImplProvider = Provider<GroupBuyingRepositoryImpl>((
  ref,
) {
  return GroupBuyingRepositoryImpl(
    ref.watch(groupBuyingLocalDataSourceProvider),
    ref.watch(groupBuyingRemoteDataSourceProvider),
    ref.watch(databaseProvider),
  );
});

// ── Contracts ───────────────────────────────────────────────

final contractLocalDataSourceProvider = Provider<ContractLocalDataSource>((
  ref,
) {
  return ContractLocalDataSource(ref.watch(databaseProvider));
});

final contractRemoteDataSourceProvider = Provider<ContractRemoteDataSource>((
  ref,
) {
  return ContractRemoteDataSource(ref.watch(firestoreProvider));
});

final contractRepositoryImplProvider = Provider<ContractRepositoryImpl>((ref) {
  return ContractRepositoryImpl(
    ref.watch(contractLocalDataSourceProvider),
    ref.watch(contractRemoteDataSourceProvider),
    ref.watch(databaseProvider),
  );
});

// ── Diagnosis ───────────────────────────────────────────────

final diagnosisLocalDataSourceProvider = Provider<DiagnosisLocalDataSource>((
  ref,
) {
  return DiagnosisLocalDataSource(ref.watch(databaseProvider));
});

final diagnosisRemoteDataSourceProvider = Provider<DiagnosisRemoteDataSource>((
  ref,
) {
  return DiagnosisRemoteDataSource(ref.watch(firestoreProvider));
});

final diagnosisRepositoryImplProvider = Provider<DiagnosisRepositoryImpl>((
  ref,
) {
  return DiagnosisRepositoryImpl(
    ref.watch(diagnosisLocalDataSourceProvider),
    ref.watch(diagnosisRemoteDataSourceProvider),
    ref.watch(databaseProvider),
  );
});

// ── Inputs ──────────────────────────────────────────────────

final inputLocalDataSourceProvider = Provider<InputLocalDataSource>((ref) {
  return InputLocalDataSource(ref.watch(databaseProvider));
});

final inputRemoteDataSourceProvider = Provider<InputRemoteDataSource>((ref) {
  return InputRemoteDataSource(ref.watch(firestoreProvider));
});

final inputRepositoryImplProvider = Provider<InputRepositoryImpl>((ref) {
  return InputRepositoryImpl(
    ref.watch(inputLocalDataSourceProvider),
    ref.watch(inputRemoteDataSourceProvider),
    ref.watch(databaseProvider),
  );
});

// ── Market prices ───────────────────────────────────────────

final commodityLocalDataSourceProvider = Provider<CommodityLocalDataSource>((
  ref,
) {
  return CommodityLocalDataSource(ref.watch(databaseProvider));
});

final commodityRemoteDataSourceProvider = Provider<CommodityRemoteDataSource>((
  ref,
) {
  return CommodityRemoteDataSource(ref.watch(firestoreProvider));
});

final marketPriceRepositoryImplProvider = Provider<MarketPriceRepositoryImpl>((
  ref,
) {
  return MarketPriceRepositoryImpl(
    ref.watch(commodityLocalDataSourceProvider),
    ref.watch(commodityRemoteDataSourceProvider),
  );
});

// ── Weather ─────────────────────────────────────────────────

final weatherLocalDataSourceProvider = Provider<WeatherLocalDataSource>((ref) {
  return WeatherLocalDataSource(ref.watch(databaseProvider));
});

final weatherRemoteDataSourceProvider = Provider<WeatherRemoteDataSource>((
  ref,
) {
  return WeatherRemoteDataSource(ref.watch(firestoreProvider));
});

final weatherRepositoryImplProvider = Provider<WeatherRepositoryImpl>((ref) {
  return WeatherRepositoryImpl(
    ref.watch(weatherLocalDataSourceProvider),
    ref.watch(weatherRemoteDataSourceProvider),
  );
});
