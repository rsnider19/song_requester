import 'dart:async';

import 'package:flutter/material.dart' show CircularProgressIndicator;
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:song_requester/features/songs/domain/models/performer_song.dart';
import 'package:song_requester/features/songs/domain/models/song.dart';
import 'package:song_requester/features/songs/domain/models/spotify_search_result.dart';
import 'package:song_requester/features/songs/presentation/providers/song_library_state_notifier.dart';
import 'package:song_requester/features/songs/presentation/providers/spotify_search_provider.dart';
import 'package:song_requester/features/songs/presentation/screens/add_song_screen.dart';

import '../../../../helpers/helpers.dart';

// ---------------------------------------------------------------------------
// Fixtures
// ---------------------------------------------------------------------------

const _song1 = Song(
  songId: 'song-1',
  title: 'Bohemian Rhapsody',
  artist: 'Queen',
  spotifyTrackId: 'track-1',
);

const _performerSong1 = PerformerSong(
  performerSongId: 'ps-1',
  profileId: 'profile-1',
  songId: 'song-1',
  sortOrder: 0,
  song: _song1,
);

const _searchResult1 = SpotifySearchResult(
  spotifyTrackId: 'track-1',
  title: 'Bohemian Rhapsody',
  artist: 'Queen',
  artistId: 'artist-1',
  albumArtUrl: 'https://example.com/art1.jpg',
);

const _searchResult2 = SpotifySearchResult(
  spotifyTrackId: 'track-2',
  title: 'Hotel California',
  artist: 'Eagles',
  artistId: 'artist-2',
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
  group('AddSongScreen', () {
    testWidgets('shows search prompt when query is empty', (tester) async {
      await tester.pumpApp(
        const AddSongScreen(),
        overrides: [
          songLibraryStateProvider.overrideWith(
            () => _FakeSongLibraryStateNotifier(const AsyncData([])),
          ),
        ],
      );

      expect(find.text('Search for songs'), findsOneWidget);
      expect(find.text('Add Song'), findsOneWidget);
    });

    testWidgets('shows loading indicator when search is in progress', (tester) async {
      final completer = Completer<List<SpotifySearchResult>>();

      await tester.pumpApp(
        const AddSongScreen(),
        overrides: [
          songLibraryStateProvider.overrideWith(
            () => _FakeSongLibraryStateNotifier(const AsyncData([])),
          ),
          spotifySearchProvider.overrideWith(
            (ref, query) => completer.future,
          ),
        ],
      );

      // Enter a search query.
      await tester.enterText(find.byType(EditableText), 'test');
      await tester.pump();

      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      // Complete the future to avoid dangling state.
      addTearDown(() => completer.complete([]));
    });

    testWidgets('shows search results when search completes', (tester) async {
      await tester.pumpApp(
        const AddSongScreen(),
        overrides: [
          songLibraryStateProvider.overrideWith(
            () => _FakeSongLibraryStateNotifier(const AsyncData([])),
          ),
          spotifySearchProvider.overrideWith(
            (ref, query) async => [_searchResult1, _searchResult2],
          ),
        ],
      );

      // Enter a search query.
      await tester.enterText(find.byType(EditableText), 'test');
      await tester.pumpAndSettle();

      expect(find.text('Bohemian Rhapsody'), findsOneWidget);
      expect(find.text('Queen'), findsOneWidget);
      expect(find.text('Hotel California'), findsOneWidget);
      expect(find.text('Eagles'), findsOneWidget);
    });

    testWidgets('shows check icon for songs already in library', (tester) async {
      await tester.pumpApp(
        const AddSongScreen(),
        overrides: [
          songLibraryStateProvider.overrideWith(
            () => _FakeSongLibraryStateNotifier(
              const AsyncData([_performerSong1]),
            ),
          ),
          spotifySearchProvider.overrideWith(
            (ref, query) async => [_searchResult1, _searchResult2],
          ),
        ],
      );

      // Enter a search query.
      await tester.enterText(find.byType(EditableText), 'test');
      await tester.pumpAndSettle();

      // track-1 is in the library (via _performerSong1) so should show check icon.
      // track-2 is not in the library so should show plus icon.
      final checkIcons = find.byIcon(LucideIcons.check);
      final plusIcons = find.byIcon(LucideIcons.plus);

      expect(checkIcons, findsOneWidget);
      expect(plusIcons, findsOneWidget);
    });

    testWidgets('shows search failed message on error', (tester) async {
      await tester.pumpApp(
        const AddSongScreen(),
        overrides: [
          songLibraryStateProvider.overrideWith(
            () => _FakeSongLibraryStateNotifier(const AsyncData([])),
          ),
          spotifySearchProvider.overrideWith(
            (ref, query) async => throw Exception('Network error'),
          ),
        ],
      );

      // Enter a search query.
      await tester.enterText(find.byType(EditableText), 'test');
      await tester.pumpAndSettle();

      expect(find.text('Search failed'), findsOneWidget);
    });

    testWidgets('shows no songs found for empty results', (tester) async {
      await tester.pumpApp(
        const AddSongScreen(),
        overrides: [
          songLibraryStateProvider.overrideWith(
            () => _FakeSongLibraryStateNotifier(const AsyncData([])),
          ),
          spotifySearchProvider.overrideWith(
            (ref, query) async => [],
          ),
        ],
      );

      // Enter a search query.
      await tester.enterText(find.byType(EditableText), 'zzz');
      await tester.pumpAndSettle();

      expect(find.text('No songs found'), findsOneWidget);
    });
  });
}
