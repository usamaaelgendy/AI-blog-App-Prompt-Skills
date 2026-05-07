abstract class BookmarksEvent {}

class LoadBookmarks extends BookmarksEvent {}

class LoadMoreBookmarks extends BookmarksEvent {}

class RemoveBookmarkFromList extends BookmarksEvent {
  final String postId;
  RemoveBookmarkFromList(this.postId);
}
