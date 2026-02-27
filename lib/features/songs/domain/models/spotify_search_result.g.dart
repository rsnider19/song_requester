// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'spotify_search_result.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_SpotifySearchResult _$SpotifySearchResultFromJson(Map<String, dynamic> json) =>
    _SpotifySearchResult(
      spotifyTrackId: json['spotify_track_id'] as String,
      title: json['title'] as String,
      artist: json['artist'] as String,
      artistId: json['artist_id'] as String,
      albumArtUrl: json['album_art_url'] as String?,
    );

Map<String, dynamic> _$SpotifySearchResultToJson(
  _SpotifySearchResult instance,
) => <String, dynamic>{
  'spotify_track_id': instance.spotifyTrackId,
  'title': instance.title,
  'artist': instance.artist,
  'artist_id': instance.artistId,
  'album_art_url': ?instance.albumArtUrl,
};
