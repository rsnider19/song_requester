abstract class PerformerOnboardingException implements Exception {
  const PerformerOnboardingException(this.message, [this.technicalDetails]);
  final String message;
  final String? technicalDetails;

  @override
  String toString() => 'PerformerOnboardingException: $message';
}

class BecomePerformerException extends PerformerOnboardingException {
  const BecomePerformerException(super.message, [super.technicalDetails]);
}
