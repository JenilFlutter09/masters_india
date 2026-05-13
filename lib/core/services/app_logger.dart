import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:logger/logger.dart';

class AppLogger {
  AppLogger._();

  static final Logger _logger = Logger(
    filter: _DebugOnlyFilter(),
    printer: PrettyPrinter(
      methodCount: 0,
      errorMethodCount: 8,
      lineLength: 100,
      colors: false,
      printEmojis: false,
      dateTimeFormat: DateTimeFormat.onlyTimeAndSinceStart,
    ),
  );

  static void debug(String message) => _logger.d(message);

  static void info(String message) => _logger.i(message);

  static void warning(String message) => _logger.w(message);

  static void error(String message, {Object? error, StackTrace? stackTrace}) {
    _logger.e(message, error: error, stackTrace: stackTrace);
  }

  static void apiRequest({
    required int requestId,
    required String method,
    required Uri url,
    required Map<String, String> headers,
    String? body,
  }) {
    info(
      [
        '[API][$requestId] REQUEST',
        '$method $url',
        'Headers: ${_prettyJson(headers)}',
        'Body: ${_prettyBody(body)}',
      ].join('\n'),
    );
  }

  static void apiResponse({
    required int requestId,
    required String method,
    required Uri url,
    required int statusCode,
    required Duration duration,
    required Map<String, String> headers,
    required String? body,
  }) {
    info(
      [
        '[API][$requestId] RESPONSE',
        '$method $url',
        'Status: $statusCode',
        'Duration: ${duration.inMilliseconds} ms',
        'Headers: ${_prettyJson(headers)}',
        'Body: ${_prettyBody(body)}',
      ].join('\n'),
    );
  }

  static void apiFailure({
    required int requestId,
    required String method,
    required Uri url,
    required Duration duration,
    required String message,
    Object? error,
    StackTrace? stackTrace,
  }) {
    AppLogger.error(
      [
        '[API][$requestId] FAILURE',
        '$method $url',
        'Duration: ${duration.inMilliseconds} ms',
        'Message: $message',
      ].join('\n'),
      error: error,
      stackTrace: stackTrace,
    );
  }

  static String prettyObject(Object? value) {
    if (value == null) {
      return '<null>';
    }
    if (value is String) {
      return _prettyBody(value);
    }
    try {
      return const JsonEncoder.withIndent('  ').convert(value);
    } catch (_) {
      return value.toString();
    }
  }

  static String _prettyBody(String? body) {
    if (body == null || body.isEmpty) {
      return '<empty>';
    }

    final trimmed = body.trim();
    try {
      final decoded = jsonDecode(trimmed);
      return const JsonEncoder.withIndent('  ').convert(decoded);
    } catch (_) {
      return trimmed;
    }
  }

  static String _prettyJson(Map<String, String> headers) {
    if (headers.isEmpty) {
      return '<empty>';
    }
    return const JsonEncoder.withIndent('  ').convert(headers);
  }
}

class _DebugOnlyFilter extends LogFilter {
  @override
  bool shouldLog(LogEvent event) => kDebugMode;
}
