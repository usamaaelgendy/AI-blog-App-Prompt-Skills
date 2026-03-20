import 'package:dartz/dartz.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/post.dart';
import '../../domain/repositories/posts_repository.dart';
import '../datasources/posts_datasource.dart';

class PostsRepositoryImpl implements PostsRepository {
  final PostsDataSource _dataSource;

  PostsRepositoryImpl(this._dataSource);

  @override
  Future<Either<Failure, List<Post>>> getPosts() async {
    try {
      final models = await _dataSource.fetchPosts();
      return Right(models.map((m) => m.toEntity()).toList());
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, Post>> getPost(String id) async {
    try {
      final model = await _dataSource.fetchPost(id);
      return Right(model.toEntity());
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, void>> createPost(Map<String, dynamic> data) async {
    try {
      await _dataSource.createPost(data);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, void>> deletePost(String id) async {
    try {
      await _dataSource.deletePost(id);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    }
  }
}
