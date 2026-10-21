import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/domain/entities/driver_user_entity.dart';
import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/auth/presentation/pages/otp_page.dart';
import '../../features/auth/presentation/pages/phone_page.dart';
import '../../features/auth/presentation/pages/register_page.dart';
import '../../features/auth/presentation/pages/set_password_page.dart';
import '../../features/driver/presentation/pages/driver_main_shell_page.dart';
import '../../features/driver/presentation/pages/driver_splash_page.dart';
import '../../features/home/presentation/pages/city_picker_page.dart';
import '../../features/home/presentation/pages/driver_home_page.dart';
import '../../features/intercity_rides/domain/entities/intercity_ride_entity.dart';
import '../../features/intercity_rides/presentation/pages/create_driver_trip_page.dart';
import '../../features/intercity_rides/presentation/pages/driver_trip_details_page.dart';
import '../../features/intercity_rides/presentation/pages/driver_trips_page.dart';
import '../../features/notifications/presentation/pages/notifications_page.dart';
import '../../features/onboarding/presentation/pages/onboarding_page.dart';
import '../../features/profile/presentation/pages/driver_profile_page.dart';
import '../../features/reviews/presentation/pages/driver_reviews_page.dart';
import '../../features/support/presentation/pages/support_page.dart';
import '../../features/taxi_radar/presentation/pages/driver_radar_page.dart';
import '../../features/verification/presentation/pages/driver_verification_page.dart';
import '../../features/wallet/presentation/pages/driver_wallet_page.dart';

import '../di/injection.dart';
import '../services/push_notification_service.dart';
import '../services/session_manager.dart';
import '../widgets/smooth_tab_branch_container.dart';

final driverRootNavigatorKey =
    GlobalKey<NavigatorState>(debugLabel: 'driverRoot');
final _driverShellNavigatorHome =
    GlobalKey<NavigatorState>(debugLabel: 'driverShellHome');
final _driverShellNavigatorTrips =
    GlobalKey<NavigatorState>(debugLabel: 'driverShellTrips');
final _driverShellNavigatorWallet =
    GlobalKey<NavigatorState>(debugLabel: 'driverShellWallet');
final _driverShellNavigatorProfile =
    GlobalKey<NavigatorState>(debugLabel: 'driverShellProfile');

/// Creates the production GoRouter instance for Yo'l-Yo'lakay Driver.
GoRouter createDriverRouter() {
  final router = GoRouter(
    navigatorKey: driverRootNavigatorKey,
    initialLocation: '/splash',
    routes: [
      // 1. Splash Screen
      GoRoute(
        path: '/splash',
        builder: (context, state) => const DriverSplashPage(),
      ),

      // Onboarding Screen
      GoRoute(
        path: '/onboarding',
        builder: (context, state) => const OnboardingPage(),
      ),

      // Home fallback
      GoRoute(
        path: '/home',
        redirect: (context, state) => '/driver/home',
      ),

      // 2. Auth Flows
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginPage(),
      ),
      GoRoute(
        path: '/register',
        builder: (context, state) => const RegisterPage(),
      ),
      GoRoute(
        path: '/phone',
        builder: (context, state) => const PhonePage(),
      ),
      GoRoute(
        path: '/set-password',
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>?;
          return SetPasswordPage(
            nextRoute: extra?['nextRoute'] as String?,
          );
        },
      ),
      GoRoute(
        path: '/otp',
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>?;
          final phone = extra?['phone'] as String? ?? '';
          final session = extra?['session'] as OtpSessionEntity? ??
              const OtpSessionEntity(
                sessionId: '',
                expiresIn: 120,
                resendInterval: 60,
              );

          return OtpPage(
            phone: phone,
            session: session,
          );
        },
      ),

      // 3. Verification
      GoRoute(
        path: '/verification',
        builder: (context, state) => const DriverVerificationPage(),
      ),

      // 4. Modal / Full-screen sub-routes
      GoRoute(
        path: '/city-picker',
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>?;
          return CityPickerPage(
            title: extra?['title'] as String? ?? 'Shaharni tanlang',
            excludedCityId: extra?['excludedId'] as String?,
            initialMode: extra?['initialMode'] as CityPickerViewMode? ??
                CityPickerViewMode.map,
          );
        },
      ),
      GoRoute(
        path: '/driver/radar',
        builder: (context, state) => const DriverRadarPage(),
      ),
      GoRoute(
        path: '/driver/trips/create',
        builder: (context, state) {
          final extraRide = state.extra as IntercityRideEntity?;
          return CreateDriverTripPage(editRide: extraRide);
        },
      ),
      GoRoute(
        path: '/driver/create-trip',
        builder: (context, state) {
          final extraRide = state.extra as IntercityRideEntity?;
          return CreateDriverTripPage(editRide: extraRide);
        },
      ),
      GoRoute(
        path: '/driver/trips/:id',
        builder: (context, state) {
          final tripId = state.pathParameters['id'] ?? '';
          return DriverTripDetailsPage(rideId: tripId);
        },
      ),
      GoRoute(
        path: '/driver/trip/:id',
        builder: (context, state) {
          final tripId = state.pathParameters['id'] ?? '';
          return DriverTripDetailsPage(rideId: tripId);
        },
      ),
      GoRoute(
        path: '/driver/reviews',
        builder: (context, state) => const DriverReviewsPage(),
      ),
      GoRoute(
        path: '/reviews',
        builder: (context, state) => const DriverReviewsPage(),
      ),
      GoRoute(
        path: '/driver/notifications',
        builder: (context, state) => const NotificationsPage(),
      ),
      GoRoute(
        path: '/notifications',
        builder: (context, state) => const NotificationsPage(),
      ),
      GoRoute(
        path: '/driver/support',
        builder: (context, state) => const SupportPage(),
      ),
      GoRoute(
        path: '/support',
        builder: (context, state) => const SupportPage(),
      ),
      GoRoute(
        path: '/wallet',
        builder: (context, state) => const DriverWalletPage(),
      ),

      // 5. Stateful Shell Navigation (4 Main Tabs) with SmoothTabBranchContainer
      StatefulShellRoute(
        builder: (context, state, navigationShell) {
          return DriverMainShellPage(navigationShell: navigationShell);
        },
        navigatorContainerBuilder: (context, navigationShell, children) {
          return SmoothTabBranchContainer(
            navigationShell: navigationShell,
            children: children,
          );
        },
        branches: [
          // Branch 0: Asosiy (Home / Shift)
          StatefulShellBranch(
            navigatorKey: _driverShellNavigatorHome,
            routes: [
              GoRoute(
                path: '/driver/home',
                builder: (context, state) => const DriverHomePage(),
              ),
            ],
          ),
          // Branch 1: Qatnovlar (Trips / Rides)
          StatefulShellBranch(
            navigatorKey: _driverShellNavigatorTrips,
            routes: [
              GoRoute(
                path: '/driver/trips',
                builder: (context, state) => const DriverTripsPage(),
              ),
            ],
          ),
          // Branch 2: Hamyon (Wallet)
          StatefulShellBranch(
            navigatorKey: _driverShellNavigatorWallet,
            routes: [
              GoRoute(
                path: '/driver/wallet',
                builder: (context, state) => const DriverWalletPage(),
              ),
            ],
          ),
          // Branch 3: Profil (Profile)
          StatefulShellBranch(
            navigatorKey: _driverShellNavigatorProfile,
            routes: [
              GoRoute(
                path: '/driver/profile',
                builder: (context, state) => const DriverProfilePage(),
              ),
            ],
          ),
        ],
      ),
    ],
  );

  // Attach listeners if services are already registered
  setupRouterListeners(router);

  return router;
}

StreamSubscription<void>? _sessionSubscription;
StreamSubscription<String>? _notificationSubscription;

/// Attaches reactive listeners (session expiration, push notification deep-links)
/// to the GoRouter instance. Called after DI is configured.
void setupRouterListeners(GoRouter router) {
  _sessionSubscription?.cancel();
  _notificationSubscription?.cancel();

  if (sl.isRegistered<SessionManager>()) {
    _sessionSubscription = sl<SessionManager>().onSessionExpired.listen((_) {
      router.go('/login');
    });
  }

  if (sl.isRegistered<PushNotificationService>()) {
    _notificationSubscription = sl<PushNotificationService>()
        .onNotificationTapped
        .listen((targetRoute) {
      router.push(targetRoute);
    });
  }
}

/// Global GoRouter instance.
final GoRouter driverRouter = createDriverRouter();
