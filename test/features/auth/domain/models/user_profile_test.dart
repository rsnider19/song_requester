import 'package:flutter_test/flutter_test.dart';
import 'package:song_requester/features/auth/domain/exceptions/auth_exception.dart';
import 'package:song_requester/features/auth/domain/models/user_profile.dart';

void main() {
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
  });

  group('AuthException subclasses', () {
    test('SignInException preserves message and technicalDetails', () {
      const e = SignInException('User-facing message', 'technical info');
      expect(e.message, 'User-facing message');
      expect(e.technicalDetails, 'technical info');
      expect(e.toString(), contains('User-facing message'));
    });

    test('ProfileException preserves message and technicalDetails', () {
      const e = ProfileException('Profile error', 'db detail');
      expect(e.message, 'Profile error');
      expect(e.technicalDetails, 'db detail');
      expect(e.toString(), contains('Profile error'));
    });
  });
}
