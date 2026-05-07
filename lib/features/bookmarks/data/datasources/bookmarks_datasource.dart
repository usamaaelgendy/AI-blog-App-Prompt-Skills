import '../models/bookmark_model.dart';

abstract class BookmarksDataSource {
  Future<List<BookmarkModel>> fetchBookmarks(
    String userId, {
    int offset = 0,
    int limit = 20,
  });
  Future<BookmarkModel> addBookmark(String userId, String postId);
  Future<void> removeBookmark(String userId, String postId);
  Future<bool> isBookmarked(String userId, String postId);
  Future<List<String>> getBookmarkStatuses(
    String userId,
    List<String> postIds,
  );
}
