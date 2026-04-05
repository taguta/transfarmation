import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/providers/data_providers.dart';
import '../../infrastructure/datasource/local/community_sqlite.dart';
import '../../infrastructure/repositories/community_repository_impl.dart';
import '../../domain/repositories/community_repository.dart';
import '../../domain/entities/post.dart';

final communityLocalDataSourceProvider = Provider<CommunityLocalDataSource>((ref) {
  return CommunityLocalDataSource(ref.watch(databaseProvider));
});

final communityRepositoryProvider = Provider<CommunityRepository>((ref) {
  return CommunityRepositoryImpl(
    local: ref.watch(communityLocalDataSourceProvider),
    db: ref.watch(databaseProvider),
  );
});

final communityPostsProvider = FutureProvider<List<Post>>((ref) {
  return ref.watch(communityRepositoryProvider).getPosts();
});
