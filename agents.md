# Universal AI Agents Guidelines

This file (`agents.md`) serves as the foundational rule set for any AI Coding Assistant or Autonomous Agent interfacing with this repository.

## Repository Context
- **Project Structure**: Flutter/Dart mobile application.
- **Goal**: Serve as an educational reference project for the "Developer X AI" course. 
- **Core Standard**: Strict separation of concerns via Clean Architecture stacked with BLoC for state management. 

## Architectural Requirements
Any code generated or refactored within `lib/features/` MUST strictly observe a 3-layer Clean Architecture.

### 1. Domain Layer (`domain/`)
- **Entities**: Pure Dart classes defining data models. No database or JSON dependencies. No serialization logic. 
- **Repositories**: Abstract contracts dictating what the data layer must fulfill. NEVER deal with the UI or UI elements here.
- **UseCases**: Actionable rules executing a single operation. Must return an `Either<Failure, T>` using the `dartz` package.

### 2. Data Layer (`data/`)
- **Models**: Extensions of entities that include `fromJson`, `toJson`, `toEntity()`, and `fromEntity()` logic.
- **DataSources**: The concrete APIs handling external systems (e.g., Supabase, Dio, or SharedPreferences). Methods throw exceptions (e.g., `ServerException`).
- **Repositories Info**: Catch data source exceptions and convert them into `Left(Failure())` objects. Do NOT throw exceptions from models back into UseCases.

### 3. Presentation Layer (`presentation/`)
- **State**: Implement strictly using `flutter_bloc` (Blocs or Cubits). Map data/failures back to logical user states (`Initial`, `Loading`, `Success`, `Error`).
- **UI Logic**: Screens and Widgets must be simple visual representations. Fetch dependencies natively via `get_it`. Keep business logic entirely out of UI files. 

## Coding Directives
1. **Strong Typing Required**: Banish the `dynamic` keyword. Write highly-typed implementations. 
2. **Prioritize Immutability**: Heavily utilize `final`. Define UI properties, class arguments, and Bloc state models robustly using `Equatable`.
3. **Handle Errors Safely**: Avoid unhandled throwings. Follow the domain/data/presentation flow ensuring users only see processed `Failure` messages, mitigating application crashes.
4. **Style Preferences**: Adhere to standard Dart conventions (`camelCase` methods, `PascalCase` classes) and implement Flutter trailing commas where applicable.
5. **Testing Mandate**: Supply unit tests bridging changes; favor `bloc_test` for states and `mocktail` for dependency isolation inside `test/`.

*If your underlying LLM model is Claude, refer to `CLAUDE.md`. If your underlying LLM is Gemini, refer to `GEMINI.md`.*
