import 'package:flutter_test/flutter_test.dart';
import 'package:logger/logger.dart';
import 'package:mocktail/mocktail.dart';
import 'package:song_requester/features/auth/data/repositories/auth_repository.dart';
import 'package:song_requester/features/auth/domain/exceptions/auth_exception.dart';
import 'package:song_requester/features/auth/domain/models/user_profile.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// ---------------------------------------------------------------------------
// Mocks
// ---------------------------------------------------------------------------

class _MockSupabaseClient extends Mock implements SupabaseClient {}

class _MockGoTrueClient extends Mock implements GoTrueClient {}

class _MockLogger extends Mock implements Logger {}

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  late _MockSupabaseClient supabase;
  late _MockGoTrueClient auth;
  late _MockLogger logger;
  late AuthRepository repository;

  setUp(() {
    supabase = _MockSupabaseClient();
    auth = _MockGoTrueClient();
    logger = _MockLogger();
    repository = AuthRepository(supabase, logger);
    when(() => supabase.auth).thenReturn(auth);
  });

  group('AuthRepository', () {
    group('signInAnonymously', () {
      test('calls supabase.auth.signInAnonymously', () async {
        when(() => auth.signInAnonymously()).thenAnswer((_) async => AuthResponse());

        await expectLater(repository.signInAnonymously(), completes);
        verify(() => auth.signInAnonymously()).called(1);
      });

      test('throws SignInException on failure', () async {
        when(() => auth.signInAnonymously()).thenThrow(Exception('network error'));
        when(
          () => logger.e(
            any<dynamic>(),
            error: any<Object?>(named: 'error'),
            stackTrace: any<StackTrace?>(named: 'stackTrace'),
          ),
        ).thenReturn(null);

        await expectLater(
          repository.signInAnonymously(),
          throwsA(isA<SignInException>()),
        );
      });
    });

    group('signInWithGoogle', () {
      test('throws SignInException (stub)', () async {
        await expectLater(
          repository.signInWithGoogle(),
          throwsA(isA<SignInException>()),
        );
      });
    });

    group('signInWithApple', () {
      test('throws SignInException (stub)', () async {
        await expectLater(
          repository.signInWithApple(),
          throwsA(isA<SignInException>()),
        );
      });
    });

    group('signOut', () {
      test('calls supabase.auth.signOut', () async {
        when(() => auth.signOut()).thenAnswer((_) async {});

        await expectLater(repository.signOut(), completes);
        verify(() => auth.signOut()).called(1);
      });

      test('throws SignInException on failure', () async {
        when(() => auth.signOut()).thenThrow(Exception('error'));
        when(
          () => logger.e(
            any<dynamic>(),
            error: any<Object?>(named: 'error'),
            stackTrace: any<StackTrace?>(named: 'stackTrace'),
          ),
        ).thenReturn(null);

        await expectLater(repository.signOut(), throwsA(isA<SignInException>()));
      });
    });

    group('getProfile', () {
      test('throws ProfileException when supabase.from() throws', () async {
        when(() => supabase.from(any<String>())).thenThrow(Exception('db error'));
        when(
          () => logger.e(
            any<dynamic>(),
            error: any<Object?>(named: 'error'),
            stackTrace: any<StackTrace?>(named: 'stackTrace'),
          ),
        ).thenReturn(null);

        await expectLater(
          repository.getProfile('user-id'),
          throwsA(isA<ProfileException>()),
        );
      });
    });

    group('UserProfile domain model', () {
      test('fromJson/toJson round-trips correctly', () {
        const profile = UserProfile(
          id: 'abc',
          isAnonymous: false,
          isPerformer: true,
          email: 'test@example.com',
        );
        final json = profile.toJson();
        final restored = UserProfile.fromJson(json);
        expect(restored, equals(profile));
      });

      test('guest profile defaults: isAnonymous=true, isPerformer=false', () {
        const guest = UserProfile(id: 'guest-id', isAnonymous: true, isPerformer: false);
        expect(guest.isPerformer, isFalse);
        expect(guest.isAnonymous, isTrue);
        expect(guest.email, isNull);
      });

      test('performer profile: isPerformer=true', () {
        const performer = UserProfile(
          id: 'performer-id',
          isAnonymous: false,
          isPerformer: true,
          email: 'performer@example.com',
        );
        expect(performer.isPerformer, isTrue);
        expect(performer.isAnonymous, isFalse);
      });

      test('AuthException subclasses preserve message and technicalDetails', () {
        const e = SignInException('User-facing message', 'technical info');
        expect(e.message, 'User-facing message');
        expect(e.technicalDetails, 'technical info');
        expect(e.toString(), contains('User-facing message'));
      });
    });
  });
}
