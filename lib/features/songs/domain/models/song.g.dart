// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'song.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Song _$SongFromJson(Map<String, dynamic> json) => _Song(
  songId: json['song_id'] as String,
  title: json['title'] as String,
  artist: json['artist'] as String,
  spotifyTrackId: json['spotify_track_id'] as String,
  albumArtUrl: json['album_art_url'] as String?,
  genres:
      (json['genres'] as List<dynamic>?)?.map((e) => e as String).toList() ??
      const <String>[],
);

Map<String, dynamic> _$SongToJson(_Song instance) => <String, dynamic>{
  'song_id': instance.songId,
  'title': instance.title,
  'artist': instance.artist,
  'spotify_track_id': instance.spotifyTrackId,
  'album_art_url': ?instance.albumArtUrl,
  'genres': instance.genres,
};
