import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/providers/data_providers.dart';
import '../../domain/entities/ledger_entry.dart';
import '../../infrastructure/repositories/ledger_repository.dart';

final ledgerRepositoryProvider = Provider<LedgerRepository>((ref) {
  return LedgerRepository(ref.watch(databaseProvider));
});

final ledgerEntriesProvider = FutureProvider<List<LedgerEntry>>((ref) {
  return ref.watch(ledgerRepositoryProvider).getEntries();
});
