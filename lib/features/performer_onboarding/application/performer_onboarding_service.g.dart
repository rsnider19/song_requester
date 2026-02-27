// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'performer_onboarding_service.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(performerOnboardingService)
final performerOnboardingServiceProvider =
    PerformerOnboardingServiceProvider._();

final class PerformerOnboardingServiceProvider
    extends
        $FunctionalProvider<
          PerformerOnboardingService,
          PerformerOnboardingService,
          PerformerOnboardingService
        >
    with $Provider<PerformerOnboardingService> {
  PerformerOnboardingServiceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'performerOnboardingServiceProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$performerOnboardingServiceHash();

  @$internal
  @override
  $ProviderElement<PerformerOnboardingService> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  PerformerOnboardingService create(Ref ref) {
    return performerOnboardingService(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(PerformerOnboardingService value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<PerformerOnboardingService>(value),
    );
  }
}

String _$performerOnboardingServiceHash() =>
    r'6cbdb2742c3446319809e1efea68b477965f25bf';
