# Contract: BookmarksRepository

**Layer**: Domain (abstract) + Data (implementation) | **Type**: Repository interface

## Interface: BookmarksRepository

Defines the business operations for bookmarks. All methods return `Either<Failure, T>` — never throws.

### Methods

#### `getBookmarks(String userId, {int offset, int limit})`
- **Returns**: `Either<Failure, List<Bookmark>>` — paginated list of bookmarks with post data
- **Parameters**:
  - `userId` (String) — the authenticated user's ID
  - `offset` (int, default 0) — pagination offset
  - `limit` (int, default 20) — page size
- **Success (Right)**: List of `Bookmark` entities
- **Failure (Left)**: `ServerFailure` with error message

#### `addBookmark(String userId, String postId)`
- **Returns**: `Either<Failure, Bookmark>` — the created bookmark
- **Parameters**:
  - `userId` (String) — the authenticated user's ID
  - `postId` (String) — the post to bookmark
- **Success (Right)**: Created `Bookmark` entity
- **Failure (Left)**: `ServerFailure` with error message

#### `removeBookmark(String userId, String postId)`
- **Returns**: `Either<Failure, void>` — success or failure
- **Parameters**:
  - `userId` (String) — the authenticated user's ID
  - `postId` (String) — the post to unbookmark
- **Success (Right)**: `null` (void)
- **Failure (Left)**: `ServerFailure` with error message

#### `isBookmarked(String userId, String postId)`
- **Returns**: `Either<Failure, bool>` — bookmark status
- **Parameters**:
  - `userId` (String) — the authenticated user's ID
  - `postId` (String) — the post to check
- **Success (Right)**: `true` if bookmarked, `false` otherwise
- **Failure (Left)**: `ServerFailure` with error message

#### `getBookmarkStatuses(String userId, List<String> postIds)`
- **Returns**: `Either<Failure, Set<String>>` — set of bookmarked post IDs
- **Parameters**:
  - `userId` (String) — the authenticated user's ID
  - `postIds` (List<String>) — post IDs to check
- **Success (Right)**: `Set<String>` of post IDs that are bookmarked
- **Failure (Left)**: `ServerFailure` with error message

## Implementation: BookmarksRepositoryImpl

Concrete implementation in the data layer. Injects `BookmarksDataSource` via constructor.

- Catches `ServerException` from data source → returns `Left(ServerFailure(e.message))`
- Converts `BookmarkModel` to `Bookmark` entity via `toEntity()`
- Never throws exceptions — always returns `Either`

## Use Cases

### GetBookmarks
- Single `call(GetBookmarksParams params)` method
- Params: `userId`, `offset`, `limit`
- Delegates to `BookmarksRepository.getBookmarks()`

### ToggleBookmark
- Single `call(ToggleBookmarkParams params)` method
- Params: `userId`, `postId`, `isCurrentlyBookmarked`
- If currently bookmarked → calls `removeBookmark()`
- If not bookmarked → calls `addBookmark()`

### IsBookmarked
- Single `call(IsBookmarkedParams params)` method
- Params: `userId`, `postId`
- Delegates to `BookmarksRepository.isBookmarked()`
