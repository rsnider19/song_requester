import 'package:freezed_annotation/freezed_annotation.dart';

part 'spotify_search_result.freezed.dart';
part 'spotify_search_result.g.dart';

@freezed
abstract class SpotifySearchResult with _$SpotifySearchResult {
  const factory SpotifySearchResult({
    required String spotifyTrackId,
    required String title,
    required String artist,
    required String artistId,
    String? albumArtUrl,
  }) = _SpotifySearchResult;

  factory SpotifySearchResult.fromJson(Map<String, dynamic> json) => _$SpotifySearchResultFromJson(json);
}
