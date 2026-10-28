import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/providers/data_providers.dart';
import '../../../auth/presentation/providers/auth_providers.dart';
import '../../domain/loan_application.dart';
import '../../infrastructure/credit_desk_remote_datasource.dart';

final creditDeskRemoteProvider = Provider<CreditDeskRemoteDataSource>(
  (ref) => CreditDeskRemoteDataSource(ref.watch(firestoreProvider)),
);

final pendingApplicationsForLenderProvider = StreamProvider<List<LoanApplication>>(
  (ref) => ref.watch(creditDeskRemoteProvider).watchPending(),
);

final myOffersProvider = StreamProvider<List<Map<String, dynamic>>>((ref) {
  final uid = ref.watch(currentFarmerIdProvider);
  if (uid == null) return const Stream.empty();
  return ref.watch(creditDeskRemoteProvider).watchMyOffers(uid);
});

final decidedApplicationsProvider = StreamProvider<List<LoanApplication>>((ref) {
  final uid = ref.watch(currentFarmerIdProvider);
  if (uid == null) return const Stream.empty();
  return ref.watch(creditDeskRemoteProvider).watchDecidedBy(uid);
});
