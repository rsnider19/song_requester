// Ignore for testing purposes
// ignore_for_file: prefer_const_constructors

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:song_requester/app/app.dart';
import 'package:song_requester/app/router/app_router.dart';
import 'package:song_requester/features/counter/counter.dart';

void main() {
  group('App', () {
    testWidgets('renders CounterPage', (tester) async {
      // Override goRouterProvider to avoid Supabase.instance initialization
      // in tests (bootstrap handles that at runtime).
      final testRouter = GoRouter(
        routes: [
          GoRoute(path: '/', builder: (_, _) => const CounterPage()),
        ],
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [goRouterProvider.overrideWithValue(testRouter)],
          child: App(),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(CounterPage), findsOneWidget);
    });
  });
}
