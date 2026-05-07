# Quickstart: Post Bookmarks

**Feature**: 001-post-bookmarks | **Date**: 2026-04-07

## Prerequisites

1. Flutter 3.24+ and Dart 3.5+ installed
2. Supabase project with `bookmarks` table created (see schema below)
3. Existing blog app running with posts feature functional

## Supabase Setup

### Create bookmarks table

```sql
CREATE TABLE bookmarks (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id uuid NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  post_id uuid NOT NULL REFERENCES posts(id) ON DELETE CASCADE,
  created_at timestamptz NOT NULL DEFAULT now(),
  UNIQUE(user_id, post_id)
);

CREATE INDEX idx_bookmarks_user_id ON bookmarks(user_id);
CREATE INDEX idx_bookmarks_post_id ON bookmarks(post_id);
```

### Enable Row Level Security

```sql
ALTER TABLE bookmarks ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can read own bookmarks"
  ON bookmarks FOR SELECT
  USING (auth.uid() = user_id);

CREATE POLICY "Users can insert own bookmarks"
  ON bookmarks FOR INSERT
  WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can delete own bookmarks"
  ON bookmarks FOR DELETE
  USING (auth.uid() = user_id);
```

## Implementation Order

Build in this order to satisfy layer dependencies:

1. **Domain layer** (no dependencies):
   - `bookmark.dart` entity
   - `bookmarks_repository.dart` interface
   - Use cases: `get_bookmarks.dart`, `toggle_bookmark.dart`, `is_bookmarked.dart`

2. **Data layer** (depends on domain):
   - `bookmark_model.dart` model
   - `bookmarks_datasource.dart` interface
   - `bookmarks_datasource_impl.dart` Supabase implementation
   - `bookmarks_repository_impl.dart` repository implementation

3. **DI registration** (depends on data):
   - Register datasource, repository, use cases, and BLoCs in `core/di/`

4. **Presentation layer** (depends on domain + DI):
   - `bookmark_toggle_bloc.dart` + events + states (optimistic toggle)
   - `bookmark_icon_button.dart` widget
   - `bookmarks_bloc.dart` + events + states (list management)
   - `bookmarks_screen.dart` screen

5. **Integration**:
   - Add `BookmarkIconButton` to `PostCard` widget
   - Add bookmarks screen navigation entry point

## Verification

```bash
flutter analyze          # Should pass with zero issues
flutter test             # All new and existing tests pass
```

## Key Patterns to Follow

- Entity: `final` fields, `const` constructor, no imports beyond dart:core
- Model: `fromJson()`, `toJson()`, `toEntity()` — snake_case JSON keys
- DataSource: catch `PostgrestException` → throw `ServerException`
- Repository: catch `ServerException` → return `Left(ServerFailure)`
- BLoC: `on<Event>` handlers, emit states, fold `Either` results
- Widget: stateless, receives data via constructor, uses `BlocBuilder`
