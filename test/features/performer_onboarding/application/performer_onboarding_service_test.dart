import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:song_requester/features/auth/application/auth_service.dart';
import 'package:song_requester/features/auth/domain/exceptions/auth_exception.dart';
import 'package:song_requester/features/auth/domain/models/user_profile.dart';
import 'package:song_requester/features/performer_onboarding/application/performer_onboarding_service.dart';
import 'package:song_requester/features/performer_onboarding/domain/exceptions/performer_onboarding_exception.dart';
import 'package:song_requester/services/logging_service.dart';

// ---------------------------------------------------------------------------
// Mocks
// ---------------------------------------------------------------------------

class _MockAuthService extends Mock implements AuthService {}

class _MockLoggingService extends Mock implements LoggingService {}

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  late _MockAuthService authService;
  late _MockLoggingService logger;
  late PerformerOnboardingService service;

  setUp(() {
    authService = _MockAuthService();
    logger = _MockLoggingService();
    service = PerformerOnboardingService(authService, logger);
  });

  group('PerformerOnboardingService', () {
    group('becomePerformer', () {
      test('returns updated UserProfile on success', () async {
        const updatedProfile = UserProfile(
          id: 'user-id',
          isAnonymous: false,
          isPerformer: true,
          email: 'user@example.com',
        );

        when(
          () => authService.becomePerformer('user-id'),
        ).thenAnswer((_) async => updatedProfile);

        final result = await service.becomePerformer('user-id');

        expect(result.isPerformer, isTrue);
        verify(() => authService.becomePerformer('user-id')).called(1);
      });

      test('throws BecomePerformerException when AuthService throws ProfileException', () async {
        when(
          () => authService.becomePerformer(any()),
        ).thenThrow(const ProfileException('DB error'));
        when(
          () => logger.e(
            any<dynamic>(),
            error: any<Object?>(named: 'error'),
            stackTrace: any<StackTrace?>(named: 'stackTrace'),
          ),
        ).thenReturn(null);

        await expectLater(
          service.becomePerformer('user-id'),
          throwsA(isA<BecomePerformerException>()),
        );
      });

      test('thrown BecomePerformerException has user-facing message', () async {
        when(
          () => authService.becomePerformer(any()),
        ).thenThrow(const ProfileException('DB error'));
        when(
          () => logger.e(
            any<dynamic>(),
            error: any<Object?>(named: 'error'),
            stackTrace: any<StackTrace?>(named: 'stackTrace'),
          ),
        ).thenReturn(null);

        BecomePerformerException? caught;
        try {
          await service.becomePerformer('user-id');
        } on BecomePerformerException catch (e) {
          caught = e;
        }
        expect(caught, isNotNull);
        expect(caught!.message, isNotEmpty);
      });

      test('throws BecomePerformerException on unexpected error', () async {
        when(
          () => authService.becomePerformer(any()),
        ).thenThrow(Exception('unexpected'));
        when(
          () => logger.e(
            any<dynamic>(),
            error: any<Object?>(named: 'error'),
            stackTrace: any<StackTrace?>(named: 'stackTrace'),
          ),
        ).thenReturn(null);

        await expectLater(
          service.becomePerformer('user-id'),
          throwsA(isA<BecomePerformerException>()),
        );
      });
    });
  });
}
