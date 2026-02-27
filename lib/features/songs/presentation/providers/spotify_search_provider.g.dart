// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'spotify_search_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Debounced Spotify search provider. Auto-disposes when the search screen
/// is popped. Returns results after a 300ms debounce.

@ProviderFor(spotifySearch)
final spotifySearchProvider = SpotifySearchFamily._();

/// Debounced Spotify search provider. Auto-disposes when the search screen
/// is popped. Returns results after a 300ms debounce.

final class SpotifySearchProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<SpotifySearchResult>>,
          List<SpotifySearchResult>,
          FutureOr<List<SpotifySearchResult>>
        >
    with
        $FutureModifier<List<SpotifySearchResult>>,
        $FutureProvider<List<SpotifySearchResult>> {
  /// Debounced Spotify search provider. Auto-disposes when the search screen
  /// is popped. Returns results after a 300ms debounce.
  SpotifySearchProvider._({
    required SpotifySearchFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'spotifySearchProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$spotifySearchHash();

  @override
  String toString() {
    return r'spotifySearchProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<List<SpotifySearchResult>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<SpotifySearchResult>> create(Ref ref) {
    final argument = this.argument as String;
    return spotifySearch(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is SpotifySearchProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$spotifySearchHash() => r'e4a2b97a55981d5a5b4582ef4ef1031822848176';

/// Debounced Spotify search provider. Auto-disposes when the search screen
/// is popped. Returns results after a 300ms debounce.

final class SpotifySearchFamily extends $Family
    with
        $FunctionalFamilyOverride<FutureOr<List<SpotifySearchResult>>, String> {
  SpotifySearchFamily._()
    : super(
        retry: null,
        name: r'spotifySearchProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Debounced Spotify search provider. Auto-disposes when the search screen
  /// is popped. Returns results after a 300ms debounce.

  SpotifySearchProvider call(String query) =>
      SpotifySearchProvider._(argument: query, from: this);

  @override
  String toString() => r'spotifySearchProvider';
}
