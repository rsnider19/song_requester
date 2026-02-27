import 'dart:async';

import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:song_requester/features/auth/presentation/providers/auth_state_notifier.dart';
import 'package:song_requester/features/songs/application/song_service.dart';
import 'package:song_requester/features/songs/domain/models/performer_song.dart';
import 'package:song_requester/features/songs/domain/models/spotify_search_result.dart';

part 'song_library_state_notifier.g.dart';

@Riverpod(keepAlive: true)
class SongLibraryStateNotifier extends _$SongLibraryStateNotifier {
  @override
  AsyncValue<List<PerformerSong>> build() {
    final profile = ref.watch(authStateProvider);
    if (profile == null) return const AsyncData([]);

    unawaited(_loadLibrary(profile.id));
    return const AsyncLoading();
  }

  Future<void> _loadLibrary(String profileId) async {
    try {
      final library = await ref.read(songServiceProvider).getLibrary(profileId);
      state = AsyncData(library);
    } on Exception catch (e, st) {
      state = AsyncError(e, st);
    }
  }

  /// Refreshes the library from the database.
  Future<void> refresh() async {
    final profile = ref.read(authStateProvider);
    if (profile == null) return;
    state = const AsyncLoading();
    await _loadLibrary(profile.id);
  }

  /// Adds a song from a Spotify search result and refreshes the library.
  ///
  /// Returns `true` if the soft limit was reached.
  Future<bool> addSong(SpotifySearchResult searchResult) async {
    final profile = ref.read(authStateProvider);
    if (profile == null) return false;

    final currentSize = state.value?.length ?? 0;
    final softLimitReached = await ref
        .read(songServiceProvider)
        .addSongToLibrary(
          profileId: profile.id,
          searchResult: searchResult,
          currentLibrarySize: currentSize,
        );

    await refresh();
    return softLimitReached;
  }

  /// Removes a song from the library and refreshes.
  Future<void> removeSong(String songId) async {
    final profile = ref.read(authStateProvider);
    if (profile == null) return;

    await ref
        .read(songServiceProvider)
        .removeSongFromLibrary(
          profileId: profile.id,
          songId: songId,
        );

    await refresh();
  }

  /// Reorders the library by moving the item at [oldIndex] to [newIndex].
  Future<void> reorder(int oldIndex, int newIndex) async {
    final current = state.value;
    if (current == null) return;

    final previousList = current;
    final list = List<PerformerSong>.of(current);
    final item = list.removeAt(oldIndex);
    list.insert(newIndex, item);

    // Optimistically update the UI.
    state = AsyncData(list);

    try {
      await ref.read(songServiceProvider).reorderLibrary(list);

      // Refresh to get the correct sort_order values from the DB.
      await refresh();
    } on Exception {
      // Rollback to the original list on failure.
      state = AsyncData(previousList);
    }
  }
}
