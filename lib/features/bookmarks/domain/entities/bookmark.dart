import '../../../posts/domain/entities/post.dart';

class Bookmark {
  final String id;
  final String postId;
  final String userId;
  final DateTime createdAt;
  final Post post;

  const Bookmark({
    required this.id,
    required this.postId,
    required this.userId,
    required this.createdAt,
    required this.post,
  });
}
