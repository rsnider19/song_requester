import 'package:flutter/material.dart' show CircularProgressIndicator;
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:song_requester/features/songs/domain/models/performer_song.dart';
import 'package:song_requester/features/songs/domain/models/song.dart';
import 'package:song_requester/features/songs/presentation/providers/song_library_state_notifier.dart';
import 'package:song_requester/features/songs/presentation/screens/songs_screen.dart';

import '../../../../helpers/helpers.dart';

// ---------------------------------------------------------------------------
// Fixtures
// ---------------------------------------------------------------------------

const _song1 = Song(
  songId: 'song-1',
  title: 'Bohemian Rhapsody',
  artist: 'Queen',
  spotifyTrackId: 'track-1',
  albumArtUrl: 'https://example.com/art1.jpg',
);

const _song2 = Song(
  songId: 'song-2',
  title: 'Hotel California',
  artist: 'Eagles',
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

// ---------------------------------------------------------------------------
// Fake notifier
// ---------------------------------------------------------------------------

class _FakeSongLibraryStateNotifier extends SongLibraryStateNotifier {
  _FakeSongLibraryStateNotifier(this._state);
  final AsyncValue<List<PerformerSong>> _state;

  @override
  AsyncValue<List<PerformerSong>> build() => _state;

  @override
  Future<void> refresh() async {}

  @override
  Future<bool> addSong(dynamic searchResult) async => false;

  @override
  Future<void> removeSong(String songId) async {}

  @override
  Future<void> reorder(int oldIndex, int newIndex) async {}
}

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  group('SongsScreen', () {
    testWidgets('shows loading indicator while loading', (tester) async {
      await tester.pumpApp(
        const SongsScreen(),
        overrides: [
          songLibraryStateProvider.overrideWith(
            () => _FakeSongLibraryStateNotifier(const AsyncLoading()),
          ),
        ],
      );

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('shows error view with retry on error', (tester) async {
      await tester.pumpApp(
        const SongsScreen(),
        overrides: [
          songLibraryStateProvider.overrideWith(
            () => _FakeSongLibraryStateNotifier(
              AsyncError(Exception('Load failed'), StackTrace.current),
            ),
          ),
        ],
      );

      expect(find.text('Something went wrong'), findsOneWidget);
      expect(find.text('Retry'), findsOneWidget);
    });

    testWidgets('shows empty view when library is empty', (tester) async {
      await tester.pumpApp(
        const SongsScreen(),
        overrides: [
          songLibraryStateProvider.overrideWith(
            () => _FakeSongLibraryStateNotifier(const AsyncData([])),
          ),
        ],
      );

      expect(find.text('No songs yet'), findsOneWidget);
      expect(find.text('Search Spotify to add songs to your library.'), findsOneWidget);
    });

    testWidgets('shows song list when library has songs', (tester) async {
      await tester.pumpApp(
        const SongsScreen(),
        overrides: [
          songLibraryStateProvider.overrideWith(
            () => _FakeSongLibraryStateNotifier(
              const AsyncData([_performerSong1, _performerSong2]),
            ),
          ),
        ],
      );

      expect(find.text('Bohemian Rhapsody'), findsOneWidget);
      expect(find.text('Queen'), findsOneWidget);
      expect(find.text('Hotel California'), findsOneWidget);
      expect(find.text('Eagles'), findsOneWidget);
    });

    testWidgets('shows song count', (tester) async {
      await tester.pumpApp(
        const SongsScreen(),
        overrides: [
          songLibraryStateProvider.overrideWith(
            () => _FakeSongLibraryStateNotifier(
              const AsyncData([_performerSong1, _performerSong2]),
            ),
          ),
        ],
      );

      expect(find.text('2 songs'), findsOneWidget);
    });

    testWidgets('shows singular count for one song', (tester) async {
      await tester.pumpApp(
        const SongsScreen(),
        overrides: [
          songLibraryStateProvider.overrideWith(
            () => _FakeSongLibraryStateNotifier(
              const AsyncData([_performerSong1]),
            ),
          ),
        ],
      );

      expect(find.text('1 song'), findsOneWidget);
    });

    testWidgets('shows Edit button when library is populated', (tester) async {
      await tester.pumpApp(
        const SongsScreen(),
        overrides: [
          songLibraryStateProvider.overrideWith(
            () => _FakeSongLibraryStateNotifier(
              const AsyncData([_performerSong1]),
            ),
          ),
        ],
      );

      expect(find.text('Edit'), findsOneWidget);
    });

    testWidgets('hides Edit button when library is empty', (tester) async {
      await tester.pumpApp(
        const SongsScreen(),
        overrides: [
          songLibraryStateProvider.overrideWith(
            () => _FakeSongLibraryStateNotifier(const AsyncData([])),
          ),
        ],
      );

      expect(find.text('Edit'), findsNothing);
    });

    testWidgets('toggles to Done when Edit is tapped', (tester) async {
      await tester.pumpApp(
        const SongsScreen(),
        overrides: [
          songLibraryStateProvider.overrideWith(
            () => _FakeSongLibraryStateNotifier(
              const AsyncData([_performerSong1]),
            ),
          ),
        ],
      );

      await tester.tap(find.text('Edit'));
      await tester.pump();

      expect(find.text('Done'), findsOneWidget);
      expect(find.text('Edit'), findsNothing);
    });

    testWidgets('shows Add Song button in normal mode', (tester) async {
      await tester.pumpApp(
        const SongsScreen(),
        overrides: [
          songLibraryStateProvider.overrideWith(
            () => _FakeSongLibraryStateNotifier(
              const AsyncData([_performerSong1]),
            ),
          ),
        ],
      );

      expect(find.text('Add Song'), findsOneWidget);
    });

    testWidgets('hides Add Song button in edit mode', (tester) async {
      await tester.pumpApp(
        const SongsScreen(),
        overrides: [
          songLibraryStateProvider.overrideWith(
            () => _FakeSongLibraryStateNotifier(
              const AsyncData([_performerSong1]),
            ),
          ),
        ],
      );

      await tester.tap(find.text('Edit'));
      await tester.pump();

      expect(find.text('Add Song'), findsNothing);
    });

    testWidgets('filter input filters displayed songs', (tester) async {
      await tester.pumpApp(
        const SongsScreen(),
        overrides: [
          songLibraryStateProvider.overrideWith(
            () => _FakeSongLibraryStateNotifier(
              const AsyncData([_performerSong1, _performerSong2]),
            ),
          ),
        ],
      );

      // Both songs visible initially.
      expect(find.text('Bohemian Rhapsody'), findsOneWidget);
      expect(find.text('Hotel California'), findsOneWidget);

      // Type a filter query.
      await tester.enterText(find.byType(EditableText), 'bohemian');
      await tester.pump();

      // Only matching song is visible.
      expect(find.text('Bohemian Rhapsody'), findsOneWidget);
      expect(find.text('Hotel California'), findsNothing);
    });
  });
}
