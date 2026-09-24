import 'dart:async';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'driver_app.dart';
import 'core/di/injection_container.dart';
import 'core/providers/app_provider_observer.dart';
import 'core/providers/core_providers.dart';
import 'core/utils/app_logger.dart';

import 'firebase_options.dart';

/// Dedicated entry point for the standalone Yo'l-Yo'lakay Driver application.
/// Run with: flutter run -t lib/main_driver.dart
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase safely if configuration is present
  try {
    if (Firebase.apps.isEmpty) {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
      AppLogger.info('Firebase initialized successfully',
          module: LogModule.system);
    }
  } catch (e) {
    AppLogger.info('Firebase initialization deferred: $e',
        module: LogModule.system);
  }

  // Catch uncaught framework errors gracefully
  FlutterError.onError = (details) {
    if (kReleaseMode && Firebase.apps.isNotEmpty) {
      FirebaseCrashlytics.instance.recordFlutterFatalError(details);
    }
    AppLogger.error(
      'DriverFlutterError: ${details.exceptionAsString()}',
      module: LogModule.system,
      error: details.exception,
      stackTrace: details.stack,
    );
    FlutterError.presentError(details);
  };

  // Catch uncaught asynchronous platform dispatch errors
  PlatformDispatcher.instance.onError = (error, stack) {
    if (kReleaseMode && Firebase.apps.isNotEmpty) {
      FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
    }
    AppLogger.error(
      'DriverPlatformError: $error',
      module: LogModule.system,
      error: error,
      stackTrace: stack,
    );
    return true; // handled, prevent crash/deadlock
  };

  // Initialize Clean Architecture Dependency Injection Container
  sl.init();

  // Initialize Push Notifications asynchronously
  unawaited(sl.pushNotificationService.initialize());

  // Portrait orientation configuration
  unawaited(
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]),
  );

  // System UI overlay configuration
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      systemNavigationBarColor: Colors.transparent,
      systemNavigationBarIconBrightness: Brightness.dark,
    ),
  );

  // Load persistent storage without stalling main thread
  final sharedPreferences = await SharedPreferences.getInstance();

  // Set default role asynchronously without blocking first frame render
  unawaited(
    Future.wait([
      sharedPreferences.setString('user_role', 'driver'),
      sharedPreferences.setString('app_user_role', 'driver'),
      sharedPreferences.setBool('is_role_selected', true),
    ]),
  );

  runApp(
    ProviderScope(
      observers: const [
        AppProviderObserver(),
      ],
      overrides: [
        sharedPreferencesProvider.overrideWithValue(sharedPreferences),
      ],
      child: const YolYolakayDriverApp(),
    ),
  );
}
