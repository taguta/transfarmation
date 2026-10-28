import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/savings_group.dart';

import '../../../../core/providers/data_providers.dart';
import '../../../auth/presentation/providers/auth_providers.dart';

final savingsGroupsProvider = FutureProvider<List<SavingsGroup>>((ref) async {
  final repo = ref.watch(savingsRepositoryImplProvider);
  return repo.getGroups(ref.watch(activeFarmerIdProvider));
});

final savingsTransactionsProvider = FutureProvider<List<SavingsTransaction>>((ref) async {
  final repo = ref.watch(savingsRepositoryImplProvider);
  return repo.getTransactions('sg-001');
});
