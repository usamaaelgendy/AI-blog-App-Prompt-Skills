# Research: Post Bookmarks

**Feature**: 001-post-bookmarks | **Date**: 2026-04-07

## R1: Supabase Bookmarks Table Design

**Decision**: Create a `bookmarks` table with columns `id` (UUID, PK), `user_id` (UUID, FK → auth.users), `post_id` (UUID, FK → posts), `created_at` (timestamptz, default now()). Add a unique constraint on `(user_id, post_id)` to prevent duplicate bookmarks.

**Rationale**: Matches the existing Supabase schema conventions (UUID primary keys, snake_case columns, timestamptz for dates). The composite unique constraint enforces the one-bookmark-per-user-per-post business rule at the database level, preventing duplicates even under concurrent requests.

**Alternatives considered**:
- Boolean `is_bookmarked` field on posts table: Rejected — doesn't support per-user bookmarks and modifies an existing entity.
- Array field on users table: Rejected — doesn't scale, no referential integrity, complicates queries.

## R2: Optimistic UI Pattern with BLoC

**Decision**: Use a dedicated `BookmarkToggleBloc` that immediately emits the toggled state, fires the server request, and emits a revert + error state if the request fails. The toggle BLoC maintains a `Map<String, bool>` of post IDs to bookmark status.

**Rationale**: Separating toggle logic from the bookmarks list BLoC allows the toggle to be used anywhere a post is displayed (posts list, post detail, bookmarks screen) without coupling to the bookmarks list state. The `Map<String, bool>` approach lets the BLoC track multiple posts' bookmark states simultaneously, which is necessary when posts are displayed in a list.

**Alternatives considered**:
- Single BLoC for both list and toggle: Rejected — the toggle needs to work outside the bookmarks screen context (on posts list, post detail).
- Stream-based approach without BLoC: Rejected — inconsistent with the project's BLoC-only state management pattern.

## R3: Paginated Bookmarks Loading

**Decision**: Use Supabase's `.range(from, to)` method for offset-based pagination, loading 20 bookmarks per page ordered by `created_at` descending. Join with posts table using `.select('*, posts(*)')` to fetch bookmark and post data in a single query.

**Rationale**: Matches the pagination approach suitable for Supabase Postgrest API. The join query avoids N+1 queries when loading bookmarked posts. Offset pagination is simpler than cursor-based and sufficient for bookmark lists where real-time insertion during browsing is uncommon.

**Alternatives considered**:
- Cursor-based pagination: Rejected — unnecessary complexity for bookmarks ordered by creation date where the list is user-specific and relatively stable.
- Load all then paginate client-side: Rejected — doesn't scale with growing bookmark count per the spec's "no limit" assumption.

## R4: Bookmark Status Check for Post Cards

**Decision**: When loading a page of posts, fetch the current user's bookmark status for those post IDs in a single batch query (`_client.from('bookmarks').select('post_id').eq('user_id', userId).in_('post_id', postIds)`). Store results in the `BookmarkToggleBloc` state.

**Rationale**: A batch query on page load is more efficient than individual checks per post. Storing in the toggle BLoC state provides a single source of truth for bookmark status across all screens.

**Alternatives considered**:
- Individual `isBookmarked` check per post card: Rejected — N+1 query pattern, poor performance.
- Add bookmark status to the posts query: Rejected — would require modifying the existing posts feature, and bookmark data is user-specific while posts are shared.

## R5: Handling Deleted Posts in Bookmarks

**Decision**: Use Supabase foreign key with `ON DELETE CASCADE` on the `bookmarks.post_id` column. When a post is deleted, its bookmarks are automatically removed. On the bookmarks screen, if a stale bookmark somehow appears (e.g., from cache), handle the null post gracefully by filtering it out.

**Rationale**: Database-level cascading deletes are the most reliable way to maintain referential integrity. Application-level cleanup would require polling or event listeners for post deletions, adding unnecessary complexity.

**Alternatives considered**:
- Application-level cleanup via post deletion events: Rejected — adds complexity and has race condition risks.
- Soft delete with a flag: Rejected — over-engineering for this use case.