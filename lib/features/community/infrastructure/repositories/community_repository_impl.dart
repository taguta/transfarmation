import 'dart:convert';
import 'package:sqflite/sqflite.dart';
import '../../domain/entities/post.dart';
import '../../domain/repositories/community_repository.dart';
import '../datasource/local/community_sqlite.dart';

class CommunityRepositoryImpl implements CommunityRepository {
  final CommunityLocalDataSource local;
  final Database db;

  CommunityRepositoryImpl({required this.local, required this.db});

  @override
  Future<List<Post>> getPosts() async {
    return await local.getPosts();
  }

  @override
  Future<void> createPost(Post post) async {
    await local.savePost(post);
    await db.insert('sync_queue', {
      'id': post.id,
      'type': 'forum_post',
      'payload': jsonEncode({
        'id': post.id,
        'author': post.author,
        'region': post.region,
        'title': post.title,
        'content': post.content,
        'replies': post.replies,
        'tagsData': jsonEncode(post.tags),
        'isAlert': post.isAlert,
        'time': post.time.toIso8601String(),
      }),
      'retryCount': 0,
    });
  }
}
