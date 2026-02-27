import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:song_requester/services/dot_env_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final class AppProviderObserver extends ProviderObserver {
  const AppProviderObserver();

  @override
  void didUpdateProvider(
    ProviderObserverContext context,
    Object? previousValue,
    Object? newValue,
  ) {
    debugPrint('[Provider] ${context.provider.name ?? context.provider.runtimeType}: $previousValue -> $newValue');
  }

  @override
  void providerDidFail(
    ProviderObserverContext context,
    Object error,
    StackTrace stackTrace,
  ) {
    debugPrint('[Provider:fail] ${context.provider.name ?? context.provider.runtimeType}: $error');
  }
}

Future<void> bootstrap(
  FutureOr<Widget> Function() builder, {
  required String envPath,
}) async {
  WidgetsFlutterBinding.ensureInitialized();

  FlutterError.onError = (details) {
    debugPrint('[FlutterError] ${details.exceptionAsString()}');
  };

  final env = await DotEnvService.load(envPath);
  debugPrint('[Bootstrap] Supabase URL: ${env.supabaseUrl}');

  await Supabase.initialize(
    url: env.supabaseUrl,
    anonKey: env.supabaseAnonKey,
  );

  // Ensure every user has a persistent identity from first open.
  // signInAnonymously is a no-op if a session already exists.
  final client = Supabase.instance.client;
  debugPrint('[Bootstrap] currentUser before sign-in: ${client.auth.currentUser?.id}');

  if (client.auth.currentUser == null) {
    try {
      debugPrint('[Bootstrap] Attempting anonymous sign-in...');
      await client.auth.signInAnonymously();
      debugPrint('[Bootstrap] Anonymous sign-in succeeded. userId=${client.auth.currentUser?.id}');
    } on Exception catch (e, st) {
      debugPrint('[Bootstrap] Anonymous sign-in FAILED: $e\n$st');
    }
  } else {
    debugPrint('[Bootstrap] Existing session found, skipping sign-in.');
  }

  debugPrint('[Bootstrap] currentUser after sign-in: ${client.auth.currentUser?.id}');

  runApp(
    ProviderScope(
      observers: const [AppProviderObserver()],
      child: await builder(),
    ),
  );
}
