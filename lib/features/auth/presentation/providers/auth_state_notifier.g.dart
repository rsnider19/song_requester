// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'auth_state_notifier.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Exposes the current [UserProfile?].
/// - `null`  → no session (should not happen in normal use; bootstrap creates anonymous session)
/// - non-null with [UserProfile.isAnonymous] == true → guest
/// - non-null with [UserProfile.isAnonymous] == false → signed-in user

@ProviderFor(AuthStateNotifier)
final authStateProvider = AuthStateNotifierProvider._();

/// Exposes the current [UserProfile?].
/// - `null`  → no session (should not happen in normal use; bootstrap creates anonymous session)
/// - non-null with [UserProfile.isAnonymous] == true → guest
/// - non-null with [UserProfile.isAnonymous] == false → signed-in user
final class AuthStateNotifierProvider
    extends $NotifierProvider<AuthStateNotifier, UserProfile?> {
  /// Exposes the current [UserProfile?].
  /// - `null`  → no session (should not happen in normal use; bootstrap creates anonymous session)
  /// - non-null with [UserProfile.isAnonymous] == true → guest
  /// - non-null with [UserProfile.isAnonymous] == false → signed-in user
  AuthStateNotifierProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'authStateProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$authStateNotifierHash();

  @$internal
  @override
  AuthStateNotifier create() => AuthStateNotifier();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(UserProfile? value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<UserProfile?>(value),
    );
  }
}

String _$authStateNotifierHash() => r'352cda8b554129ded880b35dce72b943a2d475f6';

/// Exposes the current [UserProfile?].
/// - `null`  → no session (should not happen in normal use; bootstrap creates anonymous session)
/// - non-null with [UserProfile.isAnonymous] == true → guest
/// - non-null with [UserProfile.isAnonymous] == false → signed-in user

abstract class _$AuthStateNotifier extends $Notifier<UserProfile?> {
  UserProfile? build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<UserProfile?, UserProfile?>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<UserProfile?, UserProfile?>,
              UserProfile?,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
