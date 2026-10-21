import 'package:flutter/foundation.dart';
import '../constants/api_endpoints.dart';

enum AppEnvironment {
  dev,
  staging,
  prod,
}

/// Centralized, environment-aware application configuration.
abstract class AppConfig {
  /// App metadata
  static const String appName = "Yol-Yolakay";
  static const String appVersion = '1.0.0';
  static const int buildNumber = 1;

  /// Environment detection from compile-time flags (`--dart-define=ENV=dev`)
  static const String _envString =
      String.fromEnvironment('ENV', defaultValue: 'dev');

  static AppEnvironment get environment {
    return switch (_envString.toLowerCase()) {
      'staging' => AppEnvironment.staging,
      'prod' => AppEnvironment.prod,
      _ => AppEnvironment.dev,
    };
  }

  /// Zero-mock enforcement: Always connect to real backend
  static const bool isMockMode = false;

  /// Server metadata
  static const String serverUrl = ApiEndpoints.serverUrl;
  static const String swaggerUrl = ApiEndpoints.swaggerUrl;

  /// API Base URLs
  static const String prodBaseUrl = ApiEndpoints.prodBaseUrl;
  static const String stagingBaseUrl = ApiEndpoints.devBaseUrl;
  static const String devBaseUrl = ApiEndpoints.devBaseUrl;

  /// Active Base URL according to environment
  static String get activeBaseUrl {
    return switch (environment) {
      AppEnvironment.dev => devBaseUrl,
      AppEnvironment.staging => stagingBaseUrl,
      AppEnvironment.prod => prodBaseUrl,
    };
  }

  /// Active WebSocket URL according to environment
  static String get activeWebSocketUrl {
    return switch (environment) {
      AppEnvironment.dev => ApiEndpoints.webSocketUrl,
      AppEnvironment.staging => ApiEndpoints.webSocketUrl,
      AppEnvironment.prod => ApiEndpoints.webSocketUrl,
    };
  }

  /// Network Timeouts (ms)
  static const int connectTimeout = 15000;
  static const int receiveTimeout = 15000;
  static const int sendTimeout = 15000;

  /// Logging configuration
  static bool get enableVerboseLogging =>
      !kReleaseMode || environment == AppEnvironment.dev;

  /// Legal Document URLs (External configuration required in production)
  static const String privacyPolicyUrl = String.fromEnvironment(
    'PRIVACY_POLICY_URL',
    defaultValue: 'https://yol-yolakay.uz/privacy',
  );

  static const String termsOfServiceUrl = String.fromEnvironment(
    'TERMS_OF_SERVICE_URL',
    defaultValue: 'https://yol-yolakay.uz/terms',
  );
}
