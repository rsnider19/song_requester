import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:song_requester/features/auth/presentation/providers/auth_state_notifier.dart';

part 'app_mode_notifier.g.dart';

/// The two modes a user can be in.
enum AppMode { audience, performer }

/// Tracks the active app mode (Audience or Performer).
///
/// Defaults to [AppMode.performer] on cold start if the user has already
/// opted in as a performer; otherwise defaults to [AppMode.audience].
/// State is in-memory — resets correctly on each cold start from auth state.
@Riverpod(keepAlive: true)
class AppModeNotifier extends _$AppModeNotifier {
  @override
  AppMode build() {
    // Watch so the notifier rebuilds when auth state changes (e.g. sign-out then
    // sign-in within the same session), re-seeding the correct default mode.
    final profile = ref.watch(authStateProvider);
    return (profile?.isPerformer ?? false) ? AppMode.performer : AppMode.audience;
  }

  // The mode getter/setter provide a semantic API (mode vs state) and satisfy
  // the lint requirement to pair a setter with a getter on the same class.
  AppMode get mode => state;
  set mode(AppMode value) => state = value;
}
