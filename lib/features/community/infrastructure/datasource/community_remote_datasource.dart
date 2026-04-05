import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/post.dart';

abstract class CommunityRemoteDataSource {
  Future<List<Post>> getPosts();
  Future<void> createPost(Post post, String authorId);
}

class CommunityRemoteDataSourceFirestoreImpl implements CommunityRemoteDataSource {
  final FirebaseFirestore firestore;
  CommunityRemoteDataSourceFirestoreImpl(this.firestore);

  @override
  Future<List<Post>> getPosts() async {
    final snapshot = await firestore.collection('community_posts')
        .orderBy('timestamp', descending: true)
        .limit(20)
        .get();

    return snapshot.docs.map((doc) {
      final data = doc.data();
      return Post(
        id: doc.id,
        author: data['authorName'] ?? 'Community Member',
        region: data['region'] ?? 'Global',
        title: data['title'] ?? 'Untitled Topic',
        content: data['content'] ?? '',
        time: (data['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now(),
        replies: data['comments'] ?? 0,
        tags: List<String>.from(data['tags'] ?? ['general']),
        isAlert: data['isAlert'] ?? false,
      );
    }).toList();
  }

  @override
  Future<void> createPost(Post post, String authorId) async {
    await firestore.collection('community_posts').add({
      'authorId': authorId,
      'authorName': post.author, 
      'region': post.region,
      'title': post.title,
      'content': post.content,
      'timestamp': FieldValue.serverTimestamp(),
      'tags': post.tags,
      'isAlert': post.isAlert,
      'comments': 0,
    });
  }
}
