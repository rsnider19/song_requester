import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:song_requester/app/providers/app_mode_notifier.dart';
import 'package:song_requester/app/router/go_router_refresh_stream.dart';
import 'package:song_requester/features/auth/presentation/providers/auth_state_notifier.dart';
import 'package:song_requester/features/auth/presentation/screens/sign_in_screen.dart';
import 'package:song_requester/features/gigs/presentation/screens/gigs_screen.dart';
import 'package:song_requester/features/home/presentation/screens/audience_home_screen.dart';
import 'package:song_requester/features/profile/presentation/screens/audience_profile_screen.dart';
import 'package:song_requester/features/profile/presentation/screens/performer_profile_screen.dart';
import 'package:song_requester/features/search/presentation/screens/search_screen.dart';
import 'package:song_requester/features/songs/presentation/screens/songs_screen.dart';
import 'package:song_requester/widgets/app_shell_screen.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

part 'app_router.g.dart';

// ---------------------------------------------------------------------------
// Audience shell
// ---------------------------------------------------------------------------

@TypedStatefulShellRoute<AudienceShellRouteData>(
  branches: <TypedStatefulShellBranch<StatefulShellBranchData>>[
    TypedStatefulShellBranch<HomeBranchData>(
      routes: <TypedRoute<RouteData>>[
        TypedGoRoute<HomeRoute>(path: '/home'),
      ],
    ),
    TypedStatefulShellBranch<SearchBranchData>(
      routes: <TypedRoute<RouteData>>[
        TypedGoRoute<SearchRoute>(path: '/search'),
      ],
    ),
    TypedStatefulShellBranch<AudienceProfileBranchData>(
      routes: <TypedRoute<RouteData>>[
        TypedGoRoute<AudienceProfileRoute>(path: '/profile'),
      ],
    ),
  ],
)
class AudienceShellRouteData extends StatefulShellRouteData {
  const AudienceShellRouteData();

  static const _$tabs = [
    AppShellTab(icon: LucideIcons.house, label: 'Home'),
    AppShellTab(icon: LucideIcons.search, label: 'Search'),
    AppShellTab(icon: LucideIcons.user, label: 'Profile'),
  ];

  @override
  Widget builder(
    BuildContext context,
    GoRouterState state,
    StatefulNavigationShell navigationShell,
  ) => AppShellScreen(navigationShell: navigationShell, tabs: _$tabs);
}

class HomeBranchData extends StatefulShellBranchData {
  const HomeBranchData();
}

class HomeRoute extends GoRouteData with $HomeRoute {
  const HomeRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) => const AudienceHomeScreen();
}

class SearchBranchData extends StatefulShellBranchData {
  const SearchBranchData();
}

class SearchRoute extends GoRouteData with $SearchRoute {
  const SearchRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) => const SearchScreen();
}

class AudienceProfileBranchData extends StatefulShellBranchData {
  const AudienceProfileBranchData();
}

class AudienceProfileRoute extends GoRouteData with $AudienceProfileRoute {
  const AudienceProfileRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) => const AudienceProfileScreen();
}

// ---------------------------------------------------------------------------
// Performer shell
// ---------------------------------------------------------------------------

@TypedStatefulShellRoute<PerformerShellRouteData>(
  branches: <TypedStatefulShellBranch<StatefulShellBranchData>>[
    TypedStatefulShellBranch<GigsBranchData>(
      routes: <TypedRoute<RouteData>>[
        TypedGoRoute<GigsRoute>(path: '/performer/gigs'),
      ],
    ),
    TypedStatefulShellBranch<SongsBranchData>(
      routes: <TypedRoute<RouteData>>[
        TypedGoRoute<SongsRoute>(path: '/performer/songs'),
      ],
    ),
    TypedStatefulShellBranch<PerformerProfileBranchData>(
      routes: <TypedRoute<RouteData>>[
        TypedGoRoute<PerformerProfileRoute>(path: '/performer/profile'),
      ],
    ),
  ],
)
class PerformerShellRouteData extends StatefulShellRouteData {
  const PerformerShellRouteData();

  static const _$tabs = [
    AppShellTab(icon: LucideIcons.calendar, label: 'Gigs'),
    AppShellTab(icon: LucideIcons.music, label: 'Songs'),
    AppShellTab(icon: LucideIcons.user, label: 'Profile'),
  ];

  @override
  Widget builder(
    BuildContext context,
    GoRouterState state,
    StatefulNavigationShell navigationShell,
  ) => AppShellScreen(navigationShell: navigationShell, tabs: _$tabs);
}

class GigsBranchData extends StatefulShellBranchData {
  const GigsBranchData();
}

class GigsRoute extends GoRouteData with $GigsRoute {
  const GigsRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) => const GigsScreen();
}

class SongsBranchData extends StatefulShellBranchData {
  const SongsBranchData();
}

class SongsRoute extends GoRouteData with $SongsRoute {
  const SongsRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) => const SongsScreen();
}

class PerformerProfileBranchData extends StatefulShellBranchData {
  const PerformerProfileBranchData();
}

class PerformerProfileRoute extends GoRouteData with $PerformerProfileRoute {
  const PerformerProfileRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) => const PerformerProfileScreen();
}

// ---------------------------------------------------------------------------
// Sign in (standalone — no shell)
// ---------------------------------------------------------------------------

@TypedGoRoute<SignInRoute>(path: '/sign-in')
class SignInRoute extends GoRouteData with $SignInRoute {
  const SignInRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) => const SignInScreen();
}

// ---------------------------------------------------------------------------
// Router provider
// ---------------------------------------------------------------------------

@Riverpod(keepAlive: true)
GoRouter goRouter(Ref ref) {
  final authStream = Supabase.instance.client.auth.onAuthStateChange;
  final refreshListenable = GoRouterRefreshStream(authStream);
  ref.onDispose(refreshListenable.dispose);

  final router = GoRouter(
    routes: $appRoutes,
    initialLocation: '/home',
    refreshListenable: refreshListenable,
    redirect: (context, state) {
      // Use ref.read — redirect is invoked reactively via refreshListenable/listen;
      // watching here would cause rebuild loops.
      final profile = ref.read(authStateProvider);
      final mode = ref.read(appModeProvider);
      final isPerformer = profile?.isPerformer ?? false;
      final loc = state.matchedLocation;
      final isPerformerRoute = loc.startsWith('/performer');

      // Guard: unauthenticated users must sign in first.
      if (profile == null && loc != '/sign-in') return '/sign-in';

      // Guard: non-performers cannot access performer routes.
      if (isPerformerRoute && !isPerformer) return '/home';

      // Mode sync: performer mode → redirect to performer shell.
      if (mode == AppMode.performer && isPerformer && !isPerformerRoute && loc != '/sign-in') {
        return '/performer/gigs';
      }

      // Mode sync: audience mode → redirect away from performer shell.
      if (mode == AppMode.audience && isPerformerRoute) return '/home';

      return null;
    },
  );

  // Refresh the router whenever mode changes so redirect runs immediately.
  ref.listen(appModeProvider, (_, _) => router.refresh());

  return router;
}
