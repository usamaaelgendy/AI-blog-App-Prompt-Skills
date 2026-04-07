import 'package:dartz/dartz.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/bookmark.dart';
import '../../domain/repositories/bookmarks_repository.dart';
import '../datasources/bookmarks_datasource.dart';

class BookmarksRepositoryImpl implements BookmarksRepository {
  final BookmarksDataSource _dataSource;

  BookmarksRepositoryImpl(this._dataSource);

  @override
  Future<Either<Failure, List<Bookmark>>> getBookmarks(
    String userId, {
    int offset = 0,
    int limit = 20,
  }) async {
    try {
      final models = await _dataSource.fetchBookmarks(
        userId,
        offset: offset,
        limit: limit,
      );
      final bookmarks = models
          .map((m) => m.toEntity())
          .where((b) => b != null)
          .cast<Bookmark>()
          .toList();
      return Right(bookmarks);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, Bookmark>> addBookmark(
    String userId,
    String postId,
  ) async {
    try {
      final model = await _dataSource.addBookmark(userId, postId);
      final entity = model.toEntity();
      if (entity == null) {
        return const Left(ServerFailure('Failed to create bookmark'));
      }
      return Right(entity);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, void>> removeBookmark(
    String userId,
    String postId,
  ) async {
    try {
      await _dataSource.removeBookmark(userId, postId);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, bool>> isBookmarked(
    String userId,
    String postId,
  ) async {
    try {
      final result = await _dataSource.isBookmarked(userId, postId);
      return Right(result);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, Set<String>>> getBookmarkStatuses(
    String userId,
    List<String> postIds,
  ) async {
    try {
      final result = await _dataSource.getBookmarkStatuses(userId, postIds);
      return Right(result.toSet());
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    }
  }
}
