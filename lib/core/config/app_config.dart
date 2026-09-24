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
  static const String appName = "Yo'l-Yo'lakay Haydovchi";
  static const String appVersion = '1.0.0';
  static const int buildNumber = 1;

  /// Environment detection from compile-time flags (`--dart-define=ENV=dev`)
  static const String _envString =
      String.fromEnvironment('ENV', defaultValue: 'prod');

  static AppEnvironment get environment {
    return switch (_envString.toLowerCase()) {
      'dev' => AppEnvironment.dev,
      'staging' => AppEnvironment.staging,
      _ => AppEnvironment.prod,
    };
  }

  /// Zero-mock enforcement: Always connect to real backend
  static const bool isMockMode = false;

  /// API Base URLs
  static const String prodBaseUrl = ApiEndpoints.prodBaseUrl;
  static const String stagingBaseUrl =
      'https://staging-api.yol-yolakay.uz/api/v1';
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
      AppEnvironment.dev => 'ws://10.0.2.2:8000/ws',
      AppEnvironment.staging => 'wss://staging-api.yol-yolakay.uz/ws',
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
