import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:song_requester/app/providers/supabase_provider.dart';
import 'package:song_requester/features/auth/domain/exceptions/auth_exception.dart';
import 'package:song_requester/features/auth/domain/models/user_profile.dart';
import 'package:song_requester/services/logging_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

part 'auth_repository.g.dart';

class AuthRepository {
  AuthRepository(this._supabase, this._logger);

  final SupabaseClient _supabase;
  final LoggingService _logger;

  /// Returns the currently authenticated [User], or null if no session exists.
  User? get currentUser => _supabase.auth.currentUser;

  /// Returns a stream of [User?] that emits whenever auth state changes.
  Stream<User?> watchAuthState() => _supabase.auth.onAuthStateChange.map((event) => event.session?.user);

  /// Signs in anonymously. No-op if a session already exists.
  Future<void> signInAnonymously() async {
    try {
      await _supabase.auth.signInAnonymously();
    } catch (e, st) {
      _logger.e('Failed to sign in anonymously', error: e, stackTrace: st);
      throw SignInException('Could not create guest session', e.toString());
    }
  }

  /// Signs in with Google OAuth.
  ///
  // TODO(oauth): Replace stub with real OAuth once credentials are configured.
  Future<void> signInWithGoogle() async {
    throw const SignInException('Google Sign-In is not yet implemented');
  }

  /// Signs in with Apple OAuth.
  ///
  // TODO(oauth): Replace stub with real OAuth once credentials are configured.
  Future<void> signInWithApple() async {
    throw const SignInException('Apple Sign-In is not yet implemented');
  }

  /// Signs the current user out.
  Future<void> signOut() async {
    try {
      await _supabase.auth.signOut();
    } catch (e, st) {
      _logger.e('Failed to sign out', error: e, stackTrace: st);
      throw SignInException('Could not sign out', e.toString());
    }
  }

  /// Fetches the [UserProfile] for [userId] from the profile table.
  ///
  /// [isAnonymous] must be supplied by the caller from the live [User] object
  /// to avoid a race where [currentUser] might be null mid-request.
  Future<UserProfile> getProfile(String userId, {required bool isAnonymous}) async {
    try {
      final row = await _supabase
          .from('profile')
          .select('profile_id, email, is_performer')
          .eq('profile_id', userId)
          .single();
      return UserProfile(
        id: row['profile_id'] as String,
        email: row['email'] as String?,
        isAnonymous: isAnonymous,
        isPerformer: row['is_performer'] as bool,
      );
    } catch (e, st) {
      _logger.e('Failed to fetch profile', error: e, stackTrace: st);
      throw ProfileException('Could not load profile', e.toString());
    }
  }

  /// Updates [isPerformer] flag for the given [userId].
  Future<void> updateIsPerformer({
    required String userId,
    required bool isPerformer,
  }) async {
    try {
      await _supabase.from('profile').update({'is_performer': isPerformer}).eq('profile_id', userId);
    } catch (e, st) {
      _logger.e('Failed to update profile', error: e, stackTrace: st);
      throw ProfileException('Could not update profile', e.toString());
    }
  }
}

@Riverpod(keepAlive: true)
AuthRepository authRepository(Ref ref) => AuthRepository(
  ref.watch(supabaseProvider),
  ref.watch(loggingServiceProvider),
);
