import 'dart:convert';
import 'dart:math';

import 'package:crypto/crypto.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'package:song_requester/app/providers/supabase_provider.dart';
import 'package:song_requester/features/auth/domain/exceptions/auth_exception.dart';
import 'package:song_requester/features/auth/domain/models/user_profile.dart';
import 'package:song_requester/services/logging_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

part 'auth_repository.g.dart';

class AuthRepository {
  AuthRepository(
    this._supabase,
    this._logger, {
    required String googleWebClientId,
    String? googleIosClientId,
  }) : _googleWebClientId = googleWebClientId,
       _googleIosClientId = googleIosClientId;

  final SupabaseClient _supabase;
  final LoggingService _logger;
  final String _googleWebClientId;
  final String? _googleIosClientId;

  /// Returns the currently authenticated [User], or null if no session exists.
  User? get currentUser => _supabase.auth.currentUser;

  /// Returns a stream of [User?] that emits whenever auth state changes.
  Stream<User?> watchAuthState() => _supabase.auth.onAuthStateChange.map((event) => event.session?.user);

  /// Signs in with Google using the native SDK flow.
  ///
  /// Calls `GoogleSignIn.signIn` to retrieve an ID token, then exchanges it
  /// with Supabase. If the current user is anonymous, uses
  /// `linkIdentityWithIdToken` to promote the anonymous session to a permanent
  /// account (preserving the user ID and profile). Otherwise performs a
  /// regular sign-in. Returns silently if the user cancels the sign-in sheet.
  Future<void> signInWithGoogle() async {
    try {
      final googleSignIn = GoogleSignIn(
        clientId: _googleIosClientId,
        serverClientId: _googleWebClientId,
      );

      final googleUser = await googleSignIn.signIn();
      if (googleUser == null) return; // User dismissed the sign-in sheet.

      final googleAuth = await googleUser.authentication;
      final accessToken = googleAuth.accessToken;
      final idToken = googleAuth.idToken;

      if (accessToken == null) throw const SignInException('Google Sign-In failed: no access token received');
      if (idToken == null) throw const SignInException('Google Sign-In failed: no ID token received');

      if (_supabase.auth.currentUser?.isAnonymous == true) {
        await _supabase.auth.linkIdentityWithIdToken(
          provider: OAuthProvider.google,
          idToken: idToken,
          accessToken: accessToken,
        );
      } else {
        await _supabase.auth.signInWithIdToken(
          provider: OAuthProvider.google,
          idToken: idToken,
          accessToken: accessToken,
        );
      }
    } on SignInException {
      rethrow;
    } catch (e, st) {
      _logger.e('Failed to sign in with Google', error: e, stackTrace: st);
      throw SignInException('Google Sign-In failed', e.toString());
    }
  }

  /// Signs in with Apple using the native SDK flow (iOS/macOS only).
  ///
  /// Generates a PKCE nonce, calls [SignInWithApple.getAppleIDCredential],
  /// then exchanges the identity token with Supabase. If the current user is
  /// anonymous, uses `linkIdentityWithIdToken` to promote the anonymous
  /// session to a permanent account. Returns silently if the user cancels.
  Future<void> signInWithApple() async {
    try {
      final rawNonce = _generateNonce();
      final hashedNonce = _sha256(rawNonce);

      final credential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
        nonce: hashedNonce,
      );

      final idToken = credential.identityToken;
      if (idToken == null) throw const SignInException('Apple Sign-In failed: no identity token received');

      if (_supabase.auth.currentUser?.isAnonymous == true) {
        await _supabase.auth.linkIdentityWithIdToken(
          provider: OAuthProvider.apple,
          idToken: idToken,
          nonce: rawNonce,
        );
      } else {
        await _supabase.auth.signInWithIdToken(
          provider: OAuthProvider.apple,
          idToken: idToken,
          nonce: rawNonce,
        );
      }
    } on SignInWithAppleAuthorizationException catch (e, st) {
      if (e.code == AuthorizationErrorCode.canceled) return; // User dismissed the sign-in sheet.
      _logger.e('Apple Sign-In authorization error', error: e, stackTrace: st);
      throw SignInException('Apple Sign-In failed', e.toString());
    } on SignInException {
      rethrow;
    } catch (e, st) {
      _logger.e('Failed to sign in with Apple', error: e, stackTrace: st);
      throw SignInException('Apple Sign-In failed', e.toString());
    }
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
  // ---------------------------------------------------------------------------
  // Helpers
  // ---------------------------------------------------------------------------

  /// Generates a cryptographically random nonce string.
  static String _generateNonce([int length = 32]) {
    const charset = '0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._';
    final random = Random.secure();
    return List.generate(length, (_) => charset[random.nextInt(charset.length)]).join();
  }

  /// Returns the SHA-256 hex digest of [input].
  static String _sha256(String input) {
    final bytes = utf8.encode(input);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }
}

@Riverpod(keepAlive: true)
AuthRepository authRepository(Ref ref) => AuthRepository(
  ref.watch(supabaseProvider),
  ref.watch(loggingServiceProvider),
  googleWebClientId: dotenv.env['GOOGLE_WEB_CLIENT_ID'] ?? '',
  googleIosClientId: dotenv.env['GOOGLE_IOS_CLIENT_ID'],
);
