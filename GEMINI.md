# GEMINI.md

This file provides overarching guidance and context for Gemini when interacting with this repository.

## Overview
- **Project Structure**: Flutter/Dart mobile blog application.
- **Goal**: Serve as an educational reference project for the "Developer X AI" course.
- **Core Strategy**: This codebase uses a very strict interpretation of Clean Architecture mixed with the BLoC pattern. Make sure you adhere to the separations of concerns defined below.

## Tech Stack Context
- **Frameworks**: Flutter 3.24+, Dart 3.5+
- **Database/Backend**: Supabase
- **State Management**: `flutter_bloc`
- **Error Handling Pipeline**: `dartz` (`Either<Failure, T>`)
- **Dependency Injection**: `get_it`
- **HTTP Client/Requests**: `dio`
- **Testing Capabilities**: `mocktail`, `bloc_test`

## The 3-Layer Clean Architecture Rules
Whenever adding features or modifying behavior inside `lib/features/`, you must enforce isolating the code among three layers:

### 1. Domain Layer (`domain/`)
- **Entities** (`entities/`): Pure dart classes that hold data. No specific JSON decoding/encoding annotations. No `dynamic` types.
- **Repositories** (`repositories/`): Abstract interface definitions defining what the data layer must fulfill. NEVER deal with the UI from here. 
- **UseCases** (`usecases/`): Actionable rules doing a specific operation (e.g., GetUserUseCase). Returns an `Either<Failure, T>`.

### 2. Data Layer (`data/`)
- **Models** (`models/`): Provide serialization/deserialization. Always provide `toEntity()` or `fromEntity()` to bridge data to domain.
- **DataSources** (`datasources/`): API clients, database queries, SharedPreferences logic. Methods here may throw a `ServerException` or `CacheException`.
- **Implementations**: The concrete subclasses of domain repositories. They catch exceptions from datasources and return `Left(Failure())` or `Right(data)` to the requesting UseCase.

### 3. Presentation Layer (`presentation/`)
- **State** (`bloc/` or `cubit/`): Handle the logic. A Bloc invokes a UseCase, awaits the `Either` result, folds the result, and emits `LoadedState` or `ErrorState`. Use `Equatable` for states/events.
- **UI Components** (`screens/` and `widgets/`): Visual representations purely reflecting the emitted states from blocs. Use `get_it` location (or BlocProvider) to get instances. Keep Logic out of UI files.

## Behavior Instructions for Gemini
1. **Never use `dynamic` keyword**: Write highly-typed implementations.
2. **Favor immutability**: Make properties and classes `final` whenever appropriate. Use generic types strictly.
3. **Handle Errors strictly**: Never throw exceptions in UI or Domain layers. Convert to `Failure` types using `dartz` in the data layer implementation. 
4. **Follow conventions**: camelCase variables, PascalCase classes, snake_case for file names and folder structures. Follow Flutter's trailing comma patterns.
5. **Testing First**: Provide extensive tests utilizing `mocktail` referencing matching files inside the `test/` directory.
