import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../repositories/bookmarks_repository.dart';

class IsBookmarkedParams {
  final String userId;
  final String postId;

  const IsBookmarkedParams({
    required this.userId,
    required this.postId,
  });
}

class IsBookmarked {
  final BookmarksRepository _repository;

  IsBookmarked(this._repository);

  Future<Either<Failure, bool>> call(IsBookmarkedParams params) {
    return _repository.isBookmarked(params.userId, params.postId);
  }
}
