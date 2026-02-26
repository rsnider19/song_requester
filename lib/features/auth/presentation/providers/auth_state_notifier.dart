import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:song_requester/features/auth/application/auth_service.dart';
import 'package:song_requester/features/auth/domain/models/user_profile.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

part 'auth_state_notifier.g.dart';

/// Exposes the current [UserProfile?].
/// - `null`  → no session (should not happen in normal use; bootstrap creates anonymous session)
/// - non-null with [UserProfile.isAnonymous] == true → guest
/// - non-null with [UserProfile.isAnonymous] == false → signed-in user
@Riverpod(keepAlive: true)
class AuthStateNotifier extends _$AuthStateNotifier {
  @override
  UserProfile? build() {
    final service = ref.watch(authServiceProvider);

    // Seed from current session synchronously.
    final currentUser = Supabase.instance.client.auth.currentUser;
    final initial = currentUser == null
        ? null
        : UserProfile(
            id: currentUser.id,
            isAnonymous: currentUser.isAnonymous,
            isPerformer: false,
            email: currentUser.email,
          );

    // Listen for future changes; Riverpod calls onDispose before each rebuild
    // so the previous subscription is automatically cancelled on rebuild.
    final sub = service.watchUserProfile().listen((profile) {
      state = profile;
    });
    ref.onDispose(() => unawaited(sub.cancel()));
    return initial;
  }
}

/// A [ChangeNotifier] that notifies GoRouter when the auth state changes.
/// Wrap Supabase's own stream so we don't depend on Riverpod in the router layer.
class GoRouterRefreshStream extends ChangeNotifier {
  GoRouterRefreshStream(Stream<dynamic> stream) {
    notifyListeners();
    _sub = stream.listen((_) => notifyListeners());
  }

  late final StreamSubscription<dynamic> _sub;

  @override
  void dispose() {
    unawaited(_sub.cancel());
    super.dispose();
  }
}
