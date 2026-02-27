import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:song_requester/features/auth/domain/models/user_profile.dart';
import 'package:song_requester/features/auth/presentation/providers/auth_state_notifier.dart';
import 'package:song_requester/features/songs/application/song_service.dart';
import 'package:song_requester/features/songs/domain/exceptions/song_exception.dart';
import 'package:song_requester/features/songs/domain/models/performer_song.dart';
import 'package:song_requester/features/songs/domain/models/song.dart';
import 'package:song_requester/features/songs/domain/models/spotify_search_result.dart';
import 'package:song_requester/features/songs/presentation/providers/song_library_state_notifier.dart';

// ---------------------------------------------------------------------------
// Mocks & fakes
// ---------------------------------------------------------------------------

class _MockSongService extends Mock implements SongService {}

class _FakeAuthStateNotifier extends AuthStateNotifier {
  _FakeAuthStateNotifier(this._profile);
  final UserProfile? _profile;

  @override
  UserProfile? build() => _profile;
}

// ---------------------------------------------------------------------------
// Fixtures
// ---------------------------------------------------------------------------

const _profile = UserProfile(
  id: 'profile-1',
  isAnonymous: false,
  isPerformer: true,
  email: 'performer@example.com',
);

const _song1 = Song(
  songId: 'song-1',
  title: 'Song One',
  artist: 'Artist One',
  spotifyTrackId: 'track-1',
);

const _song2 = Song(
  songId: 'song-2',
  title: 'Song Two',
  artist: 'Artist Two',
  spotifyTrackId: 'track-2',
);

const _performerSong1 = PerformerSong(
  performerSongId: 'ps-1',
  profileId: 'profile-1',
  songId: 'song-1',
  sortOrder: 0,
  song: _song1,
);

const _performerSong2 = PerformerSong(
  performerSongId: 'ps-2',
  profileId: 'profile-1',
  songId: 'song-2',
  sortOrder: 1,
  song: _song2,
);

const _searchResult = SpotifySearchResult(
  spotifyTrackId: 'track-3',
  title: 'New Song',
  artist: 'New Artist',
  artistId: 'artist-3',
);

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

void main() {
  late _MockSongService service;

  setUp(() {
    service = _MockSongService();
    registerFallbackValue(_searchResult);
  });

  ProviderContainer makeContainer({UserProfile? profile = _profile}) {
    final container = ProviderContainer(
      overrides: [
        authStateProvider.overrideWith(() => _FakeAuthStateNotifier(profile)),
        songServiceProvider.overrideWithValue(service),
      ],
    );
    addTearDown(container.dispose);
    return container;
  }

  group('SongLibraryStateNotifier', () {
    group('build', () {
      test('returns empty data when profile is null', () {
        final container = makeContainer(profile: null);
        final state = container.read(songLibraryStateProvider);

        expect(state, const AsyncData<List<PerformerSong>>([]));
      });

      test('starts with loading then transitions to data on success', () async {
        when(() => service.getLibrary('profile-1')).thenAnswer(
          (_) async => [_performerSong1, _performerSong2],
        );

        final container = makeContainer();
        final states = <AsyncValue<List<PerformerSong>>>[];
        container.listen(songLibraryStateProvider, (_, next) => states.add(next));

        // Initial state is loading.
        expect(container.read(songLibraryStateProvider), isA<AsyncLoading<List<PerformerSong>>>());

        // Wait for the async load to complete.
        await Future<void>.delayed(Duration.zero);

        expect(states.last, isA<AsyncData<List<PerformerSong>>>());
        expect(states.last.value, [_performerSong1, _performerSong2]);
      });

      test('transitions to error when service throws', () async {
        when(() => service.getLibrary('profile-1')).thenAnswer(
          (_) async => throw const SongLibraryException('Load failed'),
        );

        final container = makeContainer();
        container.listen(songLibraryStateProvider, (_, _) {});

        // Wait for the async load to complete.
        await Future<void>.delayed(Duration.zero);

        expect(container.read(songLibraryStateProvider), isA<AsyncError<List<PerformerSong>>>());
      });
    });

    group('refresh', () {
      test('reloads library from service', () async {
        when(() => service.getLibrary('profile-1')).thenAnswer(
          (_) async => [_performerSong1],
        );

        final container = makeContainer();
        container.listen(songLibraryStateProvider, (_, _) {});

        // Wait for initial load.
        await Future<void>.delayed(Duration.zero);
        expect(container.read(songLibraryStateProvider).value, [_performerSong1]);

        // Update the service to return a different result.
        when(() => service.getLibrary('profile-1')).thenAnswer(
          (_) async => [_performerSong1, _performerSong2],
        );

        await container.read(songLibraryStateProvider.notifier).refresh();

        expect(container.read(songLibraryStateProvider).value, [_performerSong1, _performerSong2]);
        verify(() => service.getLibrary('profile-1')).called(2);
      });

      test('does nothing when profile is null', () async {
        final container = makeContainer(profile: null);
        container.listen(songLibraryStateProvider, (_, _) {});

        await container.read(songLibraryStateProvider.notifier).refresh();

        verifyNever(() => service.getLibrary(any()));
      });
    });

    group('addSong', () {
      test('delegates to service and refreshes library', () async {
        when(() => service.getLibrary('profile-1')).thenAnswer(
          (_) async => [_performerSong1],
        );
        when(
          () => service.addSongToLibrary(
            profileId: any(named: 'profileId'),
            searchResult: any(named: 'searchResult'),
            currentLibrarySize: any(named: 'currentLibrarySize'),
          ),
        ).thenAnswer((_) async => false);

        final container = makeContainer();
        container.listen(songLibraryStateProvider, (_, _) {});

        // Wait for initial load.
        await Future<void>.delayed(Duration.zero);

        final softLimitReached = await container.read(songLibraryStateProvider.notifier).addSong(_searchResult);

        expect(softLimitReached, isFalse);
        verify(
          () => service.addSongToLibrary(
            profileId: 'profile-1',
            searchResult: _searchResult,
            currentLibrarySize: 1,
          ),
        ).called(1);
        // Refresh was called — getLibrary called once for initial load, once for refresh.
        verify(() => service.getLibrary('profile-1')).called(2);
      });

      test('returns false when profile is null', () async {
        final container = makeContainer(profile: null);
        container.listen(songLibraryStateProvider, (_, _) {});

        final result = await container.read(songLibraryStateProvider.notifier).addSong(_searchResult);

        expect(result, isFalse);
        verifyNever(
          () => service.addSongToLibrary(
            profileId: any(named: 'profileId'),
            searchResult: any(named: 'searchResult'),
            currentLibrarySize: any(named: 'currentLibrarySize'),
          ),
        );
      });
    });

    group('removeSong', () {
      test('delegates to service and refreshes library', () async {
        when(() => service.getLibrary('profile-1')).thenAnswer(
          (_) async => [_performerSong1, _performerSong2],
        );
        when(
          () => service.removeSongFromLibrary(
            profileId: any(named: 'profileId'),
            songId: any(named: 'songId'),
          ),
        ).thenAnswer((_) async {});

        final container = makeContainer();
        container.listen(songLibraryStateProvider, (_, _) {});

        // Wait for initial load.
        await Future<void>.delayed(Duration.zero);

        await container.read(songLibraryStateProvider.notifier).removeSong('song-1');

        verify(
          () => service.removeSongFromLibrary(profileId: 'profile-1', songId: 'song-1'),
        ).called(1);
        // getLibrary called twice: initial load + refresh after remove.
        verify(() => service.getLibrary('profile-1')).called(2);
      });

      test('does nothing when profile is null', () async {
        final container = makeContainer(profile: null);
        container.listen(songLibraryStateProvider, (_, _) {});

        await container.read(songLibraryStateProvider.notifier).removeSong('song-1');

        verifyNever(
          () => service.removeSongFromLibrary(
            profileId: any(named: 'profileId'),
            songId: any(named: 'songId'),
          ),
        );
      });
    });

    group('reorder', () {
      test('optimistically updates state then refreshes', () async {
        when(() => service.getLibrary('profile-1')).thenAnswer(
          (_) async => [_performerSong1, _performerSong2],
        );
        when(() => service.reorderLibrary(any())).thenAnswer((_) async {});

        final container = makeContainer();
        final states = <AsyncValue<List<PerformerSong>>>[];
        container.listen(songLibraryStateProvider, (_, next) => states.add(next));

        // Wait for initial load.
        await Future<void>.delayed(Duration.zero);

        await container.read(songLibraryStateProvider.notifier).reorder(0, 1);

        // The optimistic update should have put song-2 before song-1.
        final optimisticState = states.firstWhere(
          (s) => s is AsyncData && s.value!.isNotEmpty && s.value!.first.songId == 'song-2',
          orElse: () => const AsyncData([]),
        );
        expect(optimisticState.value?.first.songId, 'song-2');
        expect(optimisticState.value?.last.songId, 'song-1');

        verify(() => service.reorderLibrary(any())).called(1);
      });

      test('rolls back to original list on failure', () async {
        when(() => service.getLibrary('profile-1')).thenAnswer(
          (_) async => [_performerSong1, _performerSong2],
        );
        when(() => service.reorderLibrary(any())).thenThrow(
          const SongLibraryException('Reorder failed'),
        );

        final container = makeContainer();
        container.listen(songLibraryStateProvider, (_, _) {});

        // Wait for initial load.
        await Future<void>.delayed(Duration.zero);

        await container.read(songLibraryStateProvider.notifier).reorder(0, 1);

        // After failure, state should be rolled back to the original list.
        final current = container.read(songLibraryStateProvider);
        expect(current.value?.first.songId, 'song-1');
        expect(current.value?.last.songId, 'song-2');
      });

      test('does nothing when state is loading (value is null)', () async {
        // Simulate a loading state by setting up a service that never completes.
        when(() => service.getLibrary('profile-1')).thenAnswer(
          (_) => Completer<List<PerformerSong>>().future,
        );

        final container = makeContainer();
        container.listen(songLibraryStateProvider, (_, _) {});

        // State is AsyncLoading, so value is null.
        expect(container.read(songLibraryStateProvider), isA<AsyncLoading<List<PerformerSong>>>());

        await container.read(songLibraryStateProvider.notifier).reorder(0, 1);

        verifyNever(() => service.reorderLibrary(any()));
      });
    });
  });
}
