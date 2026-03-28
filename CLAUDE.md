# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

Flutter/Dart mobile blog application using Clean Architecture, BLoC state management, and Supabase backend. This is an educational reference project for the "Developer X AI" course. It contains placeholder Supabase credentials and is not intended to run without configuration.

## Common Commands

```bash
flutter pub get          # Install dependencies
flutter run              # Run the app
flutter test             # Run all tests
flutter test test/path/to/test.dart  # Run a single test
flutter analyze          # Lint/static analysis
flutter build apk        # Build Android
flutter build ios        # Build iOS
```

## Architecture

This project follows **Clean Architecture** principles organized by feature modules. Each feature is self-contained with three layers that enforce a strict dependency rule: outer layers depend on inner layers, never the reverse.

### Folder Structure

```
lib/
├── main.dart                          # App entry point, Supabase init
├── core/                              # Shared utilities (no feature logic)
│   ├── di/                            # Dependency injection setup (get_it)
│   ├── errors/
│   │   ├── app_error.dart             # Structured error with code + user/technical messages
│   │   ├── exceptions.dart            # ServerException, CacheException (thrown by data sources)
│   │   └── failures.dart              # ServerFailure, AuthFailure, ValidationFailure (returned by repos)
│   ├── network/
│   │   ├── api_client.dart            # Abstract API client interface
│   │   └── api_client_impl.dart       # Concrete Dio-based implementation
│   ├── storage/
│   │   └── settings_storage.dart      # SharedPreferences wrapper for app settings
│   └── theme/
│       └── app_theme.dart             # Material 3 theme configuration
├── features/
│   ├── auth/                          # Authentication feature
│   │   ├── data/
│   │   │   ├── datasources/           # (empty — auth uses Supabase Auth directly)
│   │   │   ├── models/
│   │   │   │   └── user_model.dart    # JSON ↔ UserModel, toEntity() converter
│   │   │   └── repositories/
│   │   │       └── auth_repository_impl.dart  # Supabase Auth calls, returns Either
│   │   ├── domain/
│   │   │   ├── entities/
│   │   │   │   └── user.dart          # Immutable User entity
│   │   │   ├── repositories/
│   │   │   │   └── auth_repository.dart  # Abstract contract: login, register, resetPassword, logout
│   │   │   └── usecases/
│   │   │       └── login_usecase.dart # Validates input, delegates to repository
│   │   └── presentation/
│   │       ├── bloc/
│   │       │   └── auth_bloc.dart     # Handles auth events, emits auth states
│   │       └── screens/
│   │           └── login_screen.dart  # Login UI
│   ├── posts/                         # Blog posts feature (CRUD + real-time + search)
│   │   ├── data/
│   │   │   ├── datasources/
│   │   │   │   ├── posts_datasource.dart      # Abstract data source contract
│   │   │   │   └── posts_datasource_impl.dart # Supabase Postgrest queries
│   │   │   ├── models/
│   │   │   │   └── post_model.dart    # JSON ↔ PostModel, toEntity() converter
│   │   │   └── repositories/
│   │   │       └── posts_repository_impl.dart # Catches exceptions → returns Either<Failure, T>
│   │   ├── domain/
│   │   │   ├── entities/
│   │   │   │   └── post.dart          # Immutable Post entity
│   │   │   ├── repositories/
│   │   │   │   └── posts_repository.dart  # Abstract contract: getPosts, getPost, createPost, deletePost
│   │   │   └── usecases/
│   │   │       └── get_posts.dart     # Single-purpose use case wrapping repository call
│   │   └── presentation/
│   │       ├── bloc/
│   │       │   ├── posts_bloc.dart    # Loads posts, subscribes to Supabase real-time stream
│   │       │   ├── posts_event.dart   # LoadPosts, LoadMorePosts, PostsUpdated
│   │       │   └── posts_state.dart   # PostsInitial, PostsLoading, PostsLoaded, PostsError
│   │       ├── screens/
│   │       │   └── posts_list_screen.dart  # ListView with BlocBuilder
│   │       └── widgets/
│   │           └── post_card.dart     # Reusable card widget for a single post
│   ├── home/                          # Home page feature
│   │   └── data/
│   │       ├── datasources/
│   │       │   ├── home_datasource.dart      # Abstract data source contract
│   │       │   └── home_datasource_impl.dart # Concrete implementation
│   │       └── models/
│   │           ├── category_model.dart  # Category JSON model
│   │           └── tag_model.dart       # Tag JSON model
│   └── profile/                       # User profile feature
│       └── presentation/
│           ├── bloc/
│           │   └── profile_bloc.dart   # Profile state management
│           └── screens/
│               └── profile_screen.dart # Profile UI
└── services/
    └── user_service.dart              # Standalone HTTP service (jsonplaceholder API) + Logger
```

### Layers

Each feature module is divided into three layers with a strict dependency direction: **Presentation → Domain ← Data**.

#### 1. Domain Layer (innermost — no dependencies)
The business logic core. Contains only pure Dart with zero framework imports.

| Component | Purpose | Example |
|-----------|---------|---------|
| **Entities** | Immutable data classes representing business objects | `Post`, `User` |
| **Repository interfaces** | Abstract contracts defining data operations | `PostsRepository`, `AuthRepository` |
| **Use cases** | Single-responsibility classes encapsulating one business action. Called via `call()` method. May include input validation. | `GetPosts`, `LoginUseCase` |

#### 2. Data Layer (depends on Domain)
Handles all external data communication. Implements domain contracts.

| Component | Purpose | Example |
|-----------|---------|---------|
| **Models** | JSON-serializable mirrors of entities with `fromJson()`, `toJson()`, and `toEntity()` converters | `PostModel`, `UserModel` |
| **Data sources** | Abstract interface + concrete implementation for a single data provider. Throw `ServerException`/`CacheException` on failure. | `PostsDataSource` / `PostsDataSourceImpl` (Supabase) |
| **Repository implementations** | Implement domain repository interfaces. Catch exceptions from data sources and wrap results in `Either<Failure, T>`. | `PostsRepositoryImpl`, `AuthRepositoryImpl` |

#### 3. Presentation Layer (depends on Domain)
UI and state management. Never imports from `data/` directly.

| Component | Purpose | Example |
|-----------|---------|---------|
| **BLoC** | Receives events, calls use cases/repositories, emits states | `PostsBloc`, `AuthBloc` |
| **Events** | Discrete user actions or system triggers | `LoadPosts`, `PostsUpdated` |
| **States** | UI state snapshots: initial, loading, loaded, error | `PostsLoaded(posts)`, `PostsError(message)` |
| **Screens** | Full-page widgets using `BlocBuilder`/`BlocListener` | `PostsListScreen`, `LoginScreen` |
| **Widgets** | Reusable UI components | `PostCard` |

### Key Patterns

#### Error Handling Flow
```
DataSource (throws ServerException/CacheException)
    ↓
Repository (catches → returns Either<Failure, T>)
    ↓
UseCase (passes through or adds validation failures)
    ↓
BLoC (folds Either → emits success or error state)
    ↓
Screen (renders based on state)
```

Failure hierarchy: `Failure` (abstract) → `ServerFailure`, `AuthFailure`, `ValidationFailure`.

#### Dependency Inversion
Abstract classes define contracts at every boundary:
- `ApiClient` → `ApiClientImpl` (Dio)
- `PostsDataSource` → `PostsDataSourceImpl` (Supabase)
- `PostsRepository` → `PostsRepositoryImpl`
- `AuthRepository` → `AuthRepositoryImpl`

Concrete implementations are registered and resolved via **get_it** service locator.

#### Model ↔ Entity Separation
- **Entities** (domain): Plain immutable Dart classes. No serialization logic.
- **Models** (data): Mirror entities but add `fromJson()` / `toJson()` for serialization and `toEntity()` to convert to the domain type. This keeps JSON/DB concerns out of the domain layer.

#### Real-Time Updates
`PostsBloc` subscribes to Supabase real-time streams on the `posts` table via `SupabaseClient.from('posts').stream(primaryKey: ['id'])`. When changes arrive, a `PostsUpdated` event triggers a full reload via `LoadPosts`.

#### State Management (BLoC)
Each feature's presentation layer follows the BLoC pattern with separated event and state classes. Screens use `BlocBuilder` to reactively rebuild based on state changes.

### Feature Modules

| Module | Status | Layers Present | Description |
|--------|--------|----------------|-------------|
| `auth/` | Data + Domain + Presentation | Full stack | Login, register, password reset via Supabase Auth |
| `posts/` | Data + Domain + Presentation | Full stack | CRUD + search + real-time updates for blog posts |
| `home/` | Data only | Partial | Categories and tags data layer (no domain/presentation yet) |
| `profile/` | Presentation only | Partial | Profile UI and BLoC (no data/domain yet) |

## Naming Conventions

### Files & Directories
- **snake_case** for all file and directory names: `posts_list_screen.dart`, `auth_repository_impl.dart`
- Feature directories use singular nouns: `auth/`, `home/`, `profile/`
- Layer directories use plural nouns for collections: `models/`, `entities/`, `usecases/`, `screens/`, `widgets/`, `datasources/`, `repositories/`

### File Naming by Type

| Type | Pattern | Example |
|------|---------|---------|
| Entity | `<name>.dart` | `post.dart`, `user.dart` |
| Model | `<name>_model.dart` | `post_model.dart`, `user_model.dart` |
| Repository (abstract) | `<name>_repository.dart` | `posts_repository.dart`, `auth_repository.dart` |
| Repository (impl) | `<name>_repository_impl.dart` | `posts_repository_impl.dart` |
| Data source (abstract) | `<name>_datasource.dart` | `posts_datasource.dart` |
| Data source (impl) | `<name>_datasource_impl.dart` | `posts_datasource_impl.dart` |
| BLoC | `<feature>_bloc.dart` | `posts_bloc.dart`, `auth_bloc.dart` |
| Events | `<feature>_event.dart` | `posts_event.dart` |
| States | `<feature>_state.dart` | `posts_state.dart` |
| Screen | `<name>_screen.dart` | `login_screen.dart`, `posts_list_screen.dart` |
| Widget | `<name>.dart` (descriptive) | `post_card.dart` |
| Use case | `<action>_<subject>.dart` or `<action>_usecase.dart` | `get_posts.dart`, `login_usecase.dart` |
| Core utility | `<purpose>_<type>.dart` | `api_client.dart`, `app_theme.dart`, `settings_storage.dart` |

### Classes

- **PascalCase** for all class names: `PostsBloc`, `AuthRepositoryImpl`
- Entities: plain name — `Post`, `User`
- Models: suffixed with `Model` — `PostModel`, `UserModel`
- Abstract repositories: `<Name>Repository` — `PostsRepository`, `AuthRepository`
- Concrete repositories: `<Name>RepositoryImpl` — `PostsRepositoryImpl`
- Abstract data sources: `<Name>DataSource` — `PostsDataSource`
- Concrete data sources: `<Name>DataSourceImpl` — `PostsDataSourceImpl`
- Abstract interfaces (core): plain name — `ApiClient`
- Concrete implementations (core): suffixed with `Impl` — `ApiClientImpl`
- BLoC classes: `<Feature>Bloc` — `PostsBloc`, `AuthBloc`, `ProfileBloc`
- Events: verb-based PascalCase — `LoadPosts`, `PostsUpdated`, `LoadMorePosts`
- States: adjective/status-based PascalCase — `PostsInitial`, `PostsLoading`, `PostsLoaded`, `PostsError`
- Failures: `<Type>Failure` — `ServerFailure`, `AuthFailure`, `ValidationFailure`
- Exceptions: `<Type>Exception` — `ServerException`, `CacheException`
- Use cases: action-based — `GetPosts`, `LoginUseCase`
- Screens: `<Name>Screen` — `LoginScreen`, `PostsListScreen`, `ProfileScreen`

### Methods & Variables

- **camelCase** for methods, variables, and parameters: `getPosts()`, `authorId`, `createdAt`
- Private fields prefixed with underscore: `_repository`, `_client`, `_dataSource`
- Constructor injection for dependencies: `PostsRepositoryImpl(this._dataSource)`
- Factory constructors for deserialization: `factory PostModel.fromJson(Map<String, dynamic> json)`
- Conversion methods: `toEntity()`, `toJson()`, `fromJson()`
- BLoC handler methods: `_on<EventName>` — `_onLoadPosts`, `_onPostsUpdated`
- Boolean getters/methods: use `is`/`has` prefix when applicable

### JSON Keys (Supabase/API)

- **snake_case** matching database column names: `author_id`, `created_at`
- Model `fromJson()` maps snake_case keys to camelCase Dart fields
- Model `toJson()` maps camelCase fields back to snake_case keys

## Tech Stack

- Flutter 3.24+ / Dart 3.5+
- flutter_bloc 8.1.6, dartz 0.10.1, supabase_flutter, dio 5.7.0
- get_it 8.0.2 for DI, shared_preferences for local storage
- mocktail 1.0.4 for test mocks