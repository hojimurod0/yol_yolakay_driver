import 'dart:developer' as developer;
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';

/// Supported log severity levels
enum LogLevel { debug, info, warning, error }

/// Functional modules of the application for categorized filtering
enum LogModule {
  auth,
  navigation,
  api,
  state,
  taxi,
  profile,
  rides,
  booking,
  performance,
  system,
}

/// Centralized, production-safe application logger.
/// - Gated by [kReleaseMode]: in production, debug messages are suppressed.
/// - Automatically sanitizes and masks sensitive user credentials (passwords, tokens, phone numbers).
/// - Categorizes output by functional modules for rapid debugging.
class AppLogger {
  AppLogger._();

  /// Log a debug message (development only)
  static void debug(
    String message, {
    LogModule module = LogModule.system,
    Map<String, dynamic>? data,
  }) {
    _log(LogLevel.debug, message, module: module, data: data);
  }

  /// Log an informational message
  static void info(
    String message, {
    LogModule module = LogModule.system,
    Map<String, dynamic>? data,
  }) {
    _log(LogLevel.info, message, module: module, data: data);
  }

  /// Log a warning message
  static void warn(
    String message, {
    LogModule module = LogModule.system,
    Map<String, dynamic>? data,
  }) {
    _log(LogLevel.warning, message, module: module, data: data);
  }

  /// Alias for [warn]
  static void warning(
    String message, {
    LogModule module = LogModule.system,
    Map<String, dynamic>? data,
  }) =>
      warn(message, module: module, data: data);

  /// Log an error with stack trace (always logged, even in production)
  static void error(
    String message, {
    LogModule module = LogModule.system,
    dynamic error,
    StackTrace? stackTrace,
    Map<String, dynamic>? data,
  }) {
    _log(
      LogLevel.error,
      message,
      module: module,
      error: error,
      stackTrace: stackTrace,
      data: data,
    );
  }

  static void _log(
    LogLevel level,
    String message, {
    required LogModule module,
    dynamic error,
    StackTrace? stackTrace,
    Map<String, dynamic>? data,
  }) {
    // In release mode, suppress debug and info logs to safeguard memory and performance
    if (kReleaseMode && (level == LogLevel.debug || level == LogLevel.info)) {
      return;
    }

    final levelIcon = switch (level) {
      LogLevel.debug => '🔍 DEBUG',
      LogLevel.info => 'ℹ️ INFO',
      LogLevel.warning => '⚠️ WARN',
      LogLevel.error => '🛑 ERROR',
    };

    final moduleTag = module.name.toUpperCase();
    final sanitizedMessage = _sanitize(message);
    final buffer = StringBuffer('[$levelIcon][$moduleTag] $sanitizedMessage');

    if (data != null && data.isNotEmpty) {
      buffer.write(' | data: ${_sanitizeMap(data)}');
    }

    if (error != null) {
      buffer.write(' | error: $error');
    }

    developer.log(
      buffer.toString(),
      name: 'YolYolakay.$moduleTag',
      level: _toDeveloperLogLevel(level),
      error: error,
      stackTrace: stackTrace,
    );

    // In production, record non-fatal errors to Crashlytics if Firebase is active
    if (kReleaseMode && level == LogLevel.error && Firebase.apps.isNotEmpty) {
      try {
        FirebaseCrashlytics.instance.recordError(
          error ?? sanitizedMessage,
          stackTrace,
          reason: '[$moduleTag] $sanitizedMessage',
          fatal: false,
        );
      } catch (_) {
        // Crashlytics non-fatal reporting failed, ignore
      }
    }
  }

  static int _toDeveloperLogLevel(LogLevel level) {
    return switch (level) {
      LogLevel.debug => 500,
      LogLevel.info => 800,
      LogLevel.warning => 900,
      LogLevel.error => 1000,
    };
  }

  /// Patterns for sensitive credentials that must be redacted from logs
  static final RegExp _bearerPattern = RegExp(
    r'Bearer\s+[A-Za-z0-9\-._~+/]+=*',
    caseSensitive: false,
  );

  static final RegExp _sensitivePattern = RegExp(
    r'(token|access_token|refresh_token|password|secret|authorization|bearer|otp|cvv|cvc|card|pan|passport|license)\s*[:=]\s*([^\s,;]+)',
    caseSensitive: false,
  );

  /// Masks sensitive strings to prevent security leaks in device logs
  static String _sanitize(String input) {
    var sanitized = input.replaceAll(_bearerPattern, 'Bearer ***REDACTED***');
    sanitized = sanitized.replaceAllMapped(_sensitivePattern, (match) {
      final key = match.group(1);
      final value = match.group(2) ?? '';
      if (value.length <= 4) return '$key=****';
      return '$key=${value.substring(0, 2)}...${value.substring(value.length - 2)}';
    });
    return sanitized;
  }

  static Map<String, dynamic> _sanitizeMap(Map<String, dynamic> map) {
    final sanitized = <String, dynamic>{};
    for (final entry in map.entries) {
      final keyLower = entry.key.toLowerCase();
      if (keyLower.contains('token') ||
          keyLower.contains('password') ||
          keyLower.contains('secret') ||
          keyLower.contains('auth') ||
          keyLower.contains('otp') ||
          keyLower.contains('code') ||
          keyLower.contains('card') ||
          keyLower.contains('pan') ||
          keyLower.contains('cvv') ||
          keyLower.contains('passport') ||
          keyLower.contains('license')) {
        sanitized[entry.key] = '***REDACTED***';
      } else {
        sanitized[entry.key] = entry.value;
      }
    }
    return sanitized;
  }
}
