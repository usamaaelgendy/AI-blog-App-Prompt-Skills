abstract class PostsEvent {}

class LoadPosts extends PostsEvent {}

class LoadMorePosts extends PostsEvent {}

class PostsUpdated extends PostsEvent {
  final List<dynamic> data;
  PostsUpdated(this.data);
}
