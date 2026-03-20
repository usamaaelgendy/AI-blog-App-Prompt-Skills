class Post {
  final String id;
  final String title;
  final String content;
  final String authorId;
  final DateTime createdAt;

  const Post({
    required this.id,
    required this.title,
    required this.content,
    required this.authorId,
    required this.createdAt,
  });
}
