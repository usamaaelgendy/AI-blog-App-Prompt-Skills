abstract class BookmarkToggleEvent {}

class ToggleBookmarkEvent extends BookmarkToggleEvent {
  final String postId;
  ToggleBookmarkEvent(this.postId);
}

class LoadBookmarkStatuses extends BookmarkToggleEvent {
  final List<String> postIds;
  LoadBookmarkStatuses(this.postIds);
}
