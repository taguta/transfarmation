import 'dart:convert';
import 'package:sqflite/sqflite.dart';
import '../../../domain/entities/post.dart';

class CommunityLocalDataSource {
  final Database db;

  CommunityLocalDataSource(this.db);

  Future<void> savePost(Post post) async {
    await db.insert(
      'forum_posts',
      {
        'id': post.id,
        'author': post.author,
        'region': post.region,
        'title': post.title,
        'content': post.content,
        'replies': post.replies,
        'tagsData': jsonEncode(post.tags),
        'isAlert': post.isAlert ? 1 : 0,
        'time': post.time.toIso8601String(),
        'isSynced': 0,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<Post>> getPosts() async {
    final rows = await db.query('forum_posts', orderBy: 'time DESC');
    return rows.map((r) => Post(
      id: r['id'] as String,
      author: r['author'] as String,
      region: r['region'] as String,
      title: r['title'] as String,
      content: r['content'] as String,
      replies: r['replies'] as int,
      tags: List<String>.from(jsonDecode(r['tagsData'] as String)),
      isAlert: (r['isAlert'] as int) == 1,
      time: DateTime.parse(r['time'] as String),
    )).toList();
  }
}
