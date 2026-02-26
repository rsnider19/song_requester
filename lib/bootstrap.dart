import 'dart:async';
import 'dart:developer';

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
    log('didUpdateProvider(${context.provider.name ?? context.provider.runtimeType}, $previousValue -> $newValue)');
  }

  @override
  void providerDidFail(
    ProviderObserverContext context,
    Object error,
    StackTrace stackTrace,
  ) {
    log('providerDidFail(${context.provider.name ?? context.provider.runtimeType}, $error, $stackTrace)');
  }
}

Future<void> bootstrap(
  FutureOr<Widget> Function() builder, {
  required String envPath,
}) async {
  WidgetsFlutterBinding.ensureInitialized();

  FlutterError.onError = (details) {
    log(details.exceptionAsString(), stackTrace: details.stack);
  };

  final env = await DotEnvService.load(envPath);

  await Supabase.initialize(
    url: env.supabaseUrl,
    anonKey: env.supabaseAnonKey,
  );

  // Ensure every user has a persistent identity from first open.
  // signInAnonymously is a no-op if a session already exists.
  final client = Supabase.instance.client;
  if (client.auth.currentUser == null) {
    try {
      await client.auth.signInAnonymously();
    } on Exception catch (e, st) {
      log('Anonymous sign-in failed — app will continue without a session', error: e, stackTrace: st);
    }
  }

  runApp(
    ProviderScope(
      observers: const [AppProviderObserver()],
      child: await builder(),
    ),
  );
}
