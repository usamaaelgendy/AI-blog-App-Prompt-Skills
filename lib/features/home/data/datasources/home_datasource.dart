import '../../../posts/data/models/post_model.dart';
import '../models/category_model.dart';
import '../models/tag_model.dart';

abstract class HomeDataSource {
  Future<List<PostModel>> fetchPosts();
  Future<List<CategoryModel>> fetchCategories();
  Future<List<TagModel>> fetchTags();
}
