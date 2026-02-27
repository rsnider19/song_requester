import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:song_requester/features/songs/data/repositories/song_repository.dart';
import 'package:song_requester/features/songs/domain/exceptions/song_exception.dart';
import 'package:song_requester/services/logging_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class _MockSupabaseClient extends Mock implements SupabaseClient {}

class _MockFunctionsClient extends Mock implements FunctionsClient {}

class _MockLoggingService extends Mock implements LoggingService {}

void main() {
  late _MockSupabaseClient supabase;
  late _MockFunctionsClient functions;
  late _MockLoggingService logger;
  late SongRepository repository;

  setUp(() {
    supabase = _MockSupabaseClient();
    functions = _MockFunctionsClient();
    logger = _MockLoggingService();
    repository = SongRepository(supabase, logger);

    when(() => supabase.functions).thenReturn(functions);
  });

  group('searchSpotify', () {
    test('returns parsed results on success', () async {
      when(
        () => functions.invoke(
          'spotify-search',
          body: {'action': 'search', 'query': 'test query'},
        ),
      ).thenAnswer(
        (_) async => FunctionResponse(
          status: 200,
          data: {
            'tracks': [
              {
                'spotify_track_id': 'track-1',
                'title': 'Song One',
                'artist': 'Artist One',
                'artist_id': 'artist-1',
                'album_art_url': 'https://example.com/art1.jpg',
              },
              {
                'spotify_track_id': 'track-2',
                'title': 'Song Two',
                'artist': 'Artist Two',
                'artist_id': 'artist-2',
              },
            ],
          },
        ),
      );

      final results = await repository.searchSpotify('test query');

      expect(results.length, 2);
      expect(results[0].spotifyTrackId, 'track-1');
      expect(results[0].title, 'Song One');
      expect(results[0].artist, 'Artist One');
      expect(results[0].artistId, 'artist-1');
      expect(results[0].albumArtUrl, 'https://example.com/art1.jpg');
      expect(results[1].spotifyTrackId, 'track-2');
      expect(results[1].albumArtUrl, isNull);
    });

    test('returns empty list when tracks key is missing', () async {
      when(
        () => functions.invoke(
          'spotify-search',
          body: {'action': 'search', 'query': 'noresults'},
        ),
      ).thenAnswer(
        (_) async => FunctionResponse(status: 200, data: <String, dynamic>{}),
      );

      final results = await repository.searchSpotify('noresults');

      expect(results, isEmpty);
    });

    test('throws SpotifySearchException when response contains error key', () async {
      when(
        () => functions.invoke(
          'spotify-search',
          body: {'action': 'search', 'query': 'bad'},
        ),
      ).thenAnswer(
        (_) async => FunctionResponse(
          status: 200,
          data: {'error': 'Invalid query'},
        ),
      );

      await expectLater(
        repository.searchSpotify('bad'),
        throwsA(
          isA<SpotifySearchException>().having((e) => e.message, 'message', 'Invalid query'),
        ),
      );
    });

    test('throws SpotifySearchException on network error', () async {
      when(
        () => functions.invoke(
          'spotify-search',
          body: {'action': 'search', 'query': 'test'},
        ),
      ).thenThrow(Exception('Network error'));

      when(
        () => logger.e(
          any<dynamic>(),
          error: any<Object?>(named: 'error'),
          stackTrace: any<StackTrace?>(named: 'stackTrace'),
        ),
      ).thenReturn(null);

      await expectLater(
        repository.searchSpotify('test'),
        throwsA(isA<SpotifySearchException>()),
      );

      verify(
        () => logger.e(
          'Failed to search Spotify',
          error: any<Object?>(named: 'error'),
          stackTrace: any<StackTrace?>(named: 'stackTrace'),
        ),
      ).called(1);
    });
  });

  group('fetchArtistGenres', () {
    test('returns genres on success', () async {
      when(
        () => functions.invoke(
          'spotify-search',
          body: {'action': 'artist-genres', 'artistId': 'artist-1'},
        ),
      ).thenAnswer(
        (_) async => FunctionResponse(
          status: 200,
          data: {
            'genres': ['pop', 'rock', 'indie'],
          },
        ),
      );

      final genres = await repository.fetchArtistGenres('artist-1');

      expect(genres, ['pop', 'rock', 'indie']);
    });

    test('returns empty list when genres key is missing', () async {
      when(
        () => functions.invoke(
          'spotify-search',
          body: {'action': 'artist-genres', 'artistId': 'artist-1'},
        ),
      ).thenAnswer(
        (_) async => FunctionResponse(status: 200, data: <String, dynamic>{}),
      );

      final genres = await repository.fetchArtistGenres('artist-1');

      expect(genres, isEmpty);
    });

    test('returns empty list on error (best-effort)', () async {
      when(
        () => functions.invoke(
          'spotify-search',
          body: {'action': 'artist-genres', 'artistId': 'artist-1'},
        ),
      ).thenThrow(Exception('Network error'));

      when(
        () => logger.w(
          any<dynamic>(),
          error: any<Object?>(named: 'error'),
          stackTrace: any<StackTrace?>(named: 'stackTrace'),
        ),
      ).thenReturn(null);

      final genres = await repository.fetchArtistGenres('artist-1');

      expect(genres, isEmpty);
      verify(
        () => logger.w(
          'Failed to fetch artist genres',
          error: any<Object?>(named: 'error'),
          stackTrace: any<StackTrace?>(named: 'stackTrace'),
        ),
      ).called(1);
    });
  });
}
