sealed class SongException implements Exception {
  const SongException(this.message, [this.technicalDetails]);

  final String message;
  final String? technicalDetails;

  @override
  String toString() => 'SongException: $message${technicalDetails != null ? ' ($technicalDetails)' : ''}';
}

class SongLibraryException extends SongException {
  const SongLibraryException(super.message, [super.technicalDetails]);
}

class SpotifySearchException extends SongException {
  const SpotifySearchException(super.message, [super.technicalDetails]);
}
