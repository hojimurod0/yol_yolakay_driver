import 'dart:async';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../firebase_options.dart';
import '../di/injection.dart';
import '../router/driver_router.dart';
import '../utils/app_logger.dart';
import 'push_notification_service.dart';

/// Handles application bootstrap and deferred background initialization.
/// Keeps main.dart concise and minimizes startup latency.
class AppInitializer {
  AppInitializer._();

  /// Synchronous and critical initialization required before [runApp].
  /// Kept minimal so the first frame renders instantly without skipping frames.
  static Future<void> init() async {
    WidgetsFlutterBinding.ensureInitialized();

    // Setup global error handling early for Flutter & Platform
    _setupErrorHandling();

    // Configure dependency injection container
    await configureDependencies();

    // Hook reactive router listeners (session expiration, push notification deep links)
    setupRouterListeners(driverRouter);

    // Trigger non-critical services asynchronously in background
    unawaited(initBackgroundServices());
  }

  /// Sets up framework and platform error handlers.
  static void _setupErrorHandling() {
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
      return true;
    };
  }

  /// Deferred background tasks (System UI, Firebase, Push notifications, default roles).
  /// These run concurrently without delaying the initial Flutter frame render.
  static Future<void> initBackgroundServices() async {
    // 1. System UI overlays & device orientations
    try {
      SystemChrome.setSystemUIOverlayStyle(
        const SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.dark,
          systemNavigationBarColor: Colors.transparent,
          systemNavigationBarIconBrightness: Brightness.dark,
        ),
      );

      unawaited(
        SystemChrome.setPreferredOrientations([
          DeviceOrientation.portraitUp,
          DeviceOrientation.portraitDown,
        ]),
      );
    } catch (e) {
      AppLogger.error('SystemUI initialization error: $e',
          module: LogModule.system);
    }

    // 2. Default user role storage in SharedPreferences
    try {
      final sharedPreferences = sl<SharedPreferences>();
      unawaited(
        Future.wait([
          sharedPreferences.setString('user_role', 'driver'),
          sharedPreferences.setString('app_user_role', 'driver'),
          sharedPreferences.setBool('is_role_selected', true),
        ]),
      );
    } catch (e) {
      AppLogger.error('Role setup error: $e', module: LogModule.system);
    }

    // 3. Firebase & Push Notifications initialization
    try {
      if (Firebase.apps.isEmpty) {
        await Firebase.initializeApp(
          options: DefaultFirebaseOptions.currentPlatform,
        );
        AppLogger.info('Firebase initialized successfully',
            module: LogModule.system);
      }

      // Initialize Push Notifications once Firebase is confirmed
      await sl<PushNotificationService>().initialize();
    } catch (e) {
      AppLogger.info('Firebase/Push notification deferred initialization: $e',
          module: LogModule.system);
    }
  }
}
