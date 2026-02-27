// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'song_library_state_notifier.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(SongLibraryStateNotifier)
final songLibraryStateProvider = SongLibraryStateNotifierProvider._();

final class SongLibraryStateNotifierProvider
    extends
        $NotifierProvider<
          SongLibraryStateNotifier,
          AsyncValue<List<PerformerSong>>
        > {
  SongLibraryStateNotifierProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'songLibraryStateProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$songLibraryStateNotifierHash();

  @$internal
  @override
  SongLibraryStateNotifier create() => SongLibraryStateNotifier();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AsyncValue<List<PerformerSong>> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AsyncValue<List<PerformerSong>>>(
        value,
      ),
    );
  }
}

String _$songLibraryStateNotifierHash() =>
    r'5962bfb0ea6769e8172d74c9184967775256b70f';

abstract class _$SongLibraryStateNotifier
    extends $Notifier<AsyncValue<List<PerformerSong>>> {
  AsyncValue<List<PerformerSong>> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref =
        this.ref
            as $Ref<
              AsyncValue<List<PerformerSong>>,
              AsyncValue<List<PerformerSong>>
            >;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<
                AsyncValue<List<PerformerSong>>,
                AsyncValue<List<PerformerSong>>
              >,
              AsyncValue<List<PerformerSong>>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
