import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:song_requester/app/providers/app_mode_notifier.dart';
import 'package:song_requester/features/auth/domain/models/user_profile.dart';
import 'package:song_requester/features/auth/presentation/providers/auth_state_notifier.dart';
import 'package:song_requester/features/performer_onboarding/presentation/screens/performer_stripe_prompt_screen.dart';
import 'package:song_requester/l10n/l10n.dart';

import '../../../../helpers/helpers.dart';

// ---------------------------------------------------------------------------
// Mocks & fakes
// ---------------------------------------------------------------------------

/// Seeds a fixed profile without subscribing to any streams.
class _FakeAuthStateNotifier extends AuthStateNotifier {
  _FakeAuthStateNotifier(this._profile);
  final UserProfile? _profile;

  @override
  UserProfile? build() => _profile;
}

// ---------------------------------------------------------------------------
// Fixtures
// ---------------------------------------------------------------------------

/// This screen is shown after successful performer opt-in, so the profile
/// should reflect [isPerformer: true].
const _performerProfile = UserProfile(
  id: 'user-id',
  isAnonymous: false,
  isPerformer: true,
  email: 'user@example.com',
);

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  group('PerformerStripePromptScreen', () {
    testWidgets('renders headline, Stripe card, and action buttons', (tester) async {
      await tester.pumpApp(
        const PerformerStripePromptScreen(),
        overrides: [
          authStateProvider.overrideWith(() => _FakeAuthStateNotifier(_performerProfile)),
        ],
      );

      expect(find.text("You're a performer!"), findsOneWidget);
      expect(find.text('Why connect Stripe?'), findsOneWidget);
      expect(find.text('Set up Stripe'), findsOneWidget);
      expect(find.text('Skip for now'), findsOneWidget);
    });

    testWidgets('Skip for now sets app mode to performer', (tester) async {
      final container = ProviderContainer(
        overrides: [
          authStateProvider.overrideWith(() => _FakeAuthStateNotifier(_performerProfile)),
        ],
      );
      addTearDown(container.dispose);

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const ShadApp(
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: PerformerStripePromptScreen(),
          ),
        ),
      );

      expect(container.read(appModeProvider), AppMode.performer);

      await tester.tap(find.text('Skip for now'));
      await tester.pump();

      expect(container.read(appModeProvider), AppMode.performer);
    });

    testWidgets('Set up Stripe shows coming-soon toast and sets performer mode', (tester) async {
      final container = ProviderContainer(
        overrides: [
          authStateProvider.overrideWith(() => _FakeAuthStateNotifier(_performerProfile)),
        ],
      );
      addTearDown(container.dispose);

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const ShadApp(
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: ShadToaster(child: PerformerStripePromptScreen()),
          ),
        ),
      );

      await tester.tap(find.text('Set up Stripe'));
      await tester.pumpAndSettle();

      expect(find.text('Coming soon'), findsOneWidget);
      expect(container.read(appModeProvider), AppMode.performer);
    });
  });
}
