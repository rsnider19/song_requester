import 'dart:async';

import 'package:flutter/material.dart' show CircularProgressIndicator;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:song_requester/features/auth/domain/models/user_profile.dart';
import 'package:song_requester/features/auth/presentation/providers/auth_state_notifier.dart';
import 'package:song_requester/features/performer_onboarding/application/performer_onboarding_service.dart';
import 'package:song_requester/features/performer_onboarding/domain/exceptions/performer_onboarding_exception.dart';
import 'package:song_requester/features/performer_onboarding/presentation/providers/performer_onboarding_state_notifier.dart';
import 'package:song_requester/features/performer_onboarding/presentation/screens/performer_onboarding_screen.dart';

import '../../../../helpers/helpers.dart';

// ---------------------------------------------------------------------------
// Mocks & fakes
// ---------------------------------------------------------------------------

class _MockPerformerOnboardingService extends Mock implements PerformerOnboardingService {}

/// Minimal AuthStateNotifier that seeds a fixed profile without subscribing to
/// any streams. Used so that [authStateProvider.notifier.updateProfile()] works
/// correctly in tests where the completer is completed.
class _FakeAuthStateNotifier extends AuthStateNotifier {
  _FakeAuthStateNotifier(this._profile);
  final UserProfile? _profile;

  @override
  UserProfile? build() => _profile;
}

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

const _signedInProfile = UserProfile(
  id: 'user-id',
  isAnonymous: false,
  isPerformer: false,
  email: 'user@example.com',
);

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  late _MockPerformerOnboardingService onboardingService;

  setUp(() {
    onboardingService = _MockPerformerOnboardingService();
  });

  group('PerformerOnboardingScreen', () {
    testWidgets('shows value-prop headline and bullets', (tester) async {
      await tester.pumpApp(
        const PerformerOnboardingScreen(),
        overrides: [
          authStateProvider.overrideWithValue(_signedInProfile),
          performerOnboardingServiceProvider.overrideWithValue(onboardingService),
        ],
      );

      expect(find.text('Become a Performer'), findsWidgets);
      expect(find.text('Create and manage gigs'), findsOneWidget);
      expect(find.text('Build your song library'), findsOneWidget);
      expect(find.text('Accept tips'), findsOneWidget);
    });

    testWidgets('shows Confirm and Cancel buttons', (tester) async {
      await tester.pumpApp(
        const PerformerOnboardingScreen(),
        overrides: [
          authStateProvider.overrideWithValue(_signedInProfile),
          performerOnboardingServiceProvider.overrideWithValue(onboardingService),
        ],
      );

      expect(find.text('Confirm'), findsOneWidget);
      expect(find.text('Cancel'), findsOneWidget);
    });

    testWidgets('shows loading indicator while opt-in is in progress', (tester) async {
      // Use a completer that never completes so the loading state persists.
      final completer = Completer<UserProfile>();
      when(
        () => onboardingService.becomePerformer(any()),
      ).thenAnswer((_) => completer.future);

      await tester.pumpApp(
        const PerformerOnboardingScreen(),
        overrides: [
          // Use overrideWith so that authStateProvider.notifier.updateProfile()
          // works when the completer completes in teardown.
          authStateProvider.overrideWith(() => _FakeAuthStateNotifier(_signedInProfile)),
          performerOnboardingServiceProvider.overrideWithValue(onboardingService),
        ],
      );

      await tester.tap(find.text('Confirm'));
      await tester.pump(); // allow state to update

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('shows error toast when opt-in fails', (tester) async {
      when(
        () => onboardingService.becomePerformer(any()),
      ).thenThrow(const BecomePerformerException('Could not complete performer sign-up. Please try again.'));

      final container = ProviderContainer(
        overrides: [
          authStateProvider.overrideWithValue(_signedInProfile),
          performerOnboardingServiceProvider.overrideWithValue(onboardingService),
        ],
      );
      addTearDown(container.dispose);

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const ShadApp(home: ShadToaster(child: PerformerOnboardingScreen())),
        ),
      );

      await tester.tap(find.text('Confirm'));
      await tester.pumpAndSettle();

      // Error toast appears and notifier resets to idle.
      expect(find.text('Something went wrong'), findsOneWidget);
      expect(container.read(performerOnboardingStateProvider), isA<PerformerOnboardingIdle>());
    });

    testWidgets('Confirm button is disabled when profile is null', (tester) async {
      await tester.pumpApp(
        const PerformerOnboardingScreen(),
        overrides: [
          authStateProvider.overrideWithValue(null),
          performerOnboardingServiceProvider.overrideWithValue(onboardingService),
        ],
      );

      // The button should not call service when disabled.
      await tester.tap(find.text('Confirm'), warnIfMissed: false);
      await tester.pump();

      verifyNever(() => onboardingService.becomePerformer(any()));
    });
  });
}
