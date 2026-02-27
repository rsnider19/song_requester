// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'song_service.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(songService)
final songServiceProvider = SongServiceProvider._();

final class SongServiceProvider
    extends $FunctionalProvider<SongService, SongService, SongService>
    with $Provider<SongService> {
  SongServiceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'songServiceProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$songServiceHash();

  @$internal
  @override
  $ProviderElement<SongService> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  SongService create(Ref ref) {
    return songService(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(SongService value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<SongService>(value),
    );
  }
}

String _$songServiceHash() => r'f7e075c78a3016498b7ef47549e11a34947572e1';
