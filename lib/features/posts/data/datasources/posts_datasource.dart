import '../models/post_model.dart';

abstract class PostsDataSource {
  Future<List<PostModel>> fetchPosts();
  Future<PostModel> fetchPost(String id);
  Future<void> createPost(Map<String, dynamic> data);
  Future<void> deletePost(String id);
}
