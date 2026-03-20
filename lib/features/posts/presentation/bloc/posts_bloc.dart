import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../domain/repositories/posts_repository.dart';
import 'posts_event.dart';
import 'posts_state.dart';

class PostsBloc extends Bloc<PostsEvent, PostsState> {
  final PostsRepository _repository;
  final SupabaseClient _client;

  PostsBloc(this._repository, this._client) : super(PostsInitial()) {
    on<LoadPosts>(_onLoadPosts);
    on<PostsUpdated>(_onPostsUpdated);

    _client
        .from('posts')
        .stream(primaryKey: ['id']).listen((data) {
      add(PostsUpdated(data));
    });
  }

  Future<void> _onLoadPosts(LoadPosts event, Emitter<PostsState> emit) async {
    emit(PostsLoading());
    final result = await _repository.getPosts();
    result.fold(
      (failure) => emit(PostsError(failure.message)),
      (posts) => emit(PostsLoaded(posts)),
    );
  }

  void _onPostsUpdated(PostsUpdated event, Emitter<PostsState> emit) {
    // Refresh posts when realtime update comes
    add(LoadPosts());
  }

  @override
  Future<void> close() {
    return super.close();
  }
}
