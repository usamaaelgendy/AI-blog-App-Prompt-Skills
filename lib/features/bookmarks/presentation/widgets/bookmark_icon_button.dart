import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../auth/presentation/screens/login_screen.dart';
import '../bloc/bookmark_toggle_bloc.dart';
import '../bloc/bookmark_toggle_event.dart';
import '../bloc/bookmark_toggle_state.dart';

class BookmarkIconButton extends StatelessWidget {
  final String postId;

  const BookmarkIconButton({super.key, required this.postId});

  @override
  Widget build(BuildContext context) {
    return BlocListener<BookmarkToggleBloc, BookmarkToggleState>(
      listenWhen: (previous, current) =>
          current.errorPostId == postId && current.errorMessage != null,
      listener: (context, state) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(state.errorMessage!)),
        );
      },
      child: BlocBuilder<BookmarkToggleBloc, BookmarkToggleState>(
        buildWhen: (previous, current) =>
            previous.isBookmarked(postId) != current.isBookmarked(postId),
        builder: (context, state) {
          final isBookmarked = state.isBookmarked(postId);
          return IconButton(
            icon: Icon(
              isBookmarked ? Icons.bookmark : Icons.bookmark_border,
              color: isBookmarked
                  ? Theme.of(context).colorScheme.primary
                  : null,
            ),
            onPressed: () => _onPressed(context),
          );
        },
      ),
    );
  }

  void _onPressed(BuildContext context) {
    final currentUser = Supabase.instance.client.auth.currentUser;
    if (currentUser == null) {
      Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => const LoginScreen()),
      );
      return;
    }
    context.read<BookmarkToggleBloc>().add(ToggleBookmarkEvent(postId));
  }
}
