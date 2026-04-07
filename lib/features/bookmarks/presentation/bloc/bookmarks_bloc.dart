import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../domain/usecases/get_bookmarks.dart';
import 'bookmarks_event.dart';
import 'bookmarks_state.dart';

class BookmarksBloc extends Bloc<BookmarksEvent, BookmarksState> {
  final GetBookmarks _getBookmarks;
  static const _pageSize = 20;

  BookmarksBloc({required GetBookmarks getBookmarks})
      : _getBookmarks = getBookmarks,
        super(BookmarksInitial()) {
    on<LoadBookmarks>(_onLoadBookmarks);
    on<LoadMoreBookmarks>(_onLoadMoreBookmarks);
    on<RemoveBookmarkFromList>(_onRemoveBookmarkFromList);
  }

  Future<void> _onLoadBookmarks(
    LoadBookmarks event,
    Emitter<BookmarksState> emit,
  ) async {
    emit(BookmarksLoading());

    final userId = Supabase.instance.client.auth.currentUser?.id;
    if (userId == null) {
      emit(BookmarksError('User not authenticated'));
      return;
    }

    final result = await _getBookmarks(
      GetBookmarksParams(userId: userId, offset: 0, limit: _pageSize),
    );

    result.fold(
      (failure) => emit(BookmarksError(failure.message)),
      (bookmarks) => emit(BookmarksLoaded(
        bookmarks,
        hasReachedMax: bookmarks.length < _pageSize,
      )),
    );
  }

  Future<void> _onLoadMoreBookmarks(
    LoadMoreBookmarks event,
    Emitter<BookmarksState> emit,
  ) async {
    final currentState = state;
    if (currentState is! BookmarksLoaded || currentState.hasReachedMax) return;

    final userId = Supabase.instance.client.auth.currentUser?.id;
    if (userId == null) return;

    final result = await _getBookmarks(
      GetBookmarksParams(
        userId: userId,
        offset: currentState.bookmarks.length,
        limit: _pageSize,
      ),
    );

    result.fold(
      (failure) => emit(BookmarksError(failure.message)),
      (newBookmarks) => emit(BookmarksLoaded(
        [...currentState.bookmarks, ...newBookmarks],
        hasReachedMax: newBookmarks.length < _pageSize,
      )),
    );
  }

  void _onRemoveBookmarkFromList(
    RemoveBookmarkFromList event,
    Emitter<BookmarksState> emit,
  ) {
    final currentState = state;
    if (currentState is! BookmarksLoaded) return;

    final updatedBookmarks = currentState.bookmarks.where((b) => b.postId != event.postId).toList();

    emit(BookmarksLoaded(
      updatedBookmarks,
      hasReachedMax: currentState.hasReachedMax,
    ));
  }
}
