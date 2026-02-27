import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:song_requester/features/auth/application/auth_service.dart';
import 'package:song_requester/features/auth/domain/exceptions/auth_exception.dart';
import 'package:song_requester/features/auth/domain/models/user_profile.dart';
import 'package:song_requester/features/performer_onboarding/domain/exceptions/performer_onboarding_exception.dart';
import 'package:song_requester/services/logging_service.dart';

part 'performer_onboarding_service.g.dart';

class PerformerOnboardingService {
  PerformerOnboardingService(this._authService, this._logger);

  final AuthService _authService;
  final LoggingService _logger;

  /// Opts the current user in as a performer.
  ///
  /// Returns the updated [UserProfile] with [UserProfile.isPerformer] == true.
  /// Throws [BecomePerformerException] on failure.
  Future<UserProfile> becomePerformer(String userId) async {
    try {
      return await _authService.becomePerformer(userId);
    } on ProfileException catch (e, st) {
      _logger.e('Failed to opt in as performer', error: e, stackTrace: st);
      throw BecomePerformerException(
        'Could not complete performer sign-up. Please try again.',
        e.technicalDetails,
      );
    } catch (e, st) {
      _logger.e('Unexpected error during performer opt-in', error: e, stackTrace: st);
      throw BecomePerformerException(
        'An unexpected error occurred. Please try again.',
        e.toString(),
      );
    }
  }
}

@Riverpod(keepAlive: true)
PerformerOnboardingService performerOnboardingService(Ref ref) => PerformerOnboardingService(
  ref.watch(authServiceProvider),
  ref.watch(loggingServiceProvider),
);
