import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/providers/data_providers.dart';
import '../../../auth/presentation/providers/auth_providers.dart';
import '../../domain/data_share.dart';
import '../../infrastructure/data_share_repository.dart';

final dataShareRepositoryProvider = Provider<DataShareRepository>((ref) {
  return DataShareRepository(ref.watch(databaseProvider));
});

final dataSharesProvider = FutureProvider<List<DataShare>>((ref) {
  final farmerId = ref.watch(activeFarmerIdProvider);
  return ref.watch(dataShareRepositoryProvider).getShares(farmerId);
});
