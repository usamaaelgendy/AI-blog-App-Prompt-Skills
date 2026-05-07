import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../domain/repositories/bookmarks_repository.dart';
import '../../domain/usecases/toggle_bookmark.dart';
import 'bookmark_toggle_event.dart';
import 'bookmark_toggle_state.dart';

class BookmarkToggleBloc
    extends Bloc<BookmarkToggleEvent, BookmarkToggleState> {
  final ToggleBookmark _toggleBookmark;
  final BookmarksRepository _bookmarksRepository;

  BookmarkToggleBloc({
    required ToggleBookmark toggleBookmark,
    required BookmarksRepository bookmarksRepository,
  })  : _toggleBookmark = toggleBookmark,
        _bookmarksRepository = bookmarksRepository,
        super(const BookmarkToggleState()) {
    on<ToggleBookmarkEvent>(_onToggleBookmark);
    on<LoadBookmarkStatuses>(_onLoadBookmarkStatuses);
  }

  Future<void> _onToggleBookmark(
    ToggleBookmarkEvent event,
    Emitter<BookmarkToggleState> emit,
  ) async {
    final currentStatus = state.isBookmarked(event.postId);

    // Optimistic update
    final updatedStatuses = Map<String, bool>.from(state.statuses);
    updatedStatuses[event.postId] = !currentStatus;
    emit(state.copyWith(statuses: updatedStatuses));

    final userId = Supabase.instance.client.auth.currentUser?.id;
    if (userId == null) return;

    final result = await _toggleBookmark(
      ToggleBookmarkParams(
        userId: userId,
        postId: event.postId,
        isCurrentlyBookmarked: currentStatus,
      ),
    );

    result.fold(
      (failure) {
        // Revert on failure
        final revertedStatuses = Map<String, bool>.from(state.statuses);
        revertedStatuses[event.postId] = currentStatus;
        emit(state.copyWith(
          statuses: revertedStatuses,
          errorPostId: event.postId,
          errorMessage: failure.message,
        ));
      },
      (_) {
        // Clear any previous error
        emit(state.copyWith(statuses: state.statuses));
      },
    );
  }

  Future<void> _onLoadBookmarkStatuses(
    LoadBookmarkStatuses event,
    Emitter<BookmarkToggleState> emit,
  ) async {
    final userId = Supabase.instance.client.auth.currentUser?.id;
    if (userId == null) return;

    final result = await _bookmarksRepository.getBookmarkStatuses(
      userId,
      event.postIds,
    );

    result.fold(
      (_) {},
      (bookmarkedIds) {
        final updatedStatuses = Map<String, bool>.from(state.statuses);
        for (final postId in event.postIds) {
          updatedStatuses[postId] = bookmarkedIds.contains(postId);
        }
        emit(state.copyWith(statuses: updatedStatuses));
      },
    );
  }
}
