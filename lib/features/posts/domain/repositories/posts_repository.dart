import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/post.dart';

abstract class PostsRepository {
  Future<Either<Failure, List<Post>>> getPosts();
  Future<Either<Failure, Post>> getPost(String id);
  Future<Either<Failure, void>> createPost(Map<String, dynamic> data);
  Future<Either<Failure, void>> deletePost(String id);
}
