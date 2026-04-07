import '../../domain/entities/bookmark.dart';

abstract class BookmarksState {}

class BookmarksInitial extends BookmarksState {}

class BookmarksLoading extends BookmarksState {}

class BookmarksLoaded extends BookmarksState {
  final List<Bookmark> bookmarks;
  final bool hasReachedMax;

  BookmarksLoaded(this.bookmarks, {this.hasReachedMax = false});
}

class BookmarksError extends BookmarksState {
  final String message;
  BookmarksError(this.message);
}
