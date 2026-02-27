import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:song_requester/features/songs/domain/models/song.dart';

part 'performer_song.freezed.dart';
part 'performer_song.g.dart';

@freezed
abstract class PerformerSong with _$PerformerSong {
  const factory PerformerSong({
    required String performerSongId,
    required String profileId,
    required String songId,
    required int sortOrder,
    required Song song,
  }) = _PerformerSong;

  factory PerformerSong.fromJson(Map<String, dynamic> json) => _$PerformerSongFromJson(json);
}
