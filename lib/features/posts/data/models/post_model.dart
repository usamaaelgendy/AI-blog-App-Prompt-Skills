import '../../domain/entities/post.dart';

class PostModel {
  final String id;
  final String title;
  final String content;
  final String authorId;
  final DateTime createdAt;

  const PostModel({
    required this.id,
    required this.title,
    required this.content,
    required this.authorId,
    required this.createdAt,
  });

  factory PostModel.fromJson(Map<String, dynamic> json) {
    return PostModel(
      id: json['id'] as String,
      title: json['title'] as String,
      content: json['content'] as String,
      authorId: json['author_id'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() => {
        'title': title,
        'content': content,
        'author_id': authorId,
      };

  Post toEntity() => Post(
        id: id,
        title: title,
        content: content,
        authorId: authorId,
        createdAt: createdAt,
      );
}
