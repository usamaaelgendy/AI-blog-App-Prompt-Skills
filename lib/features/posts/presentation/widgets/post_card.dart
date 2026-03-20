import 'package:flutter/material.dart';
import '../../domain/entities/post.dart';

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
        trailing: Text(
          '${post.createdAt.day}/${post.createdAt.month}',
          style: Theme.of(context).textTheme.bodySmall,
        ),
        onTap: () {
          // TODO: Navigate to post details
        },
      ),
    );
  }
}
