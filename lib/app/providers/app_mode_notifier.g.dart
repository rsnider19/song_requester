// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_mode_notifier.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Tracks the active app mode (Audience or Performer).
///
/// Defaults to [AppMode.performer] on cold start if the user has already
/// opted in as a performer; otherwise defaults to [AppMode.audience].
/// State is in-memory — resets correctly on each cold start from auth state.

@ProviderFor(AppModeNotifier)
final appModeProvider = AppModeNotifierProvider._();

/// Tracks the active app mode (Audience or Performer).
///
/// Defaults to [AppMode.performer] on cold start if the user has already
/// opted in as a performer; otherwise defaults to [AppMode.audience].
/// State is in-memory — resets correctly on each cold start from auth state.
final class AppModeNotifierProvider
    extends $NotifierProvider<AppModeNotifier, AppMode> {
  /// Tracks the active app mode (Audience or Performer).
  ///
  /// Defaults to [AppMode.performer] on cold start if the user has already
  /// opted in as a performer; otherwise defaults to [AppMode.audience].
  /// State is in-memory — resets correctly on each cold start from auth state.
  AppModeNotifierProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'appModeProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$appModeNotifierHash();

  @$internal
  @override
  AppModeNotifier create() => AppModeNotifier();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AppMode value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AppMode>(value),
    );
  }
}

String _$appModeNotifierHash() => r'792dd9b3eaf576a73caf58a810d0d29d24516bc0';

/// Tracks the active app mode (Audience or Performer).
///
/// Defaults to [AppMode.performer] on cold start if the user has already
/// opted in as a performer; otherwise defaults to [AppMode.audience].
/// State is in-memory — resets correctly on each cold start from auth state.

abstract class _$AppModeNotifier extends $Notifier<AppMode> {
  AppMode build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<AppMode, AppMode>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AppMode, AppMode>,
              AppMode,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
