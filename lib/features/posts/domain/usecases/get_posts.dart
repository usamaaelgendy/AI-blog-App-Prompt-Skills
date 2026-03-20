import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/post.dart';
import '../repositories/posts_repository.dart';

class GetPosts {
  final PostsRepository _repository;

  GetPosts(this._repository);

  Future<Either<Failure, List<Post>>> call() {
    return _repository.getPosts();
  }
}
