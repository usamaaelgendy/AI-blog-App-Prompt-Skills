import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/errors/exceptions.dart';
import '../models/bookmark_model.dart';
import 'bookmarks_datasource.dart';

class BookmarksDataSourceImpl implements BookmarksDataSource {
  final SupabaseClient _client;

  BookmarksDataSourceImpl(this._client);

  @override
  Future<List<BookmarkModel>> fetchBookmarks(
    String userId, {
    int offset = 0,
    int limit = 20,
  }) async {
    try {
      final response = await _client
          .from('bookmarks')
          .select('*, posts(*)')
          .eq('user_id', userId)
          .order('created_at', ascending: false)
          .range(offset, offset + limit - 1);
      return response.map((e) => BookmarkModel.fromJson(e)).toList();
    } on PostgrestException catch (e) {
      throw ServerException(e.message);
    } catch (e) {
      throw ServerException('Unexpected error');
    }
  }

  @override
  Future<BookmarkModel> addBookmark(String userId, String postId) async {
    try {
      final response = await _client
          .from('bookmarks')
          .insert({'user_id': userId, 'post_id': postId})
          .select('*, posts(*)')
          .single();
      return BookmarkModel.fromJson(response);
    } on PostgrestException catch (e) {
      throw ServerException(e.message);
    } catch (e) {
      throw ServerException('Unexpected error');
    }
  }

  @override
  Future<void> removeBookmark(String userId, String postId) async {
    try {
      await _client
          .from('bookmarks')
          .delete()
          .eq('user_id', userId)
          .eq('post_id', postId);
    } on PostgrestException catch (e) {
      throw ServerException(e.message);
    } catch (e) {
      throw ServerException('Unexpected error');
    }
  }

  @override
  Future<bool> isBookmarked(String userId, String postId) async {
    try {
      final response = await _client
          .from('bookmarks')
          .select('id')
          .eq('user_id', userId)
          .eq('post_id', postId)
          .maybeSingle();
      return response != null;
    } on PostgrestException catch (e) {
      throw ServerException(e.message);
    } catch (e) {
      throw ServerException('Unexpected error');
    }
  }

  @override
  Future<List<String>> getBookmarkStatuses(
    String userId,
    List<String> postIds,
  ) async {
    try {
      if (postIds.isEmpty) return [];
      final response = await _client
          .from('bookmarks')
          .select('post_id')
          .eq('user_id', userId)
          .inFilter('post_id', postIds);
      return response.map((e) => e['post_id'] as String).toList();
    } on PostgrestException catch (e) {
      throw ServerException(e.message);
    } catch (e) {
      throw ServerException('Unexpected error');
    }
  }
}
