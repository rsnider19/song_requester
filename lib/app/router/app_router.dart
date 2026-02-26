import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:song_requester/app/router/go_router_refresh_stream.dart';
import 'package:song_requester/features/auth/presentation/providers/auth_state_notifier.dart';
import 'package:song_requester/features/auth/presentation/screens/sign_in_screen.dart';
import 'package:song_requester/features/counter/counter.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

part 'app_router.g.dart';

// ---------------------------------------------------------------------------
// Routes
// ---------------------------------------------------------------------------

@TypedGoRoute<CounterRoute>(path: '/')
class CounterRoute extends GoRouteData with $CounterRoute {
  const CounterRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) => const CounterPage();
}

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

  return GoRouter(
    routes: $appRoutes,
    initialLocation: '/',
    refreshListenable: refreshListenable,
    redirect: (context, state) {
      final profile = ref.read(authStateProvider);
      final isPerformer = profile?.isPerformer ?? false;

      // Performer-only guard: /performer/** routes redirect non-performers to home.
      final isPerformerRoute = state.matchedLocation.startsWith('/performer');
      if (isPerformerRoute && !isPerformer) return '/';

      return null;
    },
  );
}
