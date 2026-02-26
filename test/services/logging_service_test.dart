import 'package:flutter_test/flutter_test.dart';
import 'package:logger/logger.dart';
import 'package:mocktail/mocktail.dart';
import 'package:song_requester/services/logging_service.dart';

// ---------------------------------------------------------------------------
// Mocks
// ---------------------------------------------------------------------------

class _MockLogger extends Mock implements Logger {}

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  late _MockLogger mockLogger;
  late List<({dynamic message, Object? error, StackTrace? stackTrace})> reporterCalls;
  late LoggingService service;

  setUp(() {
    mockLogger = _MockLogger();
    reporterCalls = [];
    service = LoggingService(
      mockLogger,
      errorReporter: (message, {error, stackTrace}) =>
          reporterCalls.add((message: message, error: error, stackTrace: stackTrace)),
    );
  });

  group('LoggingService', () {
    group('d/i/w — do NOT call ErrorReporter', () {
      test('d() delegates to logger and skips reporter', () {
        service.d('debug message');
        verify(() => mockLogger.d('debug message')).called(1);
        expect(reporterCalls, isEmpty);
      });

      test('i() delegates to logger and skips reporter', () {
        service.i('info message');
        verify(() => mockLogger.i('info message')).called(1);
        expect(reporterCalls, isEmpty);
      });

      test('w() delegates to logger and skips reporter', () {
        service.w('warning message');
        verify(() => mockLogger.w('warning message')).called(1);
        expect(reporterCalls, isEmpty);
      });
    });

    group('e/f — call both logger AND ErrorReporter', () {
      test('e() delegates to logger and calls reporter', () {
        final error = Exception('boom');
        final st = StackTrace.current;

        service.e('error message', error: error, stackTrace: st);

        verify(() => mockLogger.e('error message', error: error, stackTrace: st)).called(1);
        expect(reporterCalls, hasLength(1));
        expect(reporterCalls.first.message, 'error message');
        expect(reporterCalls.first.error, error);
        expect(reporterCalls.first.stackTrace, st);
      });

      test('f() delegates to logger and calls reporter', () {
        final error = Exception('fatal');
        final st = StackTrace.current;

        service.f('fatal message', error: error, stackTrace: st);

        verify(() => mockLogger.f('fatal message', error: error, stackTrace: st)).called(1);
        expect(reporterCalls, hasLength(1));
        expect(reporterCalls.first.message, 'fatal message');
        expect(reporterCalls.first.error, error);
        expect(reporterCalls.first.stackTrace, st);
      });
    });

    group('no-op reporter (default)', () {
      test('e() does not throw when no reporter is provided', () {
        final defaultService = LoggingService(mockLogger);
        expect(() => defaultService.e('error'), returnsNormally);
      });

      test('f() does not throw when no reporter is provided', () {
        final defaultService = LoggingService(mockLogger);
        expect(() => defaultService.f('fatal'), returnsNormally);
      });
    });
  });
}
