import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logger/logger.dart';
import 'package:song_requester/features/auth/domain/models/user_profile.dart';
import 'package:song_requester/features/auth/presentation/providers/auth_state_notifier.dart';
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
    _logger.d('[Provider] $name\n  prev: ${_formatLine(previousValue)}\n  next: ${_formatLine(newValue)}');
  }

  /// Formats a provider value for readability.
  ///
  /// Objects matching `ClassName(...)`, `[...]`, or `{...}` are expanded
  /// with proper nesting support. Primitives and nulls are returned as-is.
  static String _formatLine(Object? value, [int depth = 1]) {
    if (value == null) return 'null';
    final str = value.toString().trim();

    String? prefix;
    String? suffix;
    String content;

    final classMatch = RegExp(r'^([A-Z][\w<> ,.]*)\((.*)\)$', dotAll: true).firstMatch(str);
    if (classMatch != null) {
      prefix = '${classMatch.group(1)}(';
      suffix = ')';
      content = classMatch.group(2)!;
    } else if (str.startsWith('[') && str.endsWith(']')) {
      prefix = '[';
      suffix = ']';
      content = str.substring(1, str.length - 1);
    } else if (str.startsWith('{') && str.endsWith('}')) {
      prefix = '{';
      suffix = '}';
      content = str.substring(1, str.length - 1);
    } else {
      return str;
    }

    if (content.isEmpty) return '$prefix$suffix';

    // Split content into top-level items, respecting nested boundaries
    final items = <String>[];
    var current = StringBuffer();
    var nestingDepth = 0;
    for (var i = 0; i < content.length; i++) {
      final char = content[i];
      if (char == '(' || char == '[' || char == '{') nestingDepth++;
      if (char == ')' || char == ']' || char == '}') nestingDepth--;

      if (nestingDepth == 0 && char == ',') {
        items.add(current.toString().trim());
        current = StringBuffer();
        while (i + 1 < content.length && content[i + 1] == ' ') {
          i++;
        }
      } else {
        current.write(char);
      }
    }
    if (current.isNotEmpty) items.add(current.toString().trim());

    if (items.isEmpty) return '$prefix$suffix';

    // Heuristic: don't expand if it's a single simple item
    if (items.length <= 1 && !items.any((item) => item.contains('(') || item.contains('[') || item.contains('{'))) {
      return '$prefix${items.join(', ')}$suffix';
    }

    final indent = ' ' * ((depth + 1) * 2);
    final backIndent = ' ' * (depth * 2);

    final formattedItems = items
        .map((item) {
          // Handle key: value pairs in classes or maps
          final colonIndex = item.indexOf(': ');
          if (colonIndex != -1) {
            // Ensure the colon is at the top level of this item
            var b = 0;
            for (var j = 0; j < colonIndex; j++) {
              if ('([{'.contains(item[j])) b++;
              if (')]}'.contains(item[j])) b--;
            }
            if (b == 0) {
              final key = item.substring(0, colonIndex);
              final val = item.substring(colonIndex + 2);
              return '$indent$key: ${_formatLine(val, depth + 1)}';
            }
          }
          return '$indent${_formatLine(item, depth + 1)}';
        })
        .join(',\n');

    return '$prefix\n$formattedItems\n$backIndent$suffix';
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
  final logger = LoggingService(Logger(level: level, printer: PrettyPrinter(methodCount: 0, colors: false)));

  FlutterError.onError = (details) {
    logger.e('[FlutterError] ${details.exceptionAsString()}', stackTrace: details.stack);
  };

  final env = await DotEnvService.load(envPath);
  logger.d('[Bootstrap] Supabase URL: ${env.supabaseUrl}');

  await Supabase.initialize(
    url: env.supabaseUrl,
    anonKey: env.supabaseAnonKey,
  );

  final currentUser = Supabase.instance.client.auth.currentUser;
  logger.d('[Bootstrap] currentUser: ${currentUser?.id}');

  // Pre-load the profile so AppModeNotifier sees the correct isPerformer value
  // on the very first frame. Without this, AuthStateNotifier seeds with
  // isPerformer: false, causing a flicker from audience → performer on cold
  // start for users who have already opted in as a performer.
  UserProfile? initialProfile;
  if (currentUser != null) {
    try {
      final row = await Supabase.instance.client
          .from('profile')
          .select('profile_id, email, is_performer')
          .eq('profile_id', currentUser.id)
          .single();
      initialProfile = UserProfile(
        id: row['profile_id'] as String,
        email: row['email'] as String?,
        isAnonymous: currentUser.isAnonymous,
        isPerformer: row['is_performer'] as bool,
      );
      logger.d('[Bootstrap] profile loaded: isPerformer=${initialProfile.isPerformer}');
    } on Exception catch (e, st) {
      logger.w('[Bootstrap] Could not pre-load profile; mode may flicker on first frame', error: e, stackTrace: st);
    }
  }

  runApp(
    ProviderScope(
      overrides: [
        if (initialProfile != null) authStateProvider.overrideWith(() => AuthStateNotifier(seed: initialProfile)),
      ],
      observers: [AppProviderObserver(logger)],
      child: await builder(),
    ),
  );
}
