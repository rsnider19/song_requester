import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:song_requester/features/auth/domain/models/user_profile.dart';
import 'package:song_requester/features/auth/presentation/providers/auth_state_notifier.dart';
import 'package:song_requester/features/performer_onboarding/application/performer_onboarding_service.dart';
import 'package:song_requester/features/performer_onboarding/domain/exceptions/performer_onboarding_exception.dart';
import 'package:song_requester/features/performer_onboarding/presentation/providers/performer_onboarding_state_notifier.dart';

// ---------------------------------------------------------------------------
// Mocks & fakes
// ---------------------------------------------------------------------------

class _MockPerformerOnboardingService extends Mock implements PerformerOnboardingService {}

/// Seeds a fixed profile without subscribing to any streams.
/// Inherits [updateProfile] from [AuthStateNotifier] so notifier tests can
/// verify that the auth state is updated on successful opt-in.
class _FakeAuthStateNotifier extends AuthStateNotifier {
  _FakeAuthStateNotifier(this._profile);
  final UserProfile? _profile;

  @override
  UserProfile? build() => _profile;
}

// ---------------------------------------------------------------------------
// Fixtures
// ---------------------------------------------------------------------------

const _signedInProfile = UserProfile(
  id: 'user-id',
  isAnonymous: false,
  isPerformer: false,
  email: 'user@example.com',
);

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
  late _MockPerformerOnboardingService service;

  setUp(() {
    service = _MockPerformerOnboardingService();
  });

  ProviderContainer makeContainer() {
    final container = ProviderContainer(
      overrides: [
        // Use overrideWith so that authStateProvider.notifier.updateProfile()
        // works correctly when called from the notifier on success.
        authStateProvider.overrideWith(() => _FakeAuthStateNotifier(_signedInProfile)),
        performerOnboardingServiceProvider.overrideWithValue(service),
      ],
    );
    addTearDown(container.dispose);
    return container;
  }

  group('PerformerOnboardingStateNotifier', () {
    test('initial state is PerformerOnboardingIdle', () {
      final container = makeContainer();
      expect(container.read(performerOnboardingStateProvider), isA<PerformerOnboardingIdle>());
    });

    test('confirmOptIn emits loading then success on service success', () async {
      when(() => service.becomePerformer(any())).thenAnswer((_) async => _performerProfile);

      final container = makeContainer();
      final states = <PerformerOnboardingState>[];
      container.listen(
        performerOnboardingStateProvider,
        (_, next) => states.add(next),
      );

      await container.read(performerOnboardingStateProvider.notifier).confirmOptIn('user-id');

      expect(states, [isA<PerformerOnboardingLoading>(), isA<PerformerOnboardingSuccess>()]);
    });

    test('confirmOptIn updates auth state with returned profile on success', () async {
      when(() => service.becomePerformer(any())).thenAnswer((_) async => _performerProfile);

      final container = makeContainer();
      await container.read(performerOnboardingStateProvider.notifier).confirmOptIn('user-id');

      expect(container.read(authStateProvider)?.isPerformer, isTrue);
    });

    test('confirmOptIn emits loading then error on BecomePerformerException', () async {
      const errorMessage = 'Could not complete performer sign-up. Please try again.';
      when(
        () => service.becomePerformer(any()),
      ).thenThrow(const BecomePerformerException(errorMessage));

      final container = makeContainer();
      final states = <PerformerOnboardingState>[];
      container.listen(
        performerOnboardingStateProvider,
        (_, next) => states.add(next),
      );

      await container.read(performerOnboardingStateProvider.notifier).confirmOptIn('user-id');

      expect(states, [
        isA<PerformerOnboardingLoading>(),
        isA<PerformerOnboardingError>().having((e) => e.message, 'message', errorMessage),
      ]);
    });

    test('resetError transitions from error back to idle', () async {
      when(
        () => service.becomePerformer(any()),
      ).thenThrow(const BecomePerformerException('error'));

      final container = makeContainer();
      await container.read(performerOnboardingStateProvider.notifier).confirmOptIn('user-id');
      expect(container.read(performerOnboardingStateProvider), isA<PerformerOnboardingError>());

      container.read(performerOnboardingStateProvider.notifier).resetError();

      expect(container.read(performerOnboardingStateProvider), isA<PerformerOnboardingIdle>());
    });
  });
}
