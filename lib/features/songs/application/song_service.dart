import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:song_requester/features/songs/data/repositories/song_repository.dart';
import 'package:song_requester/features/songs/domain/exceptions/song_exception.dart';
import 'package:song_requester/features/songs/domain/models/performer_song.dart';
import 'package:song_requester/features/songs/domain/models/spotify_search_result.dart';
import 'package:song_requester/services/logging_service.dart';

part 'song_service.g.dart';

/// Soft limit threshold for song library size.
const int songLibrarySoftLimit = 500;

class SongService {
  SongService(this._repository, this._logger);

  final SongRepository _repository;
  final LoggingService _logger;

  /// Searches Spotify for tracks matching [query].
  Future<List<SpotifySearchResult>> searchSpotify(String query) async {
    final trimmed = query.trim();
    if (trimmed.isEmpty) return [];
    return _repository.searchSpotify(trimmed);
  }

  /// Returns the performer's song library.
  Future<List<PerformerSong>> getLibrary(String profileId) {
    if (profileId.isEmpty) throw const SongLibraryException('Profile ID is required');
    return _repository.getLibrary(profileId);
  }

  /// Returns the set of Spotify track IDs already in the performer's library.
  Future<Set<String>> getLibraryTrackIds(String profileId) {
    if (profileId.isEmpty) throw const SongLibraryException('Profile ID is required');
    return _repository.getLibraryTrackIds(profileId);
  }

  /// Adds a song to the performer's library from a Spotify search result.
  ///
  /// Upserts the song in the shared `song` table (dedup by spotify_track_id),
  /// fetches artist genres, then creates the `performer_song` link.
  ///
  /// Returns `true` if the soft limit was reached after adding.
  Future<bool> addSongToLibrary({
    required String profileId,
    required SpotifySearchResult searchResult,
    required int currentLibrarySize,
  }) async {
    if (profileId.isEmpty) throw const SongLibraryException('Profile ID is required');

    // Fetch artist genres (best-effort).
    final genres = searchResult.artistId.isNotEmpty
        ? await _repository.fetchArtistGenres(searchResult.artistId)
        : <String>[];

    // Upsert song (shared table).
    final song = await _repository.upsertSong(
      title: searchResult.title,
      artist: searchResult.artist,
      spotifyTrackId: searchResult.spotifyTrackId,
      albumArtUrl: searchResult.albumArtUrl,
      genres: genres,
    );

    // Add to performer's library at the end.
    await _repository.addToLibrary(
      profileId: profileId,
      songId: song.songId,
      sortOrder: currentLibrarySize,
    );

    final newSize = currentLibrarySize + 1;
    if (newSize >= songLibrarySoftLimit) {
      _logger.i('Performer $profileId reached soft limit ($newSize songs)');
    }
    return newSize >= songLibrarySoftLimit;
  }

  /// Removes a song from the performer's library.
  Future<void> removeSongFromLibrary({
    required String profileId,
    required String songId,
  }) async {
    if (profileId.isEmpty) throw const SongLibraryException('Profile ID is required');
    if (songId.isEmpty) throw const SongLibraryException('Song ID is required');
    await _repository.removeFromLibrary(profileId: profileId, songId: songId);
  }

  /// Reorders the performer's song library. Accepts the full list
  /// of performer_song IDs in the desired order.
  Future<void> reorderLibrary(List<PerformerSong> reorderedList) async {
    final updates = <({String performerSongId, int sortOrder})>[];
    for (var i = 0; i < reorderedList.length; i++) {
      final item = reorderedList[i];
      if (item.sortOrder != i) {
        updates.add((performerSongId: item.performerSongId, sortOrder: i));
      }
    }
    if (updates.isEmpty) return;
    await _repository.updateSortOrder(updates);
  }
}

@Riverpod(keepAlive: true)
SongService songService(Ref ref) => SongService(
  ref.watch(songRepositoryProvider),
  ref.watch(loggingServiceProvider),
);
