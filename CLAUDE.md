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

Uses Clean Architecture with three layers per feature module under `lib/features/`:

- **Domain** (`domain/`) — Entities, abstract repository interfaces, use cases. No framework dependencies.
- **Data** (`data/`) — Models (JSON-serializable entities), data source abstractions + implementations, repository implementations. Converts exceptions to `Either<Failure, T>` using dartz.
- **Presentation** (`presentation/`) — BLoC (events/states), screens, widgets. Uses `flutter_bloc`.

Shared utilities live in `lib/core/`: error types (`errors/`), network client (`network/`), local storage (`storage/`), theming (`theme/`).

### Key Patterns

- **Error handling**: Data sources throw `ServerException`/`CacheException`. Repositories catch and return `Either<Failure, T>`. BLoCs fold the Either to emit error or success states.
- **Dependency inversion**: Abstract classes (`ApiClient`, repository interfaces) define contracts; concrete implementations are injected via get_it.
- **Real-time**: PostsBloc subscribes to Supabase real-time streams on the `posts` table.
- **Models vs Entities**: Models in `data/models/` handle JSON serialization and expose `toEntity()`/`fromEntity()` converters. Domain entities are plain immutable objects.

### Feature Modules

- `auth/` — Login flow with Supabase authentication
- `posts/` — CRUD + search for blog posts with real-time updates
- `home/` — Home page with categories and tags
- `profile/` — User profile management

## Tech Stack

- Flutter 3.24+ / Dart 3.5+
- flutter_bloc 8.1.6, dartz 0.10.1, supabase_flutter, dio 5.7.0
- get_it 8.0.2 for DI, shared_preferences for local storage
- mocktail 1.0.4 for test mocks