abstract class AuthException implements Exception {
  const AuthException(this.message, [this.technicalDetails]);

  final String message;
  final String? technicalDetails;

  @override
  String toString() => 'AuthException: $message${technicalDetails != null ? ' ($technicalDetails)' : ''}';
}

class SignInException extends AuthException {
  const SignInException(super.message, [super.technicalDetails]);
}

class ProfileException extends AuthException {
  const ProfileException(super.message, [super.technicalDetails]);
}
