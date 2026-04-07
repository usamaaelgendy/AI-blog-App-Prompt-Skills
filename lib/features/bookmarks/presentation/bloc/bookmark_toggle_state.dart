class BookmarkToggleState {
  final Map<String, bool> statuses;
  final String? errorPostId;
  final String? errorMessage;

  const BookmarkToggleState({
    this.statuses = const {},
    this.errorPostId,
    this.errorMessage,
  });

  BookmarkToggleState copyWith({
    Map<String, bool>? statuses,
    String? errorPostId,
    String? errorMessage,
  }) {
    return BookmarkToggleState(
      statuses: statuses ?? this.statuses,
      errorPostId: errorPostId,
      errorMessage: errorMessage,
    );
  }

  bool isBookmarked(String postId) => statuses[postId] ?? false;
}
