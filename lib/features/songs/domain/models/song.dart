import 'package:freezed_annotation/freezed_annotation.dart';

part 'song.freezed.dart';
part 'song.g.dart';

@freezed
abstract class Song with _$Song {
  const factory Song({
    required String songId,
    required String title,
    required String artist,
    required String spotifyTrackId,
    String? albumArtUrl,
    @Default(<String>[]) List<String> genres,
  }) = _Song;

  factory Song.fromJson(Map<String, dynamic> json) => _$SongFromJson(json);
}
