import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/bookmark.dart';

abstract class BookmarksRepository {
  Future<Either<Failure, List<Bookmark>>> getBookmarks(
    String userId, {
    int offset = 0,
    int limit = 20,
  });
  Future<Either<Failure, Bookmark>> addBookmark(String userId, String postId);
  Future<Either<Failure, void>> removeBookmark(String userId, String postId);
  Future<Either<Failure, bool>> isBookmarked(String userId, String postId);
  Future<Either<Failure, Set<String>>> getBookmarkStatuses(
    String userId,
    List<String> postIds,
  );
}
