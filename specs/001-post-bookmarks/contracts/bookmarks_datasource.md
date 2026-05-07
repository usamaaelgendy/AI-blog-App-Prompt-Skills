# Contract: BookmarksDataSource

**Layer**: Data | **Type**: Abstract interface + concrete implementation

## Interface: BookmarksDataSource

Defines the data operations for bookmark persistence. Throws `ServerException` on any failure.

### Methods

#### `fetchBookmarks(String userId, {int offset, int limit})`
- **Returns**: `List<BookmarkModel>` — bookmarks with embedded post data
- **Parameters**:
  - `userId` (String) — the authenticated user's ID
  - `offset` (int, default 0) — pagination offset
  - `limit` (int, default 20) — page size
- **Behavior**: Fetches bookmarks ordered by `created_at` DESC with joined post data
- **Throws**: `ServerException` on Supabase query failure

#### `addBookmark(String userId, String postId)`
- **Returns**: `BookmarkModel` — the created bookmark
- **Parameters**:
  - `userId` (String) — the authenticated user's ID
  - `postId` (String) — the post to bookmark
- **Behavior**: Inserts a new bookmark row. If duplicate `(userId, postId)` exists, the database unique constraint will cause a `PostgrestException`.
- **Throws**: `ServerException` on failure

#### `removeBookmark(String userId, String postId)`
- **Returns**: `void`
- **Parameters**:
  - `userId` (String) — the authenticated user's ID
  - `postId` (String) — the post to unbookmark
- **Behavior**: Deletes the bookmark matching `(userId, postId)`
- **Throws**: `ServerException` on failure

#### `isBookmarked(String userId, String postId)`
- **Returns**: `bool`
- **Parameters**:
  - `userId` (String) — the authenticated user's ID
  - `postId` (String) — the post to check
- **Behavior**: Returns `true` if a bookmark exists for the given user and post
- **Throws**: `ServerException` on failure

#### `getBookmarkStatuses(String userId, List<String> postIds)`
- **Returns**: `List<String>` — list of post IDs that are bookmarked
- **Parameters**:
  - `userId` (String) — the authenticated user's ID
  - `postIds` (List<String>) — post IDs to check
- **Behavior**: Batch check which posts are bookmarked by the user
- **Throws**: `ServerException` on failure

## Implementation: BookmarksDataSourceImpl

Concrete implementation using `SupabaseClient`. Injects the client via constructor.

- All methods wrap Supabase Postgrest queries
- Catches `PostgrestException` and rethrows as `ServerException`
- Catches general exceptions as `ServerException('Unexpected error')`
- Uses `_client.from('bookmarks')` for all queries
- Pagination via `.range(offset, offset + limit - 1)`
- Post data fetched via join: `.select('*, posts(*)')`
