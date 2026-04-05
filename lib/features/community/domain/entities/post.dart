class Post {
  final String id;
  final String author;
  final String region;
  final String title;
  final String content;
  final DateTime time;
  final int replies;
  final List<String> tags;
  final bool isAlert;

  const Post({
    required this.id,
    required this.author,
    required this.region,
    required this.title,
    required this.content,
    required this.time,
    required this.replies,
    required this.tags,
    this.isAlert = false,
  });
}
