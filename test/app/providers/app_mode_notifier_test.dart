import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:song_requester/app/providers/app_mode_notifier.dart';
import 'package:song_requester/features/auth/domain/models/user_profile.dart';
import 'package:song_requester/features/auth/presentation/providers/auth_state_notifier.dart';

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

ProviderContainer _makeContainer({UserProfile? profile}) => ProviderContainer(
  overrides: [authStateProvider.overrideWithValue(profile)],
);

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  group('AppModeNotifier', () {
    group('initial state', () {
      test('defaults to audience when user is not a performer', () {
        final container = _makeContainer(
          profile: const UserProfile(id: 'id', isAnonymous: true, isPerformer: false),
        );
        addTearDown(container.dispose);

        expect(container.read(appModeProvider), AppMode.audience);
      });

      test('defaults to performer when user is a performer', () {
        final container = _makeContainer(
          profile: const UserProfile(id: 'id', isAnonymous: false, isPerformer: true),
        );
        addTearDown(container.dispose);

        expect(container.read(appModeProvider), AppMode.performer);
      });

      test('defaults to audience when profile is null', () {
        final container = _makeContainer();
        addTearDown(container.dispose);

        expect(container.read(appModeProvider), AppMode.audience);
      });
    });

    group('mode setter', () {
      test('switching to performer updates state', () {
        final container = _makeContainer();
        addTearDown(container.dispose);

        container.read(appModeProvider.notifier).mode = AppMode.performer;

        expect(container.read(appModeProvider), AppMode.performer);
      });

      test('switching to audience updates state', () {
        final container = _makeContainer(
          profile: const UserProfile(id: 'id', isAnonymous: false, isPerformer: true),
        );
        addTearDown(container.dispose);

        container.read(appModeProvider.notifier).mode = AppMode.audience;

        expect(container.read(appModeProvider), AppMode.audience);
      });
    });

    test('mode getter reflects current state', () {
      final container = _makeContainer();
      addTearDown(container.dispose);

      final notifier = container.read(appModeProvider.notifier);
      expect(notifier.mode, AppMode.audience);

      notifier.mode = AppMode.performer;
      expect(notifier.mode, AppMode.performer);
    });
  });
}
