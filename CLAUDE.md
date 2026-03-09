# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Commands

```bash
# Install dependencies
flutter pub get

# Run the app (dev flavor)
flutter run --flavor dev -t lib/main_dev.dart

# Analyze code (must pass with zero warnings)
flutter analyze

# Run all tests
flutter test

# Regenerate code (after modifying DTOs, Entities, or injection annotations)
dart run build_runner build --delete-conflicting-outputs

# Watch mode for code generation (during development)
dart run build_runner watch --delete-conflicting-outputs

# Regenerate flavors (save main.dart and app.dart first!)
dart run flutter_flavorizr
```

## Architecture

This is a Flutter starter kit using **Clean Architecture** with strict layer separation, **BLoC** for state management, and **BDD/Gherkin** tests.

### Layer Structure

```
lib/
├── core/      # Technical infrastructure (DI, network, configuration)
├── data/      # Data layer (DTOs, repositories, API clients)
├── domain/    # Business layer (entities, use cases)
├── ui/        # Presentation layer (pages, BLoCs, widgets)
└── main_*.dart  # Flavor-specific entry points
```

**Import rules (strict):**
- `ui/` → imports only `domain_module.dart`
- `domain/` → imports only `data_module.dart`
- `data/` → imports `core_module.dart`
- Never import individual files from another layer; always import via `*_module.dart`

### `*_module.dart` Files

Every folder has a `*_module.dart` that exports the public API of that layer. When adding new files, export them through the appropriate module file.

### Navigation (go_router)

Routes are registered by each feature's `*_module.dart` via its `configure()` method, which calls `_appRouter.addRoute(...)`. No central route file — features self-register on initialization.

### BLoC Screen Structure

```
feature_name/
├── view/
│   ├── components/          # Stateless reusable widgets
│   ├── feature_page.dart    # Initializes the BLoC
│   └── feature_view.dart    # Displays the screen, manages state
├── feature_bloc.dart
├── feature_event.dart
├── feature_state.dart
├── feature_interactor.dart  # Anti-Corruption Layer between UI and Domain
└── feature_module.dart      # Injects routes into the router
```

### Dependency Injection

Uses `get_it` + `injectable`. Annotations:
- `@singleton` for Use Cases and Interactors
- `@injectable` with `@factoryMethod` for Repositories

After adding/modifying annotated classes, run `dart run build_runner build --delete-conflicting-outputs`. Never manually edit `injection.config.dart`.

### Data Conversion (Anti-Corruption Layer)

DTOs are only used in the `data/` layer. Conversion to domain entities is done via `Entity.fromDto(dto)` factory constructors. BLoC states must use domain Entities, never DTOs.

### Generated Files (Never Edit Manually)

- `*.g.dart` — Retrofit, JSON serialization
- `*.freezed.dart` — Freezed value objects
- `lib/injection.config.dart` — Injectable DI config

## Flavors

| Flavor        | Entry Point                 | Purpose              |
|---------------|-----------------------------|----------------------|
| `prod`        | `lib/main_prod.dart`        | Production           |
| `preprod`     | `lib/main_preprod.dart`     | Pre-production       |
| `recette`     | `lib/main_recette.dart`     | UAT/Recette          |
| `integration` | `lib/main_integration.dart` | Integration tests    |
| `dev`         | `lib/main_dev.dart`         | Local development    |
| `test`        | `lib/main_test.dart`        | Automated tests      |

Never delete `prod`, `dev`, or `test` flavors.

## Testing

BDD tests use Gherkin: write `.feature` files in `test/gherkin/features/` and step implementations (`.dart`) in `test/gherkin/steps/`. Three steps come pre-installed (app launch, route start, screen resize).

Async domain-to-UI data flow must use `Stream`, not `Future`.

API mocks go in `/mocks/api/` in the format:
```json
{ "GET": { "statusCode": 200, "data": {} } }
```

Test coverage targets: Use Cases 100%, BLoCs 90%, Repositories 80%.

## Commit Format

```
<JIRA-ticket> - <type>(<scope>) : <short summary>
```

Types: `build`, `ci`, `docs`, `feat`, `fix`, `perf`, `refactor`, `test`
Scopes: `core`, `data`, `domain`, `ui`, `design`

Example: `LIS-123 - feat(ui) : ajouter écran de connexion`
