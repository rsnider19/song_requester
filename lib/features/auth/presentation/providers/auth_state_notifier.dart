import 'dart:async';

import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:song_requester/features/auth/application/auth_service.dart';
import 'package:song_requester/features/auth/domain/models/user_profile.dart';

part 'auth_state_notifier.g.dart';

/// Exposes the current [UserProfile?].
/// - `null`  → no session (should not happen in normal use; bootstrap creates anonymous session)
/// - non-null with [UserProfile.isAnonymous] == true → guest
/// - non-null with [UserProfile.isAnonymous] == false → signed-in user
@Riverpod(keepAlive: true)
class AuthStateNotifier extends _$AuthStateNotifier {
  /// Optional profile pre-loaded at bootstrap time.
  ///
  /// When non-null, [build] uses it as the initial state so the app mode notifier
  /// sees the correct [UserProfile.isPerformer] value on the very first frame —
  /// preventing a flicker from audience → performer on cold start.
  /// Cleared after first use so sign-out/sign-in cycles see fresh state.
  AuthStateNotifier({UserProfile? seed}) : _seed = seed;

  UserProfile? _seed;

  @override
  UserProfile? build() {
    final service = ref.watch(authServiceProvider);

    // Use the bootstrap-seeded profile as the initial value (once only).
    // Cleared immediately so subsequent rebuilds (e.g. sign-out → sign-in)
    // fall back to the synthetic stub and let the stream correct the state.
    final seed = _seed;
    _seed = null;

    // Seed from current session synchronously via the service layer.
    final currentUser = service.currentUser;
    final initial =
        seed ??
        (currentUser == null
            ? null
            : UserProfile(
                id: currentUser.id,
                isAnonymous: currentUser.isAnonymous,
                isPerformer: false,
                email: currentUser.email,
              ));

    // Listen for future changes; Riverpod calls onDispose before each rebuild
    // so the previous subscription is automatically cancelled on rebuild.
    final sub = service.watchUserProfile().listen((profile) {
      state = profile;
    });
    ref.onDispose(() => unawaited(sub.cancel()));
    return initial;
  }

  /// Directly updates the in-memory profile without waiting for an auth event.
  ///
  /// Use this after a profile mutation (e.g. performer opt-in) to synchronously
  /// reflect the change so router guards see the new state immediately.
  // ignore: use_setters_to_change_properties
  void updateProfile(UserProfile profile) => state = profile;
}
