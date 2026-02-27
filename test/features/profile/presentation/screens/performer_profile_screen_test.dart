import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:song_requester/app/providers/app_mode_notifier.dart';
import 'package:song_requester/features/auth/application/auth_service.dart';
import 'package:song_requester/features/profile/presentation/screens/performer_profile_screen.dart';

import '../../../../helpers/helpers.dart';

// ---------------------------------------------------------------------------
// Mocks
// ---------------------------------------------------------------------------

class _MockAuthService extends Mock implements AuthService {}

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  late _MockAuthService authService;

  setUp(() {
    authService = _MockAuthService();
  });

  group('PerformerProfileScreen', () {
    testWidgets('renders placeholder content', (tester) async {
      await tester.pumpApp(
        const PerformerProfileScreen(),
        overrides: [authServiceProvider.overrideWithValue(authService)],
      );

      expect(find.text('Performer Profile'), findsOneWidget);
      expect(find.textContaining('coming soon'), findsOneWidget);
    });

    testWidgets('shows mode toggle set to on', (tester) async {
      await tester.pumpApp(
        const PerformerProfileScreen(),
        overrides: [authServiceProvider.overrideWithValue(authService)],
      );

      expect(find.byType(ShadSwitch), findsOneWidget);
      expect(find.text('Performer mode'), findsOneWidget);

      final toggle = tester.widget<ShadSwitch>(find.byType(ShadSwitch));
      expect(toggle.value, isTrue);
    });

    testWidgets('tapping mode toggle sets mode to audience', (tester) async {
      final container = ProviderContainer(
        overrides: [authServiceProvider.overrideWithValue(authService)],
      );
      addTearDown(container.dispose);

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const ShadApp(home: PerformerProfileScreen()),
        ),
      );
      await tester.pumpAndSettle();

      // Tap the switch to toggle off (performer → audience).
      await tester.tap(find.byType(ShadSwitch));
      await tester.pump();

      expect(container.read(appModeProvider), AppMode.audience);
    });

    testWidgets('shows sign-out button', (tester) async {
      await tester.pumpApp(
        const PerformerProfileScreen(),
        overrides: [authServiceProvider.overrideWithValue(authService)],
      );

      expect(find.text('Sign out'), findsOneWidget);
    });
  });
}
