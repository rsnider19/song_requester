// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'performer_song.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_PerformerSong _$PerformerSongFromJson(Map<String, dynamic> json) =>
    _PerformerSong(
      performerSongId: json['performer_song_id'] as String,
      profileId: json['profile_id'] as String,
      songId: json['song_id'] as String,
      sortOrder: (json['sort_order'] as num).toInt(),
      song: Song.fromJson(json['song'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$PerformerSongToJson(_PerformerSong instance) =>
    <String, dynamic>{
      'performer_song_id': instance.performerSongId,
      'profile_id': instance.profileId,
      'song_id': instance.songId,
      'sort_order': instance.sortOrder,
      'song': instance.song,
    };
