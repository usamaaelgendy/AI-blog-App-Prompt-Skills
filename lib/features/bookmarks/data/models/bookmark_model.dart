import '../../../posts/data/models/post_model.dart';
import '../../domain/entities/bookmark.dart';

class BookmarkModel {
  final String id;
  final String postId;
  final String userId;
  final DateTime createdAt;
  final PostModel? post;

  const BookmarkModel({
    required this.id,
    required this.postId,
    required this.userId,
    required this.createdAt,
    this.post,
  });

  factory BookmarkModel.fromJson(Map<String, dynamic> json) {
    return BookmarkModel(
      id: json['id'] as String,
      postId: json['post_id'] as String,
      userId: json['user_id'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      post: json['posts'] != null
          ? PostModel.fromJson(json['posts'] as Map<String, dynamic>)
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
        'user_id': userId,
        'post_id': postId,
      };

  Bookmark? toEntity() {
    if (post == null) return null;
    return Bookmark(
      id: id,
      postId: postId,
      userId: userId,
      createdAt: createdAt,
      post: post!.toEntity(),
    );
  }
}
