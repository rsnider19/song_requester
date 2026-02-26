# Auth & Account Creation — Implementation Spec

## Overview
Bootstrap authentication for the app. Every user gets a persistent Supabase identity on first open via anonymous auth. Signed-in users unlock personalization and performer mode.

## What's in scope

### 1. Supabase local config (`supabase/config.toml`)
- `enable_anonymous_sign_ins = true`
- `enable_manual_linking = true`

### 2. Database migration
Migration files must use **fully qualified names** for all references.
RLS policies must follow [Supabase RLS best practices](https://supabase.com/docs/guides/database/postgres/row-level-security) — see performance conventions below.

```sql
create table public.profile (
  profile_id uuid references auth.users(id) on delete cascade primary key,
  email text,
  is_performer boolean not null default false,
  created_at timestamptz not null default now()
);

alter table public.profile enable row level security;

create policy "Users can view own profile"
  on public.profile
  for select
  to authenticated
  using ((select auth.uid()) = profile_id);

create policy "Users can update own profile"
  on public.profile
  for update
  to authenticated
  using ((select auth.uid()) = profile_id)
  with check ((select auth.uid()) = profile_id);

create or replace function public.handle_new_user()
returns trigger
language plpgsql
security definer set search_path = ''
as $$
begin
  insert into public.profile (profile_id, email)
  values (new.id, new.email);
  return new;
end;
$$;

create trigger on_auth_user_created
  after insert on auth.users
  for each row execute procedure public.handle_new_user();
```

**RLS performance conventions (apply to all migrations):**
- Wrap `auth.uid()` as `(select auth.uid())` — triggers PostgreSQL initPlan cache per-statement, not per-row
- Always specify `to <role>` — prevents evaluation for irrelevant roles
- UPDATE policies need both `using` and `with check`
- Index all columns referenced in policy conditions (PK/FK columns are already indexed)
- Use `security definer set search_path = ''` on all functions to force fully qualified names inside function bodies

### 3. Environment setup
- `env/.env.development`, `env/.env.staging`, `env/.env.production` — each contains `SUPABASE_URL` and `SUPABASE_ANON_KEY`
- `lib/services/dot_env_service.dart` — reads env file at startup, exposes `supabaseUrl` and `supabaseAnonKey`
- `lib/bootstrap.dart` — updated to call `DotEnvService` and initialize Supabase before `runApp`

### 4. New packages
- `supabase_flutter`
- `flutter_dotenv`
- Stub interfaces for Google/Apple sign-in (real packages added when OAuth credentials are ready)

### 5. `lib/features/auth/` module

```
lib/features/auth/
├── SPEC.md
├── domain/
│   ├── models/user_profile.dart        # Freezed: id, email, isAnonymous, isPerformer
│   └── exceptions/auth_exception.dart  # AuthException with message + technicalDetails
├── data/
│   └── repositories/auth_repository.dart
│       # signInAnonymously()
│       # signInWithGoogle()     ← stubbed, TODO comment
│       # signInWithApple()      ← stubbed, TODO comment
│       # signOut()
│       # getProfile(String userId)
│       # updateProfile(UserProfile profile)
│       # watchAuthState() → Stream<User?>
├── application/
│   └── auth_service.dart
│       # Orchestrates repository
│       # Handles anonymous → authenticated account linking on sign-in
└── presentation/
    ├── providers/
    │   └── auth_state_notifier.dart    # Watches onAuthStateChange → UserProfile
    └── screens/
        └── sign_in_screen.dart         # Full-screen, Google + Apple buttons, loading state
```

### 6. Router updates
- `SignInRoute` added with optional `redirect` query param
- Route guard: performer-only routes redirect non-performers to `/`
- `GoRouter` watches `authStateProvider` via `refreshListenable`
- After successful sign-in: navigate to `redirect` param value, or `/` if absent

## Auth states

| State | `isAnonymous` | `isPerformer` | Description |
|-------|---------------|---------------|-------------|
| Guest | `true` | `false` | Anonymous Supabase session, no sign-in |
| Audience | `false` | `false` | Signed in, not a performer |
| Performer | `false` | `true` | Signed in, opted in as performer |

## Out of scope
- Real Google/Apple OAuth credentials — wired in a follow-up item
- Performer opt-in flow (Item 3 in backlog)
- Sign-in prompt after tipping (triggered by future items)
- `display_name`, `avatar_url`, Stripe fields — added in later migrations

## Success criteria
- [ ] Anonymous session created silently on first app open
- [ ] Stub sign-in upgrades anonymous session and links prior activity via Supabase account linking
- [ ] `authStateProvider` correctly reflects guest / audience / performer states
- [ ] Route guard redirects performer-only routes for non-performers to `/`
- [ ] `SignInScreen` renders with Google and Apple buttons, handles loading and error states
- [ ] `supabase/config.toml` has anonymous sign-ins and manual linking enabled
- [ ] Migration runs cleanly via `supabase db reset`
- [ ] Unit tests: `AuthRepository`, `AuthService`
- [ ] Widget test: `SignInScreen`
- [ ] `fvm flutter analyze` and `fvm dart run custom_lint` pass with zero issues
