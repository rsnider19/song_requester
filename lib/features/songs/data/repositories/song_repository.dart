import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:song_requester/app/providers/supabase_provider.dart';
import 'package:song_requester/features/songs/domain/exceptions/song_exception.dart';
import 'package:song_requester/features/songs/domain/models/performer_song.dart';
import 'package:song_requester/features/songs/domain/models/song.dart';
import 'package:song_requester/features/songs/domain/models/spotify_search_result.dart';
import 'package:song_requester/services/logging_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

part 'song_repository.g.dart';

class SongRepository {
  SongRepository(this._supabase, this._logger);

  final SupabaseClient _supabase;
  final LoggingService _logger;

  /// Searches Spotify via the `spotify-search` edge function.
  Future<List<SpotifySearchResult>> searchSpotify(String query) async {
    try {
      final response = await _supabase.functions.invoke(
        'spotify-search',
        body: {'action': 'search', 'query': query},
      );

      final data = response.data as Map<String, dynamic>;

      if (data.containsKey('error')) {
        throw SpotifySearchException(
          data['error'] as String? ?? 'Search failed',
        );
      }

      final tracks = data['tracks'] as List<dynamic>? ?? [];
      return tracks.map((t) => SpotifySearchResult.fromJson(t as Map<String, dynamic>)).toList();
    } on SpotifySearchException {
      rethrow;
    } on Exception catch (e, st) {
      _logger.e('Failed to search Spotify', error: e, stackTrace: st);
      throw SpotifySearchException('Could not search songs', e.toString());
    }
  }

  /// Fetches artist genres from Spotify via the edge function.
  Future<List<String>> fetchArtistGenres(String artistId) async {
    try {
      final response = await _supabase.functions.invoke(
        'spotify-search',
        body: {'action': 'artist-genres', 'artistId': artistId},
      );

      final data = response.data as Map<String, dynamic>;
      final genres = data['genres'] as List<dynamic>? ?? [];
      return genres.cast<String>();
    } on Exception catch (e, st) {
      // Genres are best-effort; log and return empty.
      _logger.w('Failed to fetch artist genres', error: e, stackTrace: st);
      return [];
    }
  }

  /// Upserts a song by spotify_track_id. Returns the song row.
  Future<Song> upsertSong({
    required String title,
    required String artist,
    required String spotifyTrackId,
    String? albumArtUrl,
    List<String>? genres,
  }) async {
    try {
      final row = await _supabase
          .from('song')
          .upsert(
            {
              'title': title,
              'artist': artist,
              'spotify_track_id': spotifyTrackId,
              'album_art_url': albumArtUrl,
              'genres': genres ?? <String>[],
            },
            onConflict: 'spotify_track_id',
          )
          .select()
          .single();
      return Song(
        songId: row['song_id'] as String,
        title: row['title'] as String,
        artist: row['artist'] as String,
        spotifyTrackId: row['spotify_track_id'] as String,
        albumArtUrl: row['album_art_url'] as String?,
        genres: (row['genres'] as List<dynamic>?)?.cast<String>() ?? [],
      );
    } on Exception catch (e, st) {
      _logger.e('Failed to upsert song', error: e, stackTrace: st);
      throw SongLibraryException('Could not save song', e.toString());
    }
  }

  /// Adds a song to the performer's library.
  Future<void> addToLibrary({
    required String profileId,
    required String songId,
    required int sortOrder,
  }) async {
    try {
      await _supabase.from('performer_song').insert({
        'profile_id': profileId,
        'song_id': songId,
        'sort_order': sortOrder,
      });
    } on Exception catch (e, st) {
      _logger.e('Failed to add song to library', error: e, stackTrace: st);
      throw SongLibraryException('Could not add song to library', e.toString());
    }
  }

  /// Removes a song from the performer's library.
  Future<void> removeFromLibrary({
    required String profileId,
    required String songId,
  }) async {
    try {
      await _supabase.from('performer_song').delete().eq('profile_id', profileId).eq('song_id', songId);
    } on Exception catch (e, st) {
      _logger.e('Failed to remove song from library', error: e, stackTrace: st);
      throw SongLibraryException('Could not remove song', e.toString());
    }
  }

  /// Returns the performer's song library ordered by sort_order.
  Future<List<PerformerSong>> getLibrary(String profileId) async {
    try {
      final rows = await _supabase
          .from('performer_song')
          .select(
            'performer_song_id, profile_id, song_id, sort_order, song:song!inner(song_id, title, artist, spotify_track_id, album_art_url, genres)',
          )
          .eq('profile_id', profileId)
          .order('sort_order');

      return rows.map((row) {
        final songData = row['song'] as Map<String, dynamic>;
        return PerformerSong(
          performerSongId: row['performer_song_id'] as String,
          profileId: row['profile_id'] as String,
          songId: row['song_id'] as String,
          sortOrder: row['sort_order'] as int,
          song: Song(
            songId: songData['song_id'] as String,
            title: songData['title'] as String,
            artist: songData['artist'] as String,
            spotifyTrackId: songData['spotify_track_id'] as String,
            albumArtUrl: songData['album_art_url'] as String?,
            genres: (songData['genres'] as List<dynamic>?)?.cast<String>() ?? [],
          ),
        );
      }).toList();
    } on Exception catch (e, st) {
      _logger.e('Failed to fetch song library', error: e, stackTrace: st);
      throw SongLibraryException('Could not load song library', e.toString());
    }
  }

  /// Updates sort order for multiple performer_song rows in a batch.
  Future<void> updateSortOrder(List<({String performerSongId, int sortOrder})> updates) async {
    try {
      for (final update in updates) {
        await _supabase
            .from('performer_song')
            .update({'sort_order': update.sortOrder})
            .eq('performer_song_id', update.performerSongId);
      }
    } on Exception catch (e, st) {
      _logger.e('Failed to update sort order', error: e, stackTrace: st);
      throw SongLibraryException('Could not reorder songs', e.toString());
    }
  }

  /// Returns the set of Spotify track IDs already in the performer's library.
  Future<Set<String>> getLibraryTrackIds(String profileId) async {
    try {
      final rows = await _supabase
          .from('performer_song')
          .select('song:song!inner(spotify_track_id)')
          .eq('profile_id', profileId);

      return rows.map((row) => (row['song'] as Map<String, dynamic>)['spotify_track_id'] as String).toSet();
    } on Exception catch (e, st) {
      _logger.e('Failed to fetch library track IDs', error: e, stackTrace: st);
      throw SongLibraryException('Could not check library', e.toString());
    }
  }
}

@Riverpod(keepAlive: true)
SongRepository songRepository(Ref ref) => SongRepository(
  ref.watch(supabaseProvider),
  ref.watch(loggingServiceProvider),
);
