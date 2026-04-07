import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/bookmark.dart';
import '../repositories/bookmarks_repository.dart';

class GetBookmarksParams {
  final String userId;
  final int offset;
  final int limit;

  const GetBookmarksParams({
    required this.userId,
    this.offset = 0,
    this.limit = 20,
  });
}

class GetBookmarks {
  final BookmarksRepository _repository;

  GetBookmarks(this._repository);

  Future<Either<Failure, List<Bookmark>>> call(GetBookmarksParams params) {
    return _repository.getBookmarks(
      params.userId,
      offset: params.offset,
      limit: params.limit,
    );
  }
}
