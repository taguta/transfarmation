import 'dart:convert';
import 'package:sqflite/sqflite.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/providers/data_providers.dart';

// --- Domain Entity ---
class ForumPost {
  final String id;
  final String author;
  final String region;
  final String title;
  final String content;
  final int replies;
  final List<String> tags;
  final bool isAlert;
  final DateTime time;

  ForumPost({
    required this.id,
    required this.author,
    required this.region,
    required this.title,
    required this.content,
    required this.replies,
    required this.tags,
    required this.isAlert,
    required this.time,
  });
}

// --- Local DataSource ---
class CommunityLocalDataSource {
  final Database db;

  CommunityLocalDataSource(this.db);

  Future<List<ForumPost>> getPosts() async {
    final rows = await db.query('forum_posts', orderBy: 'time DESC');
    return rows.map((r) => ForumPost(
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

  Future<void> savePost(ForumPost post) async {
    await db.insert('forum_posts', {
      'id': post.id,
      'author': post.author,
      'region': post.region,
      'title': post.title,
      'content': post.content,
      'replies': post.replies,
      'tagsData': jsonEncode(post.tags),
      'isAlert': post.isAlert ? 1 : 0,
      'time': post.time.toIso8601String(),
    }, conflictAlgorithm: ConflictAlgorithm.replace);
  }
}

// --- Repository Impl ---
class CommunityRepositoryImpl {
  final CommunityLocalDataSource local;
  final Database db;

  CommunityRepositoryImpl(this.local, this.db);

  Future<List<ForumPost>> getPosts() => local.getPosts();

  Future<void> createPost(ForumPost post) async {
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
        'tagsData': jsonEncode(post.tags),
        'isAlert': post.isAlert ? 1 : 0,
      }),
      'retryCount': 0,
    });
  }
}

// --- Providers ---
final communityRepositoryProvider = Provider<CommunityRepositoryImpl>((ref) {
  final db = ref.watch(databaseProvider);
  return CommunityRepositoryImpl(CommunityLocalDataSource(db), db);
});

final forumPostsProvider = FutureProvider<List<ForumPost>>((ref) async {
  return ref.watch(communityRepositoryProvider).getPosts();
});
