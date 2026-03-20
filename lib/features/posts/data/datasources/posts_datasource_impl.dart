import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/errors/exceptions.dart';
import '../models/post_model.dart';
import 'posts_datasource.dart';

class PostsDataSourceImpl implements PostsDataSource {
  final SupabaseClient _client;

  PostsDataSourceImpl(this._client);

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
  Future<PostModel> fetchPost(String id) async {
    try {
      final response =
          await _client.from('posts').select().eq('id', id).single();
      return PostModel.fromJson(response);
    } on PostgrestException catch (e) {
      throw ServerException(e.message);
    } catch (e) {
      throw ServerException('Unexpected error');
    }
  }

  @override
  Future<void> createPost(Map<String, dynamic> data) async {
    try {
      await _client.from('posts').insert(data);
    } on PostgrestException catch (e) {
      throw ServerException(e.message);
    } catch (e) {
      throw ServerException('Unexpected error');
    }
  }

  @override
  Future<void> deletePost(String id) async {
    try {
      await _client.from('posts').delete().eq('id', id);
    } on PostgrestException catch (e) {
      throw ServerException(e.message);
    } catch (e) {
      throw ServerException('Unexpected error');
    }
  }
}
