import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/providers/data_providers.dart';
import '../../../auth/presentation/providers/auth_providers.dart';
import '../../domain/escalation.dart';
import '../../domain/expert_application.dart';
import '../../infrastructure/advisory_remote_datasource.dart';

final advisoryRemoteProvider = Provider<AdvisoryRemoteDataSource>(
  (ref) => AdvisoryRemoteDataSource(ref.watch(firestoreProvider)),
);

/// Whether the signed-in user is a verified expert (admin-granted).
final isVerifiedExpertProvider = FutureProvider<bool>((ref) async {
  final uid = ref.watch(currentFarmerIdProvider);
  if (uid == null) return false;
  return ref.watch(advisoryRemoteProvider).isVerifiedExpert(uid);
});

final isVerifiedLenderProvider = FutureProvider<bool>((ref) async {
  final uid = ref.watch(currentFarmerIdProvider);
  if (uid == null) return false;
  return ref.watch(advisoryRemoteProvider).isVerifiedLender(uid);
});

final openEscalationsProvider = StreamProvider<List<Escalation>>(
  (ref) => ref.watch(advisoryRemoteProvider).watchOpen(),
);

final answeredEscalationsProvider = StreamProvider<List<Escalation>>((ref) {
  final uid = ref.watch(currentFarmerIdProvider);
  if (uid == null) return const Stream.empty();
  return ref.watch(advisoryRemoteProvider).watchAnsweredBy(uid);
});

final isAdminProvider = FutureProvider<bool>((ref) async {
  final uid = ref.watch(currentFarmerIdProvider);
  if (uid == null) return false;
  return ref.watch(advisoryRemoteProvider).isAdmin(uid);
});

final myApplicationProvider = StreamProvider<ExpertApplication?>((ref) {
  final uid = ref.watch(currentFarmerIdProvider);
  if (uid == null) return const Stream.empty();
  return ref.watch(advisoryRemoteProvider).watchMyApplication(uid);
});

final pendingApplicationsProvider = StreamProvider<List<ExpertApplication>>(
  (ref) => ref.watch(advisoryRemoteProvider).watchPendingApplications(),
);
