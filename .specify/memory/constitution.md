<!--
  Sync Impact Report
  ==================
  Version change: N/A (template) → 1.0.0
  Modified principles: N/A (initial ratification)
  Added sections:
    - Core Principles (5 principles)
    - Architecture Constraints
    - Development Workflow
    - Governance
  Removed sections: None
  Templates requiring updates:
    - .specify/templates/plan-template.md — ✅ aligned
      (Constitution Check section already generic; principles map to gates)
    - .specify/templates/spec-template.md — ✅ aligned
      (Requirements and success criteria compatible with principles)
    - .specify/templates/tasks-template.md — ✅ aligned
      (Phase structure supports layer-ordered implementation)
  Follow-up TODOs: None
-->

# Blog App Constitution

## Core Principles

### I. Clean Architecture

Every feature MUST be organized into three layers with a strict
dependency direction: **Presentation → Domain ← Data**.

- Presentation MUST NOT import from `data/`.
- Data and Presentation depend on Domain, never on each other.
- Each feature is self-contained under `lib/features/<feature>/`
  with `data/`, `domain/`, and `presentation/` sub-directories.
- Shared, non-feature code lives in `lib/core/` only.

**Rationale**: Enforcing layer boundaries keeps business logic
portable, testable, and independent of framework or data-source
changes.

### II. Contract-First Design

Every boundary MUST define an abstract interface before any
concrete implementation is written.

- Data sources: `<Name>DataSource` (abstract) →
  `<Name>DataSourceImpl` (concrete).
- Repositories: `<Name>Repository` (abstract) →
  `<Name>RepositoryImpl` (concrete).
- Core utilities: `ApiClient` (abstract) → `ApiClientImpl`
  (concrete).
- All concrete implementations MUST be registered in `core/di/`
  via get_it and resolved through constructor injection.

**Rationale**: Coding against abstractions enables substitution
for testing and future backend changes without touching consumers.

### III. Type-Safe Error Handling

Errors MUST flow through a structured pipeline; exceptions MUST
NOT leak across layer boundaries.

- Data sources throw `ServerException` or `CacheException`.
- Repositories catch those exceptions and return
  `Either<Failure, T>` (via dartz).
- Use cases pass the `Either` through or add
  `ValidationFailure`.
- BLoCs fold the `Either` into success or error states.
- Screens render based on the emitted state.
- Repositories MUST NEVER throw; they MUST always return
  `Either`.

**Rationale**: A single, predictable error path prevents
unhandled crashes and keeps error presentation consistent across
the app.

### IV. Pure Domain Layer

The domain layer MUST remain free of framework and infrastructure
concerns.

- Entities use `final` fields and `const` constructors; no
  serialization logic.
- Models (data layer) mirror entities and provide `fromJson()`,
  `toJson()`, and `toEntity()`. Models MUST NOT appear in
  presentation code.
- Use cases expose a single public `call()` method. One use case
  = one business action.
- No Flutter, Supabase, Dio, or other package imports are
  permitted in `domain/`.

**Rationale**: A pure domain layer can be reasoned about, tested,
and reused without any runtime dependencies.

### V. Dependency Inversion

All runtime dependencies MUST be injected, never instantiated
inline.

- Constructor injection is the sole mechanism for providing
  dependencies to classes.
- `core/di/` registers every concrete implementation with
  get_it.
- No class may construct its own collaborators via `new` or
  static access (except factory constructors for deserialization
  in models).

**Rationale**: Explicit injection makes the dependency graph
visible, testable, and reconfigurable without code changes.

## Architecture Constraints

- **No unauthorized packages.** New dependencies MUST NOT be
  added to `pubspec.yaml` without prior approval. Solve problems
  with the existing stack first.
- **Model/Entity separation is mandatory.** Data models
  (`*_model.dart`) handle serialization; domain entities handle
  business identity. Presentation code MUST only use entities.
- **No business logic in presentation.** Validation, data
  transformation, and decision-making belong in use cases or
  repositories, not in BLoCs or widgets.
- **No hardcoded credentials.** Supabase URLs, API keys, and
  secrets MUST remain as placeholders in source code.
- **Core is shared infrastructure.** Changes to `lib/core/`
  affect all features and MUST be discussed before implementation.
- **File placement.** New code MUST go into
  `lib/features/<feature>/` or `lib/core/`. No top-level ad-hoc
  directories.
- **Naming conventions.** Files use `snake_case`, classes use
  `PascalCase`, methods/variables use `camelCase`. Suffixes
  (`Model`, `Impl`, `Bloc`, `Screen`, `Failure`, `Exception`)
  MUST follow the documented patterns in CLAUDE.md.

## Development Workflow

- **Static analysis.** `flutter analyze` MUST pass before work
  is considered complete.
- **State management.** All features use the BLoC pattern with
  separated event and state classes. `BlocBuilder` for reactive
  UI; `BlocListener` for side effects.
- **Widget granularity.** Repeated UI patterns MUST be extracted
  into `presentation/widgets/`.
- **Real-time updates.** Features requiring live data MUST
  subscribe to Supabase real-time streams and dispatch update
  events through the BLoC.
- **Error messages.** UI MUST NOT hardcode error strings; use
  failure messages propagated from the domain layer.

## Governance

This constitution is the authoritative source of architectural
and process rules for the Blog App project. It supersedes any
ad-hoc decisions or undocumented conventions.

### Amendment Procedure

1. Propose the change with a rationale and impact assessment.
2. Update this document and increment the version per the
   versioning policy below.
3. Run the consistency propagation checklist (plan, spec, tasks,
   and command templates) and update any affected artifacts.
4. Record the change in the Sync Impact Report comment at the
   top of this file.

### Versioning Policy

- **MAJOR**: Removal or backward-incompatible redefinition of a
  principle.
- **MINOR**: New principle or materially expanded guidance added.
- **PATCH**: Clarifications, wording fixes, non-semantic
  refinements.

### Compliance

- All implementation plans MUST include a Constitution Check gate
  that verifies alignment with these principles before design
  proceeds.
- Code reviews MUST verify compliance with layer boundaries,
  error handling flow, and naming conventions.

**Version**: 1.0.0 | **Ratified**: 2026-04-07 | **Last Amended**: 2026-04-07