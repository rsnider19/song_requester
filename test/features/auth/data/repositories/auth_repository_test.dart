import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:song_requester/features/auth/data/repositories/auth_repository.dart';
import 'package:song_requester/features/auth/domain/exceptions/auth_exception.dart';
import 'package:song_requester/services/logging_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// ---------------------------------------------------------------------------
// Mocks
// ---------------------------------------------------------------------------

class _MockSupabaseClient extends Mock implements SupabaseClient {}

class _MockGoTrueClient extends Mock implements GoTrueClient {}

class _MockLoggingService extends Mock implements LoggingService {}

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  late _MockSupabaseClient supabase;
  late _MockGoTrueClient auth;
  late _MockLoggingService logger;
  late AuthRepository repository;

  setUp(() {
    supabase = _MockSupabaseClient();
    auth = _MockGoTrueClient();
    logger = _MockLoggingService();
    repository = AuthRepository(
      supabase,
      logger,
      googleWebClientId: 'test-web-client-id',
    );
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

    // signInWithGoogle and signInWithApple use native SDK sheets and require
    // integration testing on a real device. Unit tests for those flows are
    // omitted here intentionally.

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
          repository.getProfile('user-id', isAnonymous: true),
          throwsA(isA<ProfileException>()),
        );
      });
    });
  });
}
