import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:song_requester/features/counter/counter.dart';

part 'app_router.g.dart';

@TypedGoRoute<CounterRoute>(path: '/')
class CounterRoute extends GoRouteData with $CounterRoute {
  const CounterRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) => const CounterPage();
}

@Riverpod(keepAlive: true)
GoRouter goRouter(Ref ref) {
  return GoRouter(
    routes: $appRoutes,
    initialLocation: '/',
  );
}
