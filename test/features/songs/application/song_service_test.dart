import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:song_requester/features/songs/application/song_service.dart';
import 'package:song_requester/features/songs/data/repositories/song_repository.dart';
import 'package:song_requester/features/songs/domain/exceptions/song_exception.dart';
import 'package:song_requester/features/songs/domain/models/performer_song.dart';
import 'package:song_requester/features/songs/domain/models/song.dart';
import 'package:song_requester/features/songs/domain/models/spotify_search_result.dart';
import 'package:song_requester/services/logging_service.dart';

class _MockSongRepository extends Mock implements SongRepository {}

class _MockLoggingService extends Mock implements LoggingService {}

const _searchResult = SpotifySearchResult(
  spotifyTrackId: 'track-1',
  title: 'Test Song',
  artist: 'Test Artist',
  artistId: 'artist-1',
  albumArtUrl: 'https://example.com/art.jpg',
);

const _song = Song(
  songId: 'song-1',
  title: 'Test Song',
  artist: 'Test Artist',
  spotifyTrackId: 'track-1',
  albumArtUrl: 'https://example.com/art.jpg',
  genres: ['pop', 'rock'],
);

const _performerSong = PerformerSong(
  performerSongId: 'ps-1',
  profileId: 'profile-1',
  songId: 'song-1',
  sortOrder: 0,
  song: _song,
);

void main() {
  late _MockSongRepository repository;
  late _MockLoggingService logger;
  late SongService service;

  setUp(() {
    repository = _MockSongRepository();
    logger = _MockLoggingService();
    service = SongService(repository, logger);
  });

  group('searchSpotify', () {
    test('trims query and delegates to repository', () async {
      when(() => repository.searchSpotify('test')).thenAnswer((_) async => [_searchResult]);

      final results = await service.searchSpotify('  test  ');

      expect(results, [_searchResult]);
      verify(() => repository.searchSpotify('test')).called(1);
    });

    test('returns empty list for empty query', () async {
      final results = await service.searchSpotify('   ');

      expect(results, isEmpty);
      verifyNever(() => repository.searchSpotify(any()));
    });

    test('returns empty list for blank query', () async {
      final results = await service.searchSpotify('');

      expect(results, isEmpty);
      verifyNever(() => repository.searchSpotify(any()));
    });
  });

  group('getLibrary', () {
    test('delegates to repository', () async {
      when(() => repository.getLibrary('profile-1')).thenAnswer((_) async => [_performerSong]);

      final library = await service.getLibrary('profile-1');

      expect(library, [_performerSong]);
      verify(() => repository.getLibrary('profile-1')).called(1);
    });

    test('throws SongLibraryException for empty profileId', () {
      expect(
        () => service.getLibrary(''),
        throwsA(isA<SongLibraryException>()),
      );
    });
  });

  group('getLibraryTrackIds', () {
    test('delegates to repository', () async {
      when(() => repository.getLibraryTrackIds('profile-1')).thenAnswer((_) async => {'track-1', 'track-2'});

      final ids = await service.getLibraryTrackIds('profile-1');

      expect(ids, {'track-1', 'track-2'});
      verify(() => repository.getLibraryTrackIds('profile-1')).called(1);
    });

    test('throws SongLibraryException for empty profileId', () {
      expect(
        () => service.getLibraryTrackIds(''),
        throwsA(isA<SongLibraryException>()),
      );
    });
  });

  group('addSongToLibrary', () {
    test('fetches genres, upserts song, and adds to library', () async {
      when(() => repository.fetchArtistGenres('artist-1')).thenAnswer((_) async => ['pop', 'rock']);
      when(
        () => repository.upsertSong(
          title: any(named: 'title'),
          artist: any(named: 'artist'),
          spotifyTrackId: any(named: 'spotifyTrackId'),
          albumArtUrl: any(named: 'albumArtUrl'),
          genres: any(named: 'genres'),
        ),
      ).thenAnswer((_) async => _song);
      when(
        () => repository.addToLibrary(
          profileId: any(named: 'profileId'),
          songId: any(named: 'songId'),
          sortOrder: any(named: 'sortOrder'),
        ),
      ).thenAnswer((_) async {});
      when(
        () => logger.i(
          any<dynamic>(),
          error: any<Object?>(named: 'error'),
          stackTrace: any<StackTrace?>(named: 'stackTrace'),
        ),
      ).thenReturn(null);

      final softLimitReached = await service.addSongToLibrary(
        profileId: 'profile-1',
        searchResult: _searchResult,
        currentLibrarySize: 5,
      );

      expect(softLimitReached, isFalse);
      verify(() => repository.fetchArtistGenres('artist-1')).called(1);
      verify(
        () => repository.upsertSong(
          title: 'Test Song',
          artist: 'Test Artist',
          spotifyTrackId: 'track-1',
          albumArtUrl: 'https://example.com/art.jpg',
          genres: ['pop', 'rock'],
        ),
      ).called(1);
      verify(
        () => repository.addToLibrary(
          profileId: 'profile-1',
          songId: 'song-1',
          sortOrder: 5,
        ),
      ).called(1);
    });

    test('returns true when soft limit is reached', () async {
      when(() => repository.fetchArtistGenres(any())).thenAnswer((_) async => []);
      when(
        () => repository.upsertSong(
          title: any(named: 'title'),
          artist: any(named: 'artist'),
          spotifyTrackId: any(named: 'spotifyTrackId'),
          albumArtUrl: any(named: 'albumArtUrl'),
          genres: any(named: 'genres'),
        ),
      ).thenAnswer((_) async => _song);
      when(
        () => repository.addToLibrary(
          profileId: any(named: 'profileId'),
          songId: any(named: 'songId'),
          sortOrder: any(named: 'sortOrder'),
        ),
      ).thenAnswer((_) async {});
      when(
        () => logger.i(
          any<dynamic>(),
          error: any<Object?>(named: 'error'),
          stackTrace: any<StackTrace?>(named: 'stackTrace'),
        ),
      ).thenReturn(null);

      final softLimitReached = await service.addSongToLibrary(
        profileId: 'profile-1',
        searchResult: _searchResult,
        currentLibrarySize: 499,
      );

      expect(softLimitReached, isTrue);
    });

    test('skips genre fetch when artistId is empty', () async {
      const noArtistResult = SpotifySearchResult(
        spotifyTrackId: 'track-2',
        title: 'No Artist Song',
        artist: 'Unknown',
        artistId: '',
      );

      when(
        () => repository.upsertSong(
          title: any(named: 'title'),
          artist: any(named: 'artist'),
          spotifyTrackId: any(named: 'spotifyTrackId'),
          albumArtUrl: any(named: 'albumArtUrl'),
          genres: any(named: 'genres'),
        ),
      ).thenAnswer((_) async => _song);
      when(
        () => repository.addToLibrary(
          profileId: any(named: 'profileId'),
          songId: any(named: 'songId'),
          sortOrder: any(named: 'sortOrder'),
        ),
      ).thenAnswer((_) async {});

      await service.addSongToLibrary(
        profileId: 'profile-1',
        searchResult: noArtistResult,
        currentLibrarySize: 0,
      );

      verifyNever(() => repository.fetchArtistGenres(any()));
      verify(
        () => repository.upsertSong(
          title: 'No Artist Song',
          artist: 'Unknown',
          spotifyTrackId: 'track-2',
          genres: <String>[],
        ),
      ).called(1);
    });

    test('throws SongLibraryException for empty profileId', () async {
      expect(
        () => service.addSongToLibrary(
          profileId: '',
          searchResult: _searchResult,
          currentLibrarySize: 0,
        ),
        throwsA(isA<SongLibraryException>()),
      );
    });
  });

  group('removeSongFromLibrary', () {
    test('delegates to repository', () async {
      when(
        () => repository.removeFromLibrary(
          profileId: any(named: 'profileId'),
          songId: any(named: 'songId'),
        ),
      ).thenAnswer((_) async {});

      await service.removeSongFromLibrary(profileId: 'profile-1', songId: 'song-1');

      verify(
        () => repository.removeFromLibrary(profileId: 'profile-1', songId: 'song-1'),
      ).called(1);
    });

    test('throws SongLibraryException for empty profileId', () {
      expect(
        () => service.removeSongFromLibrary(profileId: '', songId: 'song-1'),
        throwsA(isA<SongLibraryException>()),
      );
    });

    test('throws SongLibraryException for empty songId', () {
      expect(
        () => service.removeSongFromLibrary(profileId: 'profile-1', songId: ''),
        throwsA(isA<SongLibraryException>()),
      );
    });
  });

  group('reorderLibrary', () {
    test('only sends updates for changed sort orders', () async {
      final list = [
        _performerSong.copyWith(performerSongId: 'ps-1', sortOrder: 1),
        _performerSong.copyWith(performerSongId: 'ps-2', sortOrder: 0),
      ];

      when(() => repository.updateSortOrder(any())).thenAnswer((_) async {});

      await service.reorderLibrary(list);

      final captured =
          verify(() => repository.updateSortOrder(captureAny())).captured.single
              as List<({String performerSongId, int sortOrder})>;

      expect(captured.length, 2);
      expect(captured[0].performerSongId, 'ps-1');
      expect(captured[0].sortOrder, 0);
      expect(captured[1].performerSongId, 'ps-2');
      expect(captured[1].sortOrder, 1);
    });

    test('skips update when all sort orders already match', () async {
      final list = [
        _performerSong.copyWith(performerSongId: 'ps-1', sortOrder: 0),
        _performerSong.copyWith(performerSongId: 'ps-2', sortOrder: 1),
      ];

      await service.reorderLibrary(list);

      verifyNever(() => repository.updateSortOrder(any()));
    });
  });
}
