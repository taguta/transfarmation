import '../entities/post.dart';
abstract class CommunityRepository {
  Future<List<Post>> getPosts();
  Future<void> createPost(Post post);
}
