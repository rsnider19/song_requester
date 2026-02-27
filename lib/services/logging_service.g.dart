// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'logging_service.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(loggingService)
final loggingServiceProvider = LoggingServiceProvider._();

final class LoggingServiceProvider
    extends $FunctionalProvider<LoggingService, LoggingService, LoggingService>
    with $Provider<LoggingService> {
  LoggingServiceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'loggingServiceProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$loggingServiceHash();

  @$internal
  @override
  $ProviderElement<LoggingService> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  LoggingService create(Ref ref) {
    return loggingService(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(LoggingService value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<LoggingService>(value),
    );
  }
}

String _$loggingServiceHash() => r'3adb8586ec3e3a50b417154b345f5cc0fce8f8d9';
