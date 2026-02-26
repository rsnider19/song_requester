import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:song_requester/features/auth/application/auth_service.dart';
import 'package:song_requester/features/auth/data/repositories/auth_repository.dart';
import 'package:song_requester/features/auth/domain/exceptions/auth_exception.dart';
import 'package:song_requester/features/auth/domain/models/user_profile.dart';
import 'package:song_requester/services/logging_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// ---------------------------------------------------------------------------
// Mocks
// ---------------------------------------------------------------------------

class _MockAuthRepository extends Mock implements AuthRepository {}

class _MockLoggingService extends Mock implements LoggingService {}

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  late _MockAuthRepository repository;
  late _MockLoggingService logger;
  late AuthService service;

  const guestProfile = UserProfile(id: 'guest-id', isAnonymous: true, isPerformer: false);

  setUp(() {
    repository = _MockAuthRepository();
    logger = _MockLoggingService();
    service = AuthService(repository, logger);
  });

  group('AuthService', () {
    group('watchUserProfile', () {
      test('emits UserProfile when user exists', () async {
        final controller = StreamController<User?>();
        final mockUser = _MockUser(id: 'guest-id', isAnonymous: true);

        when(() => repository.watchAuthState()).thenAnswer((_) => controller.stream);
        when(
          () => repository.getProfile('guest-id', isAnonymous: true),
        ).thenAnswer((_) async => guestProfile);

        final stream = service.watchUserProfile();

        controller.add(mockUser);
        await expectLater(stream, emits(guestProfile));

        await controller.close();
      });

      test('emits null when user is null', () async {
        final controller = StreamController<User?>();

        when(() => repository.watchAuthState()).thenAnswer((_) => controller.stream);

        final stream = service.watchUserProfile();

        controller.add(null);
        await expectLater(stream, emits(isNull));

        await controller.close();
      });

      test('falls back to minimal guest profile when getProfile throws', () async {
        final controller = StreamController<User?>();
        final mockUser = _MockUser(id: 'user-id', isAnonymous: false);

        when(() => repository.watchAuthState()).thenAnswer((_) => controller.stream);
        when(
          () => repository.getProfile(any<String>(), isAnonymous: any<bool>(named: 'isAnonymous')),
        ).thenThrow(const ProfileException('error'));
        when(
          () => logger.w(
            any<dynamic>(),
            error: any<Object?>(named: 'error'),
            stackTrace: any<StackTrace?>(named: 'stackTrace'),
          ),
        ).thenReturn(null);

        final stream = service.watchUserProfile();

        controller.add(mockUser);
        await expectLater(
          stream,
          emits(
            isA<UserProfile>()
                .having((p) => p.id, 'id', 'user-id')
                .having((p) => p.isAnonymous, 'isAnonymous', false)
                .having((p) => p.isPerformer, 'isPerformer', false),
          ),
        );

        await controller.close();
      });
    });

    group('signInWithGoogle', () {
      test('delegates to repository and throws SignInException (stub)', () async {
        when(
          () => repository.signInWithGoogle(),
        ).thenAnswer((_) => Future.error(const SignInException('not implemented')));

        await expectLater(service.signInWithGoogle(), throwsA(isA<SignInException>()));
      });
    });

    group('signInWithApple', () {
      test('delegates to repository and throws SignInException (stub)', () async {
        when(
          () => repository.signInWithApple(),
        ).thenAnswer((_) => Future.error(const SignInException('not implemented')));

        await expectLater(service.signInWithApple(), throwsA(isA<SignInException>()));
      });
    });

    group('signOut', () {
      test('delegates to repository', () async {
        when(() => repository.signOut()).thenAnswer((_) async {});

        await expectLater(service.signOut(), completes);
        verify(() => repository.signOut()).called(1);
      });
    });

    group('signed-in profile', () {
      test('performer flag is preserved from repository', () async {
        const performer = UserProfile(
          id: 'performer-id',
          isAnonymous: false,
          isPerformer: true,
          email: 'performer@example.com',
        );
        final controller = StreamController<User?>();
        final mockUser = _MockUser(id: 'performer-id', isAnonymous: false);

        when(() => repository.watchAuthState()).thenAnswer((_) => controller.stream);
        when(
          () => repository.getProfile('performer-id', isAnonymous: false),
        ).thenAnswer((_) async => performer);

        final stream = service.watchUserProfile();
        controller.add(mockUser);

        await expectLater(
          stream,
          emits(isA<UserProfile>().having((p) => p.isPerformer, 'isPerformer', true)),
        );

        await controller.close();
      });
    });
  });
}

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

class _MockUser extends Mock implements User {
  _MockUser({required this.id, required this.isAnonymous});

  @override
  final String id;

  @override
  final bool isAnonymous;

  @override
  String? get email => null;
}
