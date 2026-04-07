import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/di/injection_container.dart';
import '../bloc/bookmark_toggle_bloc.dart';
import '../bloc/bookmark_toggle_state.dart';
import '../bloc/bookmarks_bloc.dart';
import '../bloc/bookmarks_event.dart';
import '../bloc/bookmarks_state.dart';
import '../widgets/bookmark_icon_button.dart';

class BookmarksScreen extends StatelessWidget {
  const BookmarksScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<BookmarksBloc>()..add(LoadBookmarks()),
      child: const _BookmarksView(),
    );
  }
}

class _BookmarksView extends StatefulWidget {
  const _BookmarksView();

  @override
  State<_BookmarksView> createState() => _BookmarksViewState();
}

class _BookmarksViewState extends State<_BookmarksView> {
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_isBottom) {
      context.read<BookmarksBloc>().add(LoadMoreBookmarks());
    }
  }

  bool get _isBottom {
    if (!_scrollController.hasClients) return false;
    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.offset;
    return currentScroll >= (maxScroll * 0.9);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Bookmarks')),
      body: BlocListener<BookmarkToggleBloc, BookmarkToggleState>(
        listener: (context, toggleState) {
          final bookmarksBloc = context.read<BookmarksBloc>();
          final currentState = bookmarksBloc.state;
          if (currentState is BookmarksLoaded) {
            for (final bookmark in currentState.bookmarks) {
              final isStillBookmarked =
                  toggleState.statuses[bookmark.postId];
              if (isStillBookmarked == false) {
                bookmarksBloc.add(RemoveBookmarkFromList(bookmark.postId));
              }
            }
          }
        },
        child: BlocBuilder<BookmarksBloc, BookmarksState>(
          builder: (context, state) {
            if (state is BookmarksLoading) {
              return const Center(child: CircularProgressIndicator());
            }
            if (state is BookmarksLoaded) {
              if (state.bookmarks.isEmpty) {
                return const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.bookmark_border, size: 64, color: Colors.grey),
                      SizedBox(height: 16),
                      Text(
                        'No saved posts yet',
                        style: TextStyle(fontSize: 18, color: Colors.grey),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Browse posts and tap the bookmark icon to save them',
                        style: TextStyle(color: Colors.grey),
                      ),
                    ],
                  ),
                );
              }
              return ListView.builder(
                controller: _scrollController,
                itemCount: state.hasReachedMax
                    ? state.bookmarks.length
                    : state.bookmarks.length + 1,
                itemBuilder: (context, index) {
                  if (index >= state.bookmarks.length) {
                    return const Center(
                      child: Padding(
                        padding: EdgeInsets.all(16),
                        child: CircularProgressIndicator(),
                      ),
                    );
                  }
                  final bookmark = state.bookmarks[index];
                  return Card(
                    margin:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: ListTile(
                      title: Text(
                        bookmark.post.title,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text(
                        bookmark.post.content,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      trailing: BookmarkIconButton(postId: bookmark.postId),
                      onTap: () {
                        // TODO: Navigate to post details
                      },
                    ),
                  );
                },
              );
            }
            if (state is BookmarksError) {
              return Center(child: Text(state.message));
            }
            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }
}
