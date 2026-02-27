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
    final profile = ref.read(authStateProvider);
    return (profile?.isPerformer ?? false) ? AppMode.performer : AppMode.audience;
  }

  AppMode get mode => state;
  set mode(AppMode value) => state = value;
}
