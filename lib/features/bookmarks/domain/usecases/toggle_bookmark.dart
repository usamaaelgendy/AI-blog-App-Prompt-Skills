import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../repositories/bookmarks_repository.dart';

class ToggleBookmarkParams {
  final String userId;
  final String postId;
  final bool isCurrentlyBookmarked;

  const ToggleBookmarkParams({
    required this.userId,
    required this.postId,
    required this.isCurrentlyBookmarked,
  });
}

class ToggleBookmark {
  final BookmarksRepository _repository;

  ToggleBookmark(this._repository);

  Future<Either<Failure, void>> call(ToggleBookmarkParams params) {
    if (params.isCurrentlyBookmarked) {
      return _repository.removeBookmark(params.userId, params.postId);
    } else {
      return _repository.addBookmark(params.userId, params.postId).then(
            (result) => result.fold(
              (failure) => Left(failure),
              (_) => const Right(null),
            ),
          );
    }
  }
}
