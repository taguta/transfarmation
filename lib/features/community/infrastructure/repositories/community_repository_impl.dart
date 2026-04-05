import '../../domain/entities/post.dart';
import '../../domain/repositories/community_repository.dart';
import '../datasource/community_remote_datasource.dart';

class CommunityRepositoryImpl implements CommunityRepository {
  final CommunityRemoteDataSource remoteDataSource;
  final String currentUserId;

  CommunityRepositoryImpl({required this.remoteDataSource, required this.currentUserId});

  @override
  Future<List<Post>> getPosts() async => await remoteDataSource.getPosts();

  @override
  Future<void> createPost(Post post) async => await remoteDataSource.createPost(post, currentUserId);
}
