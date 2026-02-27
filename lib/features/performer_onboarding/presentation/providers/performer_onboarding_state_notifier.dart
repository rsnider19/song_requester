import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:song_requester/features/auth/presentation/providers/auth_state_notifier.dart';
import 'package:song_requester/features/performer_onboarding/application/performer_onboarding_service.dart';
import 'package:song_requester/features/performer_onboarding/domain/exceptions/performer_onboarding_exception.dart';

part 'performer_onboarding_state_notifier.g.dart';

/// Holds the state for the performer opt-in flow.
///
/// [PerformerOnboardingIdle] — waiting for user interaction
/// [PerformerOnboardingLoading] — network request in flight
/// [PerformerOnboardingError] — last attempt failed; message is user-facing
/// [PerformerOnboardingSuccess] — opt-in complete; caller should navigate away
sealed class PerformerOnboardingState {
  const PerformerOnboardingState();
}

class PerformerOnboardingIdle extends PerformerOnboardingState {
  const PerformerOnboardingIdle();
}

class PerformerOnboardingLoading extends PerformerOnboardingState {
  const PerformerOnboardingLoading();
}

class PerformerOnboardingError extends PerformerOnboardingState {
  const PerformerOnboardingError(this.message);
  final String message;
}

class PerformerOnboardingSuccess extends PerformerOnboardingState {
  const PerformerOnboardingSuccess();
}

@riverpod
class PerformerOnboardingStateNotifier extends _$PerformerOnboardingStateNotifier {
  @override
  PerformerOnboardingState build() => const PerformerOnboardingIdle();

  /// Opts the current user in as a performer.
  ///
  /// On success, updates the in-memory auth state so router guards reflect the
  /// change immediately, then transitions to [PerformerOnboardingSuccess].
  /// On failure, transitions to [PerformerOnboardingError] with a user-facing message.
  Future<void> confirmOptIn(String userId) async {
    state = const PerformerOnboardingLoading();
    try {
      final updatedProfile = await ref.read(performerOnboardingServiceProvider).becomePerformer(userId);
      // Update auth state synchronously so AppModeNotifier rebuilds before navigation.
      ref.read(authStateProvider.notifier).profile = updatedProfile;
      state = const PerformerOnboardingSuccess();
    } on BecomePerformerException catch (e) {
      state = PerformerOnboardingError(e.message);
    }
  }

  void resetError() => state = const PerformerOnboardingIdle();
}
