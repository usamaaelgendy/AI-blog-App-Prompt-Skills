import 'package:flutter/material.dart';
import '../../domain/entities/post.dart';
import '../../../bookmarks/presentation/widgets/bookmark_icon_button.dart';

class PostCard extends StatelessWidget {
  final Post post;

  const PostCard({super.key, required this.post});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListTile(
        title: Text(
          post.title,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(
          post.content,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        trailing: BookmarkIconButton(postId: post.id),
        onTap: () {
          // TODO: Navigate to post details
        },
      ),
    );
  }
}
