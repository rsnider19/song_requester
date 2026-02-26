import 'package:flutter/foundation.dart';
import 'package:logger/logger.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'logging_service.g.dart';

// ---------------------------------------------------------------------------
// Error Reporter
// ---------------------------------------------------------------------------

/// Hook for forwarding errors to an external crash reporter (Sentry, Crashlytics, etc.).
///
/// Assign a custom implementation to [LoggingService] to capture
/// [LoggingService.e] and [LoggingService.f] calls.
// TODO(error-reporting): Replace the no-op default with a real implementation.
typedef ErrorReporter =
    void Function(
      dynamic message, {
      Object? error,
      StackTrace? stackTrace,
    });

void _noOpErrorReporter(dynamic _, {Object? error, StackTrace? stackTrace}) {}

// ---------------------------------------------------------------------------
// Logging Service
// ---------------------------------------------------------------------------

/// Application-level logging service.
///
/// Wraps [Logger] to provide:
/// - Flavor-based log levels: [Level.debug] in debug builds, [Level.info] in
///   profile builds, [Level.warning] in release builds.
/// - Structured [PrettyPrinter] output with consistent formatting.
/// - An [ErrorReporter] callback invoked for every [e] and [f] call —
///   plug in Sentry or Crashlytics without changing call sites.
class LoggingService {
  LoggingService(this._logger, {ErrorReporter? errorReporter}) : _errorReporter = errorReporter ?? _noOpErrorReporter;

  final Logger _logger;
  final ErrorReporter _errorReporter;

  /// Debug-level log. Omitted in profile and release builds.
  void d(dynamic message, {Object? error, StackTrace? stackTrace}) =>
      _logger.d(message, error: error, stackTrace: stackTrace);

  /// Info-level log. Omitted in release builds.
  void i(dynamic message, {Object? error, StackTrace? stackTrace}) =>
      _logger.i(message, error: error, stackTrace: stackTrace);

  /// Warning-level log. Always visible.
  void w(dynamic message, {Object? error, StackTrace? stackTrace}) =>
      _logger.w(message, error: error, stackTrace: stackTrace);

  /// Error-level log. Always visible. Also invokes the [ErrorReporter].
  void e(dynamic message, {Object? error, StackTrace? stackTrace}) {
    _logger.e(message, error: error, stackTrace: stackTrace);
    _errorReporter(message, error: error, stackTrace: stackTrace);
  }

  /// Fatal-level log. Always visible. Also invokes the [ErrorReporter].
  void f(dynamic message, {Object? error, StackTrace? stackTrace}) {
    _logger.f(message, error: error, stackTrace: stackTrace);
    _errorReporter(message, error: error, stackTrace: stackTrace);
  }
}

// ---------------------------------------------------------------------------
// Provider
// ---------------------------------------------------------------------------

@Riverpod(keepAlive: true)
LoggingService loggingService(Ref ref) {
  const level = kDebugMode
      ? Level.debug
      : kReleaseMode
      ? Level.warning
      : Level.info;
  final logger = Logger(level: level, printer: PrettyPrinter());
  return LoggingService(logger);
}
