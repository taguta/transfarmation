import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/providers/data_providers.dart';
import '../../infrastructure/datasource/community_remote_datasource.dart';
import '../../infrastructure/repositories/community_repository_impl.dart';
import '../../domain/repositories/community_repository.dart';
import '../../domain/entities/post.dart';

final communityRemoteDataSourceProvider = Provider<CommunityRemoteDataSource>((ref) {
  return CommunityRemoteDataSourceFirestoreImpl(ref.watch(firestoreProvider));
});

final communityRepositoryProvider = Provider<CommunityRepository>((ref) {
  return CommunityRepositoryImpl(
    remoteDataSource: ref.watch(communityRemoteDataSourceProvider),
    currentUserId: 'dummy_user_auth_id', 
  );
});

final communityPostsProvider = FutureProvider<List<Post>>((ref) {
  return ref.watch(communityRepositoryProvider).getPosts();
});
