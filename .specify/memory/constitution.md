<!--
  Sync Impact Report
  ===================
  Version change: (none) → 1.0.0 (initial population)
  Modified principles: N/A (first population from template)
  Added sections:
    - 5 Core Principles derived from CLAUDE.md
    - Technical Constraints section
    - Development Workflow section
    - Governance section
  Removed sections: None
  Templates requiring updates:
    - .specify/templates/plan-template.md — ✅ aligned (Constitution Check
      section references gates from constitution)
    - .specify/templates/spec-template.md — ✅ aligned (requirements use
      MUST language consistent with constitution)
    - .specify/templates/tasks-template.md — ✅ aligned (phase structure
      supports story-based delivery)
  Follow-up TODOs: None
-->

# Blog App Constitution

## Core Principles

### I. Clean Architecture Layer Boundaries

Every feature module MUST be organized into three layers with a strict
dependency direction: **Presentation → Domain ← Data**.

- Presentation MUST NOT import from `data/` directly.
- Data and Presentation both depend on Domain; they MUST NOT depend on
  each other.
- Each feature is self-contained within `lib/features/<feature>/` with
  its own `data/`, `domain/`, and `presentation/` subdirectories.
- New code MUST NOT be created outside the established folder structure.

**Rationale**: Enforcing unidirectional dependencies keeps the domain
logic decoupled from infrastructure concerns, enabling independent
testing and future backend swaps without touching business rules.

### II. Domain Purity

The domain layer MUST contain only pure Dart with zero framework imports.

- Entities MUST be immutable with `final` fields and `const` constructors.
- Repository interfaces and use cases MUST NOT import Flutter, Supabase,
  Dio, or any external package.
- Use cases MUST be single-purpose with one public `call()` method. Use a
  params class when multiple inputs are required.
- Business logic (validation, transformations) MUST reside in use cases
  or repositories, never in BLoCs or widgets.

**Rationale**: A pure domain layer is the foundation of Clean
Architecture. Framework-free business logic remains testable, portable,
and comprehensible without infrastructure knowledge.

### III. Structured Error Handling

All error propagation MUST follow the established flow:

```
DataSource (throws ServerException / CacheException)
  → Repository (catches → returns Either<Failure, T>)
    → UseCase (passes through or adds ValidationFailure)
      → BLoC (folds Either → emits success or error state)
        → Screen (renders based on state)
```

- Repositories MUST catch all exceptions and return `Either<Failure, T>`.
  Exceptions MUST NOT leak past the repository boundary.
- The failure hierarchy (`ServerFailure`, `AuthFailure`,
  `ValidationFailure`) MUST be used; raw exception types MUST NOT reach
  the presentation layer.
- Error messages in the UI MUST originate from domain-layer failures,
  not hardcoded strings.

**Rationale**: A single, predictable error flow prevents unhandled
exceptions from crashing the app and gives every layer a consistent
contract for failure handling.

### IV. Dependency Inversion

Abstract interfaces MUST be defined before concrete implementations at
every system boundary.

- Every data source, repository, and core service MUST have an abstract
  contract (e.g., `PostsDataSource`) paired with a concrete
  implementation (e.g., `PostsDataSourceImpl`).
- All dependencies MUST be injected via constructors and registered
  in `core/di/` using get_it.
- Models MUST mirror domain entities and provide `fromJson()`,
  `toJson()`, and `toEntity()` converters. Data models MUST NOT be used
  directly in the presentation layer.

**Rationale**: Programming against abstractions enables swapping
implementations (e.g., mock data sources for testing) without modifying
consuming code, and keeps the dependency graph clean.

### V. Convention Consistency

All code MUST follow the project's established naming and structural
conventions.

- **Files**: `snake_case` — e.g., `posts_list_screen.dart`,
  `auth_repository_impl.dart`.
- **Classes**: `PascalCase` with role suffixes — `*Model`, `*Impl`,
  `*Bloc`, `*Screen`, `*Failure`, `*Exception`.
- **Methods/variables**: `camelCase` with underscore-prefixed privates.
- **JSON keys**: `snake_case` matching Supabase column names.
- Feature directories use singular nouns (`auth/`, `home/`). Layer
  directories use plural nouns (`models/`, `screens/`, `repositories/`).
- BLoC pattern MUST use separated event and state classes. Screens MUST
  use `BlocBuilder` for reactive UI and `BlocListener` for side effects.

**Rationale**: Uniform conventions reduce cognitive overhead, make the
codebase navigable by pattern, and prevent naming drift across features.

## Technical Constraints

- New packages MUST NOT be added to `pubspec.yaml` without explicit
  approval. Problems MUST be solved with existing dependencies first.
- `core/` files MUST NOT be modified without discussing the cross-feature
  impact, since they affect all features.
- Supabase credentials and API keys MUST NOT be committed. Source code
  MUST retain placeholders only.
- The tech stack is fixed: Flutter 3.24+ / Dart 3.5+, flutter_bloc,
  dartz, supabase_flutter, dio, get_it, shared_preferences, mocktail.

## Development Workflow

- `flutter analyze` MUST be run before considering any work complete.
- All new feature code MUST be placed in the appropriate layer within
  `lib/features/<feature>/` or `lib/core/`.
- Widgets MUST be kept small and reusable. Repeated UI patterns MUST be
  extracted into `presentation/widgets/`.
- Abstract interfaces MUST be created before their concrete
  implementations in all cases.
- Constructor injection MUST be used for all dependencies.

## Governance

This constitution is the authoritative source of non-negotiable rules
for the Blog App project. It supersedes informal practices and ad-hoc
decisions when conflicts arise.

- **Amendment procedure**: Any change to this constitution MUST be
  documented with a version bump, rationale, and sync impact report.
  Changes to principles require MAJOR version increments. New sections
  or material expansions require MINOR. Clarifications require PATCH.
- **Versioning policy**: This document follows semantic versioning
  (MAJOR.MINOR.PATCH). The Sync Impact Report at the top of this file
  MUST be updated with every amendment.
- **Compliance review**: All feature plans, specs, and task lists MUST
  reference the Constitution Check gate in the plan template. Reviewers
  MUST verify that implementations comply with these principles.
- **Runtime guidance**: `CLAUDE.md` at the repository root serves as the
  runtime development guidance file and MUST remain consistent with this
  constitution.

**Version**: 1.0.0 | **Ratified**: 2026-04-07 | **Last Amended**: 2026-04-07