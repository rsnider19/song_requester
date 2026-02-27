// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'performer_onboarding_state_notifier.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(PerformerOnboardingStateNotifier)
final performerOnboardingStateProvider =
    PerformerOnboardingStateNotifierProvider._();

final class PerformerOnboardingStateNotifierProvider
    extends
        $NotifierProvider<
          PerformerOnboardingStateNotifier,
          PerformerOnboardingState
        > {
  PerformerOnboardingStateNotifierProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'performerOnboardingStateProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$performerOnboardingStateNotifierHash();

  @$internal
  @override
  PerformerOnboardingStateNotifier create() =>
      PerformerOnboardingStateNotifier();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(PerformerOnboardingState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<PerformerOnboardingState>(value),
    );
  }
}

String _$performerOnboardingStateNotifierHash() =>
    r'7a99349b5f07e0e9401aae22e4f4bcf07892b148';

abstract class _$PerformerOnboardingStateNotifier
    extends $Notifier<PerformerOnboardingState> {
  PerformerOnboardingState build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref =
        this.ref as $Ref<PerformerOnboardingState, PerformerOnboardingState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<PerformerOnboardingState, PerformerOnboardingState>,
              PerformerOnboardingState,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
