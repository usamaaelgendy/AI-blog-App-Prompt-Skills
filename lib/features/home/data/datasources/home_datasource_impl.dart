import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../posts/data/models/post_model.dart';
import '../models/category_model.dart';
import '../models/tag_model.dart';
import 'home_datasource.dart';

class HomeDataSourceImpl implements HomeDataSource {
  final SupabaseClient _client;

  HomeDataSourceImpl(this._client);

  @override
  Future<List<PostModel>> fetchPosts() async {
    try {
      final response = await _client.from('posts').select();
      return response.map((e) => PostModel.fromJson(e)).toList();
    } on PostgrestException catch (e) {
      throw ServerException(e.message);
    } catch (e) {
      throw ServerException('Unexpected error');
    }
  }

  @override
  Future<List<CategoryModel>> fetchCategories() async {
    try {
      final response = await _client.from('categories').select();
      return response.map((e) => CategoryModel.fromJson(e)).toList();
    } on PostgrestException catch (e) {
      throw ServerException(e.message);
    } catch (e) {
      throw ServerException('Unexpected error');
    }
  }

  @override
  Future<List<TagModel>> fetchTags() async {
    try {
      final response = await _client.from('tags').select();
      return response.map((e) => TagModel.fromJson(e)).toList();
    } on PostgrestException catch (e) {
      throw ServerException(e.message);
    } catch (e) {
      throw ServerException('Unexpected error');
    }
  }
}
