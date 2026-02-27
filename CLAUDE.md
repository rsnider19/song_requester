# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

Song Requester is a Flutter mobile app for requesting songs at events. A performer can create an event and share a link with their audience. The audience can then request songs to be played at the event. The performer can also set a list of songs that they can play at the event.

When requesting a song, the user can attach a tip to the request. The tip is a monetary amount that the user is willing to pay to have their song played. The tip is paid to the performer. The tip is paid in USD. The tip is paid through Stripe.

Users are able to see a leaderboard of the top requested songs for that performer, but the tip amount is hidden.

The performer will be able to see the total tips they have received for the event and the total tips for each song. When they play a song, the money is then collected from the user and given to the performer.

## Build & Run Commands

```bash
# Run with flavor (development/staging/production)
fvm flutter run --flavor development --target lib/main_development.dart
fvm flutter run --flavor staging --target lib/main_staging.dart
fvm flutter run --flavor production --target lib/main_production.dart

# Run tests
very_good test --coverage --test-randomize-ordering-seed random

# Run a single test file
fvm flutter test test/path/to/test_file.dart

# Code generation (Drift, Freezed, Riverpod, JSON serializable)
fvm dart run build_runner build --delete-conflicting-outputs

# Watch mode for code generation
fvm dart run build_runner serve --delete-conflicting-outputs

# Analyze code
fvm flutter analyze
fvm dart run custom_lint  # NOTE: currently broken — see Known Tooling Issues below
```

## Architecture

### State Management & Backend

- **Riverpod** for state management with code generation (`riverpod_annotation`, `riverpod_generator`)
  - Always use `riverpod_generator` to generate providers and notifiers.
  - Use `@Riverpod(keepAlive: true)` for app-wide providers. Omit for screen-scoped providers.
  - Notifier class names follow the pattern `<ClassName>StateNotifier`.
  - **Stream subscriptions in `build()`**: Never store a `StreamSubscription` as a class field. Use a local variable in `build()` and register cleanup with `ref.onDispose`. Riverpod calls `onDispose` before each rebuild, so cancellation is automatic.
    ```dart
    @override
    UserProfile? build() {
      final sub = service.watchSomething().listen((value) { state = value; });
      ref.onDispose(() => unawaited(sub.cancel()));
      return null;
    }
    ```
    This avoids both the `cancel_subscriptions` and `discarded_futures` lint errors.
- **Supabase** for backend (auth, database via PostgREST, storage, edge functions)
- **Drift** for local SQLite caching and offline support

### Approved Package List

Use these packages when their use case arises. Do not reach for alternatives.

| Package | Use case |
|---------|----------|
| `cached_network_image` | All remote image loading |
| `dartx` | Extended Dart iterables/collections utilities |
| `flutter_secure_storage` | Storing sensitive values (tokens, keys) |
| `gap` | Spacing in `Row`/`Column`/`Flex` — use instead of `SizedBox` for gaps |
| `permission_handler` | Runtime permission requests (location, camera, etc.) |
| `recase` | String case conversion (camelCase, snake_case, etc.) |
| `sliver_tools` | Advanced sliver layouts in custom scroll views |
| `uuid` | Generating UUIDs client-side |

### Supabase & PostgREST

Data fetching uses Supabase's PostgREST client (`supabase_flutter`). Key patterns:

```dart
// Query with filters
final response = await supabase
    .from('table_name')
    .select('id, name, relation:other_table(id, name)')
    .eq('user_id', userId)
    .order('created_at', ascending: false);

// Insert
final response = await supabase
    .from('table_name')
    .insert({'column': value})
    .select()
    .single();

// Update
await supabase
    .from('table_name')
    .update({'column': value})
    .eq('id', id);

// Delete
await supabase
    .from('table_name')
    .delete()
    .eq('id', id);

// RPC (stored procedures)
final response = await supabase.rpc('function_name', params: {'param': value});
```

### Database Conventions

- **Table names are singular**: `public.profile`, `public.gig`, never `public.profiles`
- **Primary keys**: always `<table_name>_id uuid` (e.g., `profile_id uuid primary key`)
- **Foreign keys**: always indexed — create an explicit index after every FK declaration
- **Views**: always defined with `with (security_invoker = true)` so RLS applies to the caller
- **Prefer views over functions** for data access patterns
- **Always check indexes** when building views or PostgREST queries (index all join/filter columns)
- **`search_path = ''`**: required on all functions and `security definer` clauses

### Supabase Migrations

**Always use fully qualified names** for all identifiers in migration files — `public.profile`, `auth.users`, never bare names that rely on `search_path`.

**RLS policies must follow these performance conventions on every policy:**

```sql
-- ✅ CORRECT
create policy "Users can view own profile"
  on public.profile
  for select
  to authenticated                               -- always specify role
  using ((select auth.uid()) = profile_id);      -- wrap in (select ...) for initPlan cache

-- ❌ WRONG
create policy "Users can view own profile"
  on public.profile
  using (auth.uid() = profile_id);              -- missing role, unwrapped auth.uid()
```

- Wrap `auth.uid()` as `(select auth.uid())` — caches result per-statement, not per-row (~95% perf improvement)
- Always specify `to authenticated` (or `to anon`) — prevents evaluation for irrelevant roles
- `UPDATE` policies require both `using` and `with check`
- Index all columns referenced in policy conditions
- All functions: use `security definer set search_path = ''` to enforce fully qualified names inside the body

Reference: [Supabase RLS best practices](https://supabase.com/docs/guides/database/postgres/row-level-security)

### Database Schema

The database schema is defined in `supabase/schema.ts` (generated TypeScript types). When working with data:

1. Reference `schema.ts` for table structures and relationships
2. Use the exact column names from the schema
3. Respect foreign key relationships for joins

### Freezed

Always use the `freezed` package for domain models. Use the `@freezed` annotation, always include `fromJson`/`toJson`, and always declare the class as `abstract`.

### Code Generation

Generated files have these extensions:

- `*.g.dart` - JSON serializable, Riverpod, Drift
- `*.freezed.dart` - Freezed immutable classes
- `*.gen.dart` - Flutter Gen (assets)

### Flavor Configuration

Three environments configured via `.env` files in the `env/` directory:

- `env/.env.development`
- `env/.env.staging`
- `env/.env.production`

Each flavor has its own entry point (`lib/main_*.dart`) that passes the env path to `bootstrap()`.

### Project Structure

- `lib/app/` - App widget, database
- `lib/services/` - Shared service classes (e.g., DotEnvService)
- `lib/features/` - Feature modules
  - `application/` - Services and providers shared across features
  - `domain/` - Freezed domain models and Drift tables
  - `data/` - Repositories and data access
  - `presentation/` - UI and state management
    - `screens/` - Screens
    - `widgets/` - Widgets
    - `providers/` - UI providers
- `lib/gen/` - Generated asset references
- `supabase/schema.ts` - Generated database types (reference for table structures)

## Definition of Done

Work is **not complete** until both linters pass with zero issues (errors, warnings, and infos):

```bash
fvm flutter analyze
fvm dart run custom_lint
```

Always run both before declaring any task finished. Fix all reported issues — do not suppress or ignore them unless there is a documented reason.

**Known Tooling Issue**: `fvm dart run custom_lint` currently fails to build because `custom_lint 0.8.1` requires `analyzer ^8.0.0` (which exports `element2.dart`), but the project pins `analyzer: ^10.0.0` (which removed that file). This is a pre-existing conflict — no single analyzer version satisfies all packages simultaneously. Until `custom_lint` publishes a version supporting `analyzer 10.x`, treat `fvm flutter analyze` as the sole static analysis gate.

## Code Styles

### Dart

- Uses `very_good_analysis` lint rules
- Page width: 120 characters
- Trailing commas: preserved
- Generated files are excluded from analysis
- **`const` ternaries**: When all branches of a ternary are compile-time constants, declare the result `const` not `final`. The `prefer_const_declarations` lint enforces this.
  ```dart
  // ✅ CORRECT
  const level = kDebugMode ? Level.debug : kReleaseMode ? Level.warning : Level.info;
  // ❌ WRONG
  final level = kDebugMode ? Level.debug : kReleaseMode ? Level.warning : Level.info;
  ```
- **Single-method abstracts**: The `one_member_abstracts` lint forbids single-method abstract classes. Use a `typedef` instead.
  ```dart
  // ✅ CORRECT — typedef for callback injection
  typedef ErrorReporter = void Function(dynamic message, {Object? error, StackTrace? stackTrace});
  // ❌ WRONG — triggers one_member_abstracts
  abstract interface class ErrorReporter { void report(dynamic message, ...); }
  ```
  In tests, replace `Mock implements SomeTypedef` (invalid) with a capturing lambda:
  ```dart
  late List<dynamic> reporterCalls;
  setUp(() {
    reporterCalls = [];
    service = MyService(reporter: (msg, {error, stackTrace}) => reporterCalls.add(msg));
  });
  ```

### Git

- Always use conventional commits for commit messages

## Feature Development Patterns

### SPEC Files

Each feature has a `SPEC.md` with: Overview, Requirements, Architecture, Components, Data Operations, Integration, Testing Requirements, Future Considerations, and checkbox-based Success Criteria.

### Feature Directory Structure

```
lib/features/<feature>/
├── SPEC.md
├── domain/              # Freezed models, exceptions
├── data/
│   └── repositories/    # Data access (class + provider in same file)
├── application/         # Services, business logic (class + provider in same file)
└── presentation/        # Screens, widgets, UI providers
```

### Domain Models

Use Freezed for all domain models:

```dart
@freezed
abstract class Item with _$Item {
  const factory Item({
    required String id,
    required String userId,
    required DateTime createdAt,
    String? notes,
  }) = _Item;
  factory Item.fromJson(Map<String, dynamic> json) => _$ItemFromJson(json);
}
```

### Repository Pattern

"Dumb" data access layer: fetch/mutate only, no business logic. Accept all IDs/params (no provider dependencies). Return domain models, throw custom exceptions, log errors only, fail fast (no retry). Use `@Riverpod(keepAlive: true)`. **Only called from services, never from UI.** Combine class + provider in same file with provider at the bottom.

```dart
class ItemRepository {
  ItemRepository(this._supabase, this._logger);
  final SupabaseClient _supabase;
  final LoggingService _logger;

  Future<Item> getById(String id) async {
    try {
      final response = await _supabase
          .from('items')
          .select('*')
          .eq('id', id)
          .single();
      return Item.fromJson(response);
    } catch (e, st) {
      _logger.e('Failed to fetch item', error: e, stackTrace: st);
      throw ItemException('Could not load item', e.toString());
    }
  }

  Future<Item> create(CreateItem item) async {
    final response = await _supabase
        .from('items')
        .insert(item.toJson())
        .select()
        .single();
    return Item.fromJson(response);
  }
}

@Riverpod(keepAlive: true)
ItemRepository itemRepository(Ref ref) =>
    ItemRepository(ref.watch(supabaseProvider), ref.watch(loggingServiceProvider));
```

### Service Pattern

Business logic layer: validate input, coordinate repositories/providers, enrich data. Use `@Riverpod(keepAlive: true)`. Throw specific exceptions. **Services are the only layer that calls repositories.** Combine class + provider in same file with provider at the bottom.

```dart
class ItemService {
  ItemService(this._repository, this._logger);
  final ItemRepository _repository;
  final LoggingService _logger;

  Future<Item> create({required String userId, String? notes}) async {
    if (userId.isEmpty) throw ValidationException('User required');

    final item = CreateItem(userId: userId, notes: notes);
    return _repository.create(item);
  }
}

@Riverpod(keepAlive: true)
ItemService itemService(Ref ref) =>
    ItemService(ref.watch(itemRepositoryProvider), ref.watch(loggingServiceProvider));
```

### Exception Handling

Custom exceptions per feature with `message` (user-facing) and `technicalDetails` (logging):

```dart
abstract class FeatureException implements Exception {
  const FeatureException(this.message, [this.technicalDetails]);
  final String message;
  final String? technicalDetails;
}
```

### Provider Patterns

- **Repositories/Services**: `@Riverpod(keepAlive: true)`
- **State notifiers**: Class named `<ClassName>StateNotifier` generates `classNameStateProvider`
- **UI providers**: `@riverpod` (auto-dispose) unless app-wide
- Use `ref.watch()` for reactive dependencies
- **`keepAlive` notifiers seeding from other providers**: Use `ref.watch` (not `ref.read`) in `build()` so the notifier rebuilds when the dependency changes. Using `ref.read` freezes the seed value at first-build time — e.g. a mode notifier seeded from auth state won't reset correctly after sign-out/sign-in within the same session.

### Testing

Write unit tests for repositories (mock Supabase client), services (mock repositories), and domain models. Write widget tests for UI (loading/error/success states). Focus on behaviors over coverage percentages.

### Validation & Configuration

- Services validate (not repositories), throw specific exceptions
- Use environment variables via `DotEnvService` for thresholds/config

### UI/UX

- **EXCLUSIVELY use `shadcn_ui` package for all widgets.** Do not use raw Material or Cupertino widgets directly.
- If no `shadcn_ui` widget exists for a use case, create a custom widget in `lib/widgets/` — this directory is for **app-level shareable widgets only**.
- **Exception — `Scaffold`**: `shadcn_ui` itself uses `Scaffold` internally, so it is permitted when needed (e.g. shell screens). Import it explicitly: `import 'package:flutter/material.dart' show Scaffold;` — never import all of `flutter/material.dart`.
- Loading (shimmer/progress), error (retry button), empty states (CTA)
- Confirmation dialogs for destructive actions
- Accessibility: semantic labels, contrast, 48x48dp touch targets

### Permissions

1. Primer screen → 2. Request → 3. Denied screen ("Open Settings") → 4. Router guards → 5. Initialize in bootstrap

### Navigation & Errors

- GoRouter in `app_router.dart` with guards
- SnackBars for transient feedback, Dialogs for errors requiring action
- User-friendly messages, log technical details, no auto-retry
- **Redirect guard ordering**: Always check authentication first (before any mode or role routing). If `profile == null && loc != '/sign-in'` → redirect to `/sign-in`. This must be the first check to prevent unauthenticated users from hitting mode/role guards.

### Mock Data

Mock repositories with delays for realistic UX testing. Easy swap to real implementation. Same file structure (class + provider).

### Success Criteria

SPEC.md checklist: domain models, data operations, repositories, services, providers, integration, tests, docs.
