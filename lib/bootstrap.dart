import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logger/logger.dart';
import 'package:song_requester/services/dot_env_service.dart';
import 'package:song_requester/services/logging_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final class AppProviderObserver extends ProviderObserver {
  const AppProviderObserver(this._logger);

  final LoggingService _logger;

  @override
  void didUpdateProvider(
    ProviderObserverContext context,
    Object? previousValue,
    Object? newValue,
  ) {
    final name = context.provider.name ?? context.provider.runtimeType.toString();
    _logger.d('[Provider] $name\n  prev: ${_formatValue(previousValue)}\n  next: ${_formatValue(newValue)}');
  }

  /// Formats a provider value for readability.
  ///
  /// Objects matching `ClassName(field: value, ...)` are expanded to one field
  /// per line. Primitives and nulls are returned as-is.
  static String _formatValue(Object? value) {
    if (value == null) return 'null';
    final str = value.toString();
    final match = RegExp(r'^([A-Z]\w*)\((.+)\)$', dotAll: true).firstMatch(str);
    if (match == null) return str;
    final className = match.group(1)!;
    final body = match.group(2)!;
    // Split at commas followed by whitespace and a named field (word:),
    // to avoid splitting inside nested values like lists or nested objects.
    final fields = body.split(RegExp(r',\s+(?=\w+:)'));
    if (fields.length <= 1) return str;
    return '$className(\n${fields.map((f) => '    $f').join(',\n')}\n  )';
  }

  @override
  void providerDidFail(
    ProviderObserverContext context,
    Object error,
    StackTrace stackTrace,
  ) {
    _logger.e(
      '[Provider:fail] ${context.provider.name ?? context.provider.runtimeType}',
      error: error,
      stackTrace: stackTrace,
    );
  }
}

Future<void> bootstrap(
  FutureOr<Widget> Function() builder, {
  required String envPath,
}) async {
  WidgetsFlutterBinding.ensureInitialized();

  const level = kDebugMode
      ? Level.debug
      : kReleaseMode
      ? Level.warning
      : Level.info;
  final logger = LoggingService(Logger(level: level, printer: PrettyPrinter(methodCount: 0)));

  FlutterError.onError = (details) {
    logger.e('[FlutterError] ${details.exceptionAsString()}', stackTrace: details.stack);
  };

  final env = await DotEnvService.load(envPath);
  logger.d('[Bootstrap] Supabase URL: ${env.supabaseUrl}');

  await Supabase.initialize(
    url: env.supabaseUrl,
    anonKey: env.supabaseAnonKey,
  );

  final client = Supabase.instance.client;
  logger.d('[Bootstrap] currentUser before sign-in: ${client.auth.currentUser?.id}');

  if (client.auth.currentUser == null) {
    try {
      logger.i('[Bootstrap] Attempting anonymous sign-in...');
      await client.auth.signInAnonymously();
      logger.i('[Bootstrap] Anonymous sign-in succeeded. userId=${client.auth.currentUser?.id}');
    } on Exception catch (e, st) {
      logger.e('[Bootstrap] Anonymous sign-in FAILED', error: e, stackTrace: st);
    }
  } else {
    logger.d('[Bootstrap] Existing session found, skipping sign-in.');
  }

  logger.d('[Bootstrap] currentUser after sign-in: ${client.auth.currentUser?.id}');

  runApp(
    ProviderScope(
      observers: [AppProviderObserver(logger)],
      child: await builder(),
    ),
  );
}
