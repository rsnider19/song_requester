import 'dart:async';

import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:song_requester/features/songs/application/song_service.dart';
import 'package:song_requester/features/songs/domain/models/spotify_search_result.dart';

part 'spotify_search_provider.g.dart';

/// Debounced Spotify search provider. Auto-disposes when the search screen
/// is popped. Returns results after a 300ms debounce.
@riverpod
Future<List<SpotifySearchResult>> spotifySearch(Ref ref, String query) async {
  // Cancel pending searches when the query changes or the provider is disposed.
  final completer = Completer<void>();
  ref.onDispose(completer.complete);

  // 300ms debounce.
  await Future.any([
    Future<void>.delayed(const Duration(milliseconds: 300)),
    completer.future,
  ]);

  // If disposed during the debounce, return empty.
  if (completer.isCompleted) return [];

  // Keep the provider alive while the screen is active (cache results).
  ref.keepAlive();

  return ref.read(songServiceProvider).searchSpotify(query);
}
