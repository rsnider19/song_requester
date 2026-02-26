// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'counter_notifier.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(CounterStateNotifier)
final counterStateProvider = CounterStateNotifierProvider._();

final class CounterStateNotifierProvider
    extends $NotifierProvider<CounterStateNotifier, int> {
  CounterStateNotifierProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'counterStateProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$counterStateNotifierHash();

  @$internal
  @override
  CounterStateNotifier create() => CounterStateNotifier();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(int value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<int>(value),
    );
  }
}

String _$counterStateNotifierHash() =>
    r'07f2452539661d68c5f0a4f704c9e26b761fd34e';

abstract class _$CounterStateNotifier extends $Notifier<int> {
  int build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<int, int>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<int, int>,
              int,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
