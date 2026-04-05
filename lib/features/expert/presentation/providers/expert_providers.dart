import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/providers/data_providers.dart';
import '../../domain/entities/expert_entity.dart';
import '../../domain/repositories/expert_repository.dart';
import '../../infrastructure/datasource/local/expert_sqlite.dart';
import '../../infrastructure/repositories/expert_repository_impl.dart';

final expertDataSourceProvider = Provider<ExpertLocalDataSource>((ref) {
  final db = ref.watch(databaseProvider);
  return ExpertLocalDataSource(db);
});

final expertRepositoryProvider = Provider<ExpertRepository>((ref) {
  final dataSource = ref.watch(expertDataSourceProvider);
  return ExpertRepositoryImpl(dataSource);
});

final expertsProvider = FutureProvider.family<List<ExpertEntity>, String?>((ref, specialization) {
  final repository = ref.watch(expertRepositoryProvider);
  return repository.getExperts(specialization: specialization);
});
