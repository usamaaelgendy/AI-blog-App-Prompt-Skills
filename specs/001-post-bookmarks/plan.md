# Implementation Plan: Post Bookmarks

**Branch**: `001-post-bookmarks` | **Date**: 2026-04-07 | **Spec**: [spec.md](spec.md)
**Input**: Feature specification from `/specs/001-post-bookmarks/spec.md`

## Summary

Add a bookmarks feature allowing logged-in users to save posts for later, view all saved posts on a dedicated bookmarks
screen with infinite scroll, and remove bookmarks at any time. Follows existing Clean Architecture patterns with BLoC
state management and Supabase backend. Uses optimistic UI updates for bookmark toggle actions.

## Technical Context

**Language/Version**: Dart 3.5+ / Flutter 3.24+
**Primary Dependencies**: flutter_bloc 8.1.6, dartz 0.10.1, supabase_flutter, get_it 8.0.2, mocktail 1.0.4
**Storage**: Supabase (PostgreSQL via Postgrest) — new `bookmarks` table
**Testing**: flutter_test + mocktail
**Target Platform**: Mobile (iOS/Android)
**Project Type**: Mobile app (educational reference)
**Performance Goals**: <1s bookmark toggle with optimistic UI, <2s bookmarks screen load
**Constraints**: Optimistic UI updates with revert on failure, paginated loading (20 per page)
**Scale/Scope**: Educational reference project, single user role (authenticated user)

## Constitution Check

*GATE: Must pass before Phase 0 research. Re-check after Phase 1 design.*

| Principle                         | Status | Evidence                                                                                                                                             |
|-----------------------------------|--------|------------------------------------------------------------------------------------------------------------------------------------------------------|
| **I. Clean Architecture**         | PASS   | Feature organized as `lib/features/bookmarks/` with `data/`, `domain/`, `presentation/` sub-directories. Presentation imports domain only, not data. |
| **II. Contract-First Design**     | PASS   | Abstract `BookmarksDataSource`, `BookmarksRepository` interfaces defined before concrete `*Impl` classes. All registered via get_it in `core/di/`.   |
| **III. Type-Safe Error Handling** | PASS   | DataSource throws `ServerException` → Repository catches and returns `Either<Failure, T>` → BLoC folds → Screen renders error state.                 |
| **IV. Pure Domain Layer**         | PASS   | `Bookmark` entity uses `final` fields and `const` constructor. No Flutter/Supabase imports in domain. Use cases have single `call()` method.         |
| **V. Dependency Inversion**       | PASS   | Constructor injection for all classes. Concrete implementations registered in `core/di/` via get_it.                                                 |

**Architecture Constraints Check:**

| Constraint                        | Status                                                          |
|-----------------------------------|-----------------------------------------------------------------|
| No unauthorized packages          | PASS — Uses only existing dependencies                          |
| Model/Entity separation           | PASS — `BookmarkModel` (data) ↔ `Bookmark` (domain)             |
| No business logic in presentation | PASS — Optimistic revert logic in BLoC, not widgets             |
| No hardcoded credentials          | PASS — Supabase accessed via existing initialized client        |
| File placement                    | PASS — All files in `lib/features/bookmarks/` or `lib/core/di/` |
| Naming conventions                | PASS — Follows documented patterns                              |

## Project Structure

### Documentation (this feature)

```text
specs/001-post-bookmarks/
├── plan.md              # This file
├── spec.md              # Feature specification
├── research.md          # Phase 0 output
├── data-model.md        # Phase 1 output
├── quickstart.md        # Phase 1 output
├── contracts/           # Phase 1 output
│   ├── bookmarks_datasource.md
│   └── bookmarks_repository.md
├── checklists/
│   └── requirements.md  # Spec quality checklist
└── tasks.md             # Phase 2 output (via /speckit.tasks)
```

### Source Code (repository root)

```text
lib/
├── core/
│   └── di/
│       └── injection_container.dart     # Add bookmark registrations (new or updated)
├── features/
│   └── bookmarks/
│       ├── data/
│       │   ├── datasources/
│       │   │   ├── bookmarks_datasource.dart       # Abstract interface
│       │   │   └── bookmarks_datasource_impl.dart  # Supabase implementation
│       │   ├── models/
│       │   │   └── bookmark_model.dart              # JSON ↔ BookmarkModel + toEntity()
│       │   └── repositories/
│       │       └── bookmarks_repository_impl.dart   # Exception → Either bridge
│       ├── domain/
│       │   ├── entities/
│       │   │   └── bookmark.dart                    # Immutable Bookmark entity
│       │   ├── repositories/
│       │   │   └── bookmarks_repository.dart        # Abstract contract
│       │   └── usecases/
│       │       ├── get_bookmarks.dart               # Fetch paginated bookmarks
│       │       ├── toggle_bookmark.dart             # Add or remove bookmark
│       │       └── is_bookmarked.dart               # Check bookmark status for a post
│       └── presentation/
│           ├── bloc/
│           │   ├── bookmarks_bloc.dart              # Bookmarks list BLoC
│           │   ├── bookmarks_event.dart             # Events for bookmarks list
│           │   ├── bookmarks_state.dart             # States for bookmarks list
│           │   ├── bookmark_toggle_bloc.dart        # Toggle BLoC (optimistic updates)
│           │   ├── bookmark_toggle_event.dart       # Toggle events
│           │   └── bookmark_toggle_state.dart       # Toggle states
│           ├── screens/
│           │   └── bookmarks_screen.dart            # Dedicated bookmarks list screen
│           └── widgets/
│               └── bookmark_icon_button.dart        # Reusable toggle icon widget
test/
├── features/
│   └── bookmarks/
│       ├── data/
│       │   ├── datasources/
│       │   │   └── bookmarks_datasource_impl_test.dart
│       │   ├── models/
│       │   │   └── bookmark_model_test.dart
│       │   └── repositories/
│       │       └── bookmarks_repository_impl_test.dart
│       ├── domain/
│       │   └── usecases/
│       │       ├── get_bookmarks_test.dart
│       │       ├── toggle_bookmark_test.dart
│       │       └── is_bookmarked_test.dart
│       └── presentation/
│           └── bloc/
│               ├── bookmarks_bloc_test.dart
│               └── bookmark_toggle_bloc_test.dart
```

**Structure Decision**: Follows the existing feature-module pattern established by `posts/`. Two separate BLoCs:
`BookmarksBloc` manages the bookmarks list screen (pagination, loading), and `BookmarkToggleBloc` handles the optimistic
toggle interaction used across posts list, post detail, and bookmarks screens.

## Complexity Tracking

No constitution violations requiring justification. Two BLoCs are warranted: list management and toggle are independent
concerns used in different contexts (bookmarks screen vs. any post card/detail).