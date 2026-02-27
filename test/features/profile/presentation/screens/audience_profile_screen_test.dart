import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:song_requester/app/providers/app_mode_notifier.dart';
import 'package:song_requester/features/auth/application/auth_service.dart';
import 'package:song_requester/features/auth/domain/models/user_profile.dart';
import 'package:song_requester/features/auth/presentation/providers/auth_state_notifier.dart';
import 'package:song_requester/features/profile/presentation/screens/audience_profile_screen.dart';

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

  group('AudienceProfileScreen', () {
    testWidgets('shows guest label for anonymous user', (tester) async {
      await tester.pumpApp(
        const AudienceProfileScreen(),
        overrides: [
          authStateProvider.overrideWithValue(
            const UserProfile(id: 'id', isAnonymous: true, isPerformer: false),
          ),
          authServiceProvider.overrideWithValue(authService),
        ],
      );

      expect(find.text('Guest'), findsOneWidget);
    });

    testWidgets('shows email for signed-in user', (tester) async {
      await tester.pumpApp(
        const AudienceProfileScreen(),
        overrides: [
          authStateProvider.overrideWithValue(
            const UserProfile(
              id: 'id',
              isAnonymous: false,
              isPerformer: false,
              email: 'user@example.com',
            ),
          ),
          authServiceProvider.overrideWithValue(authService),
        ],
      );

      expect(find.text('user@example.com'), findsOneWidget);
    });

    testWidgets('does NOT show mode toggle for non-performer', (tester) async {
      await tester.pumpApp(
        const AudienceProfileScreen(),
        overrides: [
          authStateProvider.overrideWithValue(
            const UserProfile(id: 'id', isAnonymous: true, isPerformer: false),
          ),
          authServiceProvider.overrideWithValue(authService),
        ],
      );

      expect(find.byType(ShadSwitch), findsNothing);
      expect(find.text('Performer mode'), findsNothing);
    });

    testWidgets('shows mode toggle for performer', (tester) async {
      await tester.pumpApp(
        const AudienceProfileScreen(),
        overrides: [
          authStateProvider.overrideWithValue(
            const UserProfile(id: 'id', isAnonymous: false, isPerformer: true),
          ),
          appModeProvider.overrideWithValue(AppMode.audience),
          authServiceProvider.overrideWithValue(authService),
        ],
      );

      expect(find.byType(ShadSwitch), findsOneWidget);
      expect(find.text('Performer mode'), findsOneWidget);
    });

    testWidgets('mode toggle reflects audience mode (switch off)', (tester) async {
      await tester.pumpApp(
        const AudienceProfileScreen(),
        overrides: [
          authStateProvider.overrideWithValue(
            const UserProfile(id: 'id', isAnonymous: false, isPerformer: true),
          ),
          appModeProvider.overrideWithValue(AppMode.audience),
          authServiceProvider.overrideWithValue(authService),
        ],
      );

      final toggle = tester.widget<ShadSwitch>(find.byType(ShadSwitch));
      expect(toggle.value, isFalse);
    });

    testWidgets('mode toggle reflects performer mode (switch on)', (tester) async {
      await tester.pumpApp(
        const AudienceProfileScreen(),
        overrides: [
          authStateProvider.overrideWithValue(
            const UserProfile(id: 'id', isAnonymous: false, isPerformer: true),
          ),
          appModeProvider.overrideWithValue(AppMode.performer),
          authServiceProvider.overrideWithValue(authService),
        ],
      );

      final toggle = tester.widget<ShadSwitch>(find.byType(ShadSwitch));
      expect(toggle.value, isTrue);
    });

    testWidgets('tapping mode toggle off sets mode to audience', (tester) async {
      final container = ProviderContainer(
        overrides: [
          authStateProvider.overrideWithValue(
            const UserProfile(id: 'id', isAnonymous: false, isPerformer: true),
          ),
          authServiceProvider.overrideWithValue(authService),
        ],
      );
      addTearDown(container.dispose);

      // Seed the notifier into performer mode.
      container.read(appModeProvider.notifier).mode = AppMode.performer;

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const ShadApp(home: AudienceProfileScreen()),
        ),
      );
      await tester.pumpAndSettle();

      // Tap the switch to toggle off (performer → audience).
      await tester.tap(find.byType(ShadSwitch));
      await tester.pump();

      expect(container.read(appModeProvider), AppMode.audience);
    });

    testWidgets('tapping mode toggle on sets mode to performer', (tester) async {
      final container = ProviderContainer(
        overrides: [
          authStateProvider.overrideWithValue(
            const UserProfile(id: 'id', isAnonymous: false, isPerformer: true),
          ),
          authServiceProvider.overrideWithValue(authService),
        ],
      );
      addTearDown(container.dispose);

      // Notifier starts in audience mode (default for performer who hasn't switched).
      container.read(appModeProvider.notifier).mode = AppMode.audience;

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const ShadApp(home: AudienceProfileScreen()),
        ),
      );
      await tester.pumpAndSettle();

      // Tap the switch to toggle on (audience → performer).
      await tester.tap(find.byType(ShadSwitch));
      await tester.pump();

      expect(container.read(appModeProvider), AppMode.performer);
    });

    testWidgets('shows sign-out button', (tester) async {
      await tester.pumpApp(
        const AudienceProfileScreen(),
        overrides: [
          authStateProvider.overrideWithValue(null),
          authServiceProvider.overrideWithValue(authService),
        ],
      );

      expect(find.text('Sign out'), findsOneWidget);
    });
  });
}
