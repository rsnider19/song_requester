import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:song_requester/features/auth/data/repositories/auth_repository.dart';
import 'package:song_requester/features/auth/domain/exceptions/auth_exception.dart';
import 'package:song_requester/features/auth/domain/models/user_profile.dart';
import 'package:song_requester/services/logging_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

part 'auth_service.g.dart';

class AuthService {
  AuthService(this._repository, this._logger);

  final AuthRepository _repository;
  final LoggingService _logger;

  /// Returns the currently authenticated [User], or null if no session exists.
  User? get currentUser => _repository.currentUser;

  /// Returns a stream of [UserProfile?] derived from the raw auth state stream.
  /// Null means the user is fully unauthenticated (no session at all).
  Stream<UserProfile?> watchUserProfile() => _repository.watchAuthState().asyncMap(_toProfile);

  /// Signs in with Google. Stubs throw; callers should handle [SignInException].
  Future<void> signInWithGoogle() => _repository.signInWithGoogle();

  /// Signs in with Apple. Stubs throw; callers should handle [SignInException].
  Future<void> signInWithApple() => _repository.signInWithApple();

  /// Signs out. Anonymous session data is lost; the next open creates a new one.
  Future<void> signOut() => _repository.signOut();

  /// Opts the given user into performer mode.
  ///
  /// Updates [UserProfile.isPerformer] to `true` in the database and returns the refreshed
  /// [UserProfile]. Callers should handle [ProfileException].
  Future<UserProfile> becomePerformer(String userId) async {
    await _repository.updateIsPerformer(userId: userId, isPerformer: true);
    return _repository.getProfile(userId, isAnonymous: false);
  }

  // ---------------------------------------------------------------------------

  Future<UserProfile?> _toProfile(User? user) async {
    if (user == null) return null;
    try {
      return await _repository.getProfile(user.id, isAnonymous: user.isAnonymous);
    } on Exception catch (e, st) {
      // Profile may not exist yet (trigger runs async); return a minimal guest.
      _logger.w('Profile not ready yet, returning minimal guest', error: e, stackTrace: st);
      return UserProfile(
        id: user.id,
        isAnonymous: user.isAnonymous,
        isPerformer: false,
        email: user.email,
      );
    }
  }
}

@Riverpod(keepAlive: true)
AuthService authService(Ref ref) => AuthService(
  ref.watch(authRepositoryProvider),
  ref.watch(loggingServiceProvider),
);
