# Tasks: Post Bookmarks

**Input**: Design documents from `/specs/001-post-bookmarks/`
**Prerequisites**: plan.md, spec.md, research.md, data-model.md, contracts/

**Tests**: Not explicitly requested — test tasks omitted. Test file paths are documented in plan.md for future reference.

**Organization**: Tasks grouped by user story to enable independent implementation and testing.

## Format: `[ID] [P?] [Story] Description`

- **[P]**: Can run in parallel (different files, no dependencies)
- **[Story]**: Which user story this task belongs to (e.g., US1, US2, US3)
- Include exact file paths in descriptions

## Phase 1: Setup

**Purpose**: Create the bookmarks feature directory structure

- [ ] T001 Create bookmarks feature directory structure under `lib/features/bookmarks/` with subdirectories: `data/datasources/`, `data/models/`, `data/repositories/`, `domain/entities/`, `domain/repositories/`, `domain/usecases/`, `presentation/bloc/`, `presentation/screens/`, `presentation/widgets/`

---

## Phase 2: Foundational (Domain + Data Layers)

**Purpose**: Core domain entities, interfaces, and data layer implementations that ALL user stories depend on

**CRITICAL**: No user story work can begin until this phase is complete

- [ ] T002 [P] Create Bookmark entity with fields `id`, `postId`, `userId`, `createdAt`, `post` (Post entity, from joined query) — all final, const constructor in `lib/features/bookmarks/domain/entities/bookmark.dart`
- [ ] T003 [P] Create BookmarksRepository abstract interface with methods: `getBookmarks`, `addBookmark`, `removeBookmark`, `isBookmarked`, `getBookmarkStatuses` — all returning `Either<Failure, T>` in `lib/features/bookmarks/domain/repositories/bookmarks_repository.dart`
- [ ] T004 [P] Create BookmarkModel with `fromJson()`, `toJson()`, `toEntity()` mapping snake_case JSON keys (`user_id`, `post_id`, `created_at`) to camelCase Dart fields — `fromJson` must also parse nested `json['posts']` via `PostModel.fromJson()` to populate the `post` field for joined queries in `lib/features/bookmarks/data/models/bookmark_model.dart`
- [ ] T005 [P] Create BookmarksDataSource abstract interface with methods: `fetchBookmarks`, `addBookmark`, `removeBookmark`, `isBookmarked`, `getBookmarkStatuses` in `lib/features/bookmarks/data/datasources/bookmarks_datasource.dart`
- [ ] T006 Create BookmarksDataSourceImpl with SupabaseClient injection implementing all BookmarksDataSource methods — `fetchBookmarks` uses `.select('*, posts(*)').eq('user_id', userId).order('created_at').range(offset, offset+limit-1)`, `addBookmark` inserts row, `removeBookmark` deletes by user_id+post_id, `isBookmarked` checks existence, `getBookmarkStatuses` batch checks post IDs — catch `PostgrestException` and throw `ServerException` in `lib/features/bookmarks/data/datasources/bookmarks_datasource_impl.dart`
- [ ] T007 Create BookmarksRepositoryImpl with BookmarksDataSource injection, catch `ServerException` from datasource and return `Left(ServerFailure)`, convert BookmarkModel to Bookmark via `toEntity()`, filter out any bookmarks where joined post data is null (orphaned bookmark from deleted post) in `lib/features/bookmarks/data/repositories/bookmarks_repository_impl.dart`
- [ ] T008 Register data-layer dependencies in DI container: `BookmarksDataSource` → `BookmarksDataSourceImpl(SupabaseClient)`, `BookmarksRepository` → `BookmarksRepositoryImpl(BookmarksDataSource)` in `lib/core/di/injection_container.dart`

**Checkpoint**: Domain and data layers complete — user story implementation can begin

---

## Phase 3: User Story 1 — Bookmark a Post (Priority: P1) MVP

**Goal**: A logged-in user can tap a bookmark icon on any post to save it, with optimistic UI feedback. The icon reflects current bookmark status.

**Independent Test**: Tap the bookmark icon on a post in the posts list → icon toggles to bookmarked state immediately → verify the bookmark persists after refreshing the posts list.

### Implementation for User Story 1

- [ ] T009 [P] [US1] Create ToggleBookmark use case with `ToggleBookmarkParams(userId, postId, isCurrentlyBookmarked)` — if bookmarked calls `removeBookmark`, else calls `addBookmark` in `lib/features/bookmarks/domain/usecases/toggle_bookmark.dart`
- [ ] T010 [P] [US1] Create IsBookmarked use case with `IsBookmarkedParams(userId, postId)` delegating to `BookmarksRepository.isBookmarked()` in `lib/features/bookmarks/domain/usecases/is_bookmarked.dart`
- [ ] T011 [P] [US1] Create BookmarkToggleEvent classes: `ToggleBookmarkEvent(postId)`, `LoadBookmarkStatuses(postIds)`, `BookmarkStatusesLoaded(Map<String, bool>)` in `lib/features/bookmarks/presentation/bloc/bookmark_toggle_event.dart`
- [ ] T012 [P] [US1] Create BookmarkToggleState with `Map<String, bool> statuses` tracking bookmark status per postId, plus `String? errorPostId` and `String? errorMessage` for revert feedback in `lib/features/bookmarks/presentation/bloc/bookmark_toggle_state.dart`
- [ ] T013 [US1] Create BookmarkToggleBloc: on `ToggleBookmarkEvent` — emit optimistic toggled state immediately, call `ToggleBookmark` use case, on failure revert state and set error fields; on `LoadBookmarkStatuses` — call `getBookmarkStatuses` and populate the statuses map in `lib/features/bookmarks/presentation/bloc/bookmark_toggle_bloc.dart`
- [ ] T014 [US1] Create BookmarkIconButton stateless widget: uses `BlocBuilder<BookmarkToggleBloc, BookmarkToggleState>` to read bookmark status for its `postId`, renders filled/outlined bookmark icon, dispatches `ToggleBookmarkEvent` on tap, shows error snackbar via `BlocListener` on revert in `lib/features/bookmarks/presentation/widgets/bookmark_icon_button.dart`
- [ ] T015 [US1] Add auth guard to BookmarkIconButton — on tap, check `Supabase.instance.client.auth.currentUser`; if null, navigate to LoginScreen instead of dispatching toggle event (FR-008) in `lib/features/bookmarks/presentation/widgets/bookmark_icon_button.dart`
- [ ] T016 [US1] Integrate BookmarkIconButton into existing PostCard widget — add as trailing widget in the ListTile, pass `post.id` in `lib/features/posts/presentation/widgets/post_card.dart`
- [ ] T017 [US1] Register US1 dependencies in DI: `ToggleBookmark(BookmarksRepository)`, `IsBookmarked(BookmarksRepository)`, `BookmarkToggleBloc(ToggleBookmark, IsBookmarked, BookmarksRepository)` in `lib/core/di/injection_container.dart`
- [ ] T018 [US1] Provide BookmarkToggleBloc via BlocProvider at the app level (or above PostsListScreen) so it is accessible from PostCard — update widget tree in `lib/main.dart`

**Checkpoint**: Users can bookmark/unbookmark posts from the posts list with optimistic UI. MVP is functional.

---

## Phase 4: User Story 2 — View Bookmarked Posts (Priority: P2)

**Goal**: A logged-in user can navigate to a dedicated bookmarks screen that lists all saved posts with paginated infinite scroll, empty state, and post navigation.

**Independent Test**: Bookmark 2-3 posts → navigate to bookmarks screen → verify all bookmarked posts appear → tap a post → verify navigation to post detail.

### Implementation for User Story 2

- [ ] T019 [US2] Create GetBookmarks use case with `GetBookmarksParams(userId, offset, limit)` delegating to `BookmarksRepository.getBookmarks()` in `lib/features/bookmarks/domain/usecases/get_bookmarks.dart`
- [ ] T020 [P] [US2] Create BookmarksEvent classes: `LoadBookmarks`, `LoadMoreBookmarks` in `lib/features/bookmarks/presentation/bloc/bookmarks_event.dart`
- [ ] T021 [P] [US2] Create BookmarksState classes: `BookmarksInitial`, `BookmarksLoading`, `BookmarksLoaded(posts, hasReachedMax)`, `BookmarksError(message)` in `lib/features/bookmarks/presentation/bloc/bookmarks_state.dart`
- [ ] T022 [US2] Create BookmarksBloc: on `LoadBookmarks` — emit loading, fetch first page (20 items), emit loaded; on `LoadMoreBookmarks` — append next page, set `hasReachedMax` when fewer than 20 returned in `lib/features/bookmarks/presentation/bloc/bookmarks_bloc.dart`
- [ ] T023 [US2] Create BookmarksScreen with `BlocBuilder<BookmarksBloc, BookmarksState>`: loading state shows `CircularProgressIndicator`, loaded state shows `ListView.builder` with scroll listener for infinite scroll trigger, empty state shows message with "Browse posts" suggestion, error state shows error message in `lib/features/bookmarks/presentation/screens/bookmarks_screen.dart`
- [ ] T024 [US2] Add bookmarks screen navigation entry point — add bookmarks icon to app navigation (bottom nav bar or drawer) that navigates to BookmarksScreen in the appropriate navigation widget
- [ ] T025 [US2] Register US2 dependencies in DI: `GetBookmarks(BookmarksRepository)`, `BookmarksBloc(GetBookmarks)` — provide BookmarksBloc via BlocProvider on the bookmarks screen in `lib/core/di/injection_container.dart`

**Checkpoint**: Users can view all their bookmarks on a dedicated screen with pagination. US1 + US2 both work independently.

---

## Phase 5: User Story 3 — Remove a Bookmark (Priority: P3)

**Goal**: A logged-in user can remove a bookmark from the bookmarks screen by tapping the bookmark icon, and the post disappears from the list immediately (optimistic). Handles transition to empty state.

**Independent Test**: Navigate to bookmarks screen with 1+ bookmarks → tap bookmark icon to remove → post disappears from list → remove all bookmarks → empty state message appears.

### Implementation for User Story 3

- [ ] T026 [US3] Add BookmarkToggleBloc listener in BookmarksBloc — when a bookmark is toggled off (removed), remove that post from the loaded bookmarks list and re-emit state; if list becomes empty, transition to empty state in `lib/features/bookmarks/presentation/bloc/bookmarks_bloc.dart`
- [ ] T027 [US3] Integrate BookmarkIconButton into each list item on the bookmarks screen so users can unbookmark directly from the list in `lib/features/bookmarks/presentation/screens/bookmarks_screen.dart`
- [ ] T028 [US3] Ensure BookmarkToggleBloc is accessible on the bookmarks screen — verify BlocProvider scope covers both PostCard and BookmarksScreen in `lib/main.dart`

**Checkpoint**: Full bookmark lifecycle works — add, view, remove. All three user stories functional.

---

## Phase 6: Polish & Cross-Cutting Concerns

**Purpose**: Verification, cleanup, and cross-screen consistency

- [ ] T029 [P] Verify cross-screen bookmark state synchronization — when unbookmarking from bookmarks screen, the PostCard icon in posts list should also reflect the change (both read from same BookmarkToggleBloc state)
- [ ] T030 [P] Run `flutter analyze` and fix any lint issues across all new files
- [ ] T031 Run quickstart.md validation: verify Supabase table schema matches data-model.md, verify all DI registrations resolve, verify full bookmark workflow end-to-end

---

## Dependencies & Execution Order

### Phase Dependencies

- **Setup (Phase 1)**: No dependencies — start immediately
- **Foundational (Phase 2)**: Depends on Phase 1 — BLOCKS all user stories
- **US1 (Phase 3)**: Depends on Phase 2 — can start after foundational
- **US2 (Phase 4)**: Depends on Phase 2 — can start in parallel with US1
- **US3 (Phase 5)**: Depends on US1 (toggle bloc) + US2 (bookmarks screen)
- **Polish (Phase 6)**: Depends on all user stories complete

### User Story Dependencies

```
Phase 1 (Setup)
    ↓
Phase 2 (Foundational)
    ↓
  ┌─────────┬─────────┐
  ↓         ↓         │
US1 (P1)  US2 (P2)    │
  │         │         │
  └────┬────┘         │
       ↓              │
     US3 (P3) ────────┘
       ↓
    Polish
```

- **US1 and US2 can run in parallel** after foundational phase
- **US3 depends on both US1 and US2** (uses toggle from US1 on screen from US2)

### Within Each User Story

- Use cases (domain) before BLoC (presentation)
- Events + states before BLoC implementation
- BLoC before widgets/screens
- Widgets before screen integration
- DI registration after all classes exist

### Parallel Opportunities

**Phase 2 (Foundational)**: T002, T003, T004, T005 can all run in parallel (independent files, no cross-dependencies)

**Phase 3 (US1)**: T009, T010, T011, T012 can all run in parallel (independent files)

**Phase 4 (US2)**: T020, T021 can run in parallel (events + states are independent files)

**Phase 6 (Polish)**: T029, T030 can run in parallel

---

## Parallel Example: User Story 1

```text
# Parallel batch 1 — all independent domain + event/state files:
T009: Create ToggleBookmark use case in domain/usecases/toggle_bookmark.dart
T010: Create IsBookmarked use case in domain/usecases/is_bookmarked.dart
T011: Create BookmarkToggleEvent in presentation/bloc/bookmark_toggle_event.dart
T012: Create BookmarkToggleState in presentation/bloc/bookmark_toggle_state.dart

# Sequential — depends on batch 1:
T013: Create BookmarkToggleBloc (needs T009, T010, T011, T012)
T014: Create BookmarkIconButton widget (needs T013)
T015: Add auth guard to BookmarkIconButton (needs T014)
T016: Integrate into PostCard (needs T014)
T017: Register DI (needs T009, T010, T013)
T018: Provide BlocProvider in app (needs T013)
```

---

## Implementation Strategy

### MVP First (User Story 1 Only)

1. Complete Phase 1: Setup
2. Complete Phase 2: Foundational (CRITICAL — blocks all stories)
3. Complete Phase 3: User Story 1
4. **STOP and VALIDATE**: Bookmark toggle works on posts list with optimistic UI
5. This is a shippable increment — users can save posts

### Incremental Delivery

1. Setup + Foundational → Core layers ready
2. Add US1 → Bookmark toggle on posts list → **MVP!**
3. Add US2 → Dedicated bookmarks screen with pagination
4. Add US3 → Remove from bookmarks screen + cross-screen sync
5. Polish → Verify everything, fix lint, run quickstart validation

### Parallel Team Strategy

With two developers:

1. Team completes Setup + Foundational together
2. Once Foundational is done:
   - Developer A: User Story 1 (bookmark toggle)
   - Developer B: User Story 2 (bookmarks screen)
3. Both merge, then either developer completes User Story 3 (integration)

---

## Notes

- [P] tasks = different files, no dependencies on incomplete tasks
- [Story] label maps task to specific user story for traceability
- No new packages required — uses existing flutter_bloc, dartz, supabase_flutter, get_it
- Supabase `bookmarks` table must be created before testing (see quickstart.md for SQL)
- BookmarkToggleBloc is provided at app level for cross-screen state sharing
