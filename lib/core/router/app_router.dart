import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../widgets/smooth_tab_branch_container.dart';

import '../../features/auth/domain/entities/driver_user_entity.dart';
import '../../features/auth/presentation/pages/create_profile_page.dart';
import '../../features/auth/presentation/pages/otp_page.dart';
import '../../features/auth/presentation/pages/phone_page.dart';
import '../../features/auth/presentation/pages/welcome_page.dart';
import '../../features/booking/domain/entities/booking_entity.dart';
import '../../features/booking/presentation/pages/booking_page.dart';
import '../../features/booking/presentation/pages/booking_success_page.dart';
import '../../features/home/presentation/pages/city_picker_page.dart';
import '../../features/home/presentation/pages/home_page.dart';
import '../../features/home/presentation/pages/main_shell_page.dart';
import '../../features/notifications/presentation/pages/notifications_page.dart';
import '../../features/onboarding/presentation/pages/language_select_page.dart';
import '../../features/onboarding/presentation/pages/onboarding_page.dart';
import '../../features/splash/presentation/pages/splash_page.dart';
import '../../features/profile/presentation/pages/edit_profile_page.dart';
import '../../features/profile/presentation/pages/profile_page.dart';
import '../../features/rides/domain/entities/ride_entity.dart';
import '../../features/rides/presentation/pages/ride_details_page.dart';
import '../../features/rides/presentation/pages/search_results_page.dart';
import '../../features/settings/presentation/pages/settings_page.dart';
import '../../features/support/presentation/pages/support_page.dart';
import '../../features/taxi_booking/presentation/pages/taxi_map_screen.dart';
import '../../features/trips/domain/entities/trip_entity.dart';
import '../../features/trips/presentation/pages/tracking_page.dart';
import '../../features/trips/presentation/pages/trip_details_page.dart';
import '../../features/trips/presentation/pages/trips_page.dart';
import '../../features/driver/domain/entities/driver_incoming_request_entity.dart';
import '../../features/driver/presentation/pages/create_driver_trip_page.dart';
import '../../features/driver/presentation/pages/driver_home_page.dart';
import '../../features/driver/presentation/pages/driver_main_shell_page.dart';
import '../../features/driver/presentation/pages/driver_profile_page.dart';
import '../../features/driver/presentation/pages/driver_radar_page.dart';
import '../../features/driver/presentation/pages/driver_registration_page.dart';
import '../../features/driver/presentation/pages/driver_trips_page.dart';
import '../../features/onboarding/presentation/pages/role_select_page.dart';

final rootNavigatorKey = GlobalKey<NavigatorState>();
final _shellNavigatorHome = GlobalKey<NavigatorState>(debugLabel: 'shellHome');
final _shellNavigatorTaxiMap =
    GlobalKey<NavigatorState>(debugLabel: 'shellTaxiMap');
final _shellNavigatorTrips =
    GlobalKey<NavigatorState>(debugLabel: 'shellTrips');
final _shellNavigatorProfile =
    GlobalKey<NavigatorState>(debugLabel: 'shellProfile');

final _driverShellNavigatorRadar =
    GlobalKey<NavigatorState>(debugLabel: 'driverShellRadar');
final _driverShellNavigatorTrips =
    GlobalKey<NavigatorState>(debugLabel: 'driverShellTrips');
final _driverShellNavigatorProfile =
    GlobalKey<NavigatorState>(debugLabel: 'driverShellProfile');

final appRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    navigatorKey: rootNavigatorKey,
    initialLocation: '/splash',
    routes: [
      // Language Selection Route (First Launch Step)
      GoRoute(
        path: '/language-select',
        builder: (context, state) => const LanguageSelectPage(),
      ),

      // Role Selection Route (Passenger or Driver choice)
      GoRoute(
        path: '/role-select',
        builder: (context, state) => const RoleSelectPage(),
      ),

      // Splash Route
      GoRoute(
        path: '/splash',
        builder: (context, state) => const SplashPage(),
      ),

      // Onboarding Route
      GoRoute(
        path: '/onboarding',
        builder: (context, state) => const OnboardingPage(),
      ),

      // Auth Routes
      GoRoute(
        path: '/auth/welcome',
        builder: (context, state) => const WelcomePage(),
      ),
      GoRoute(
        path: '/auth/phone',
        builder: (context, state) => const PhonePage(),
      ),
      GoRoute(
        path: '/auth/otp',
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>?;
          final phone = extra?['phone'] as String? ?? '';
          final session = extra?['session'] as OtpSessionEntity? ??
              const OtpSessionEntity(
                  sessionId: '', expiresIn: 120, resendInterval: 60);

          return OtpPage(
            phone: phone,
            session: session,
          );
        },
      ),
      GoRoute(
        path: '/auth/create-profile',
        builder: (context, state) => const CreateProfilePage(),
      ),

      // Bottom Navigation Shell (Home, Tezkor Taksi, Trips, Profile)
      StatefulShellRoute(
        builder: (context, state, navigationShell) {
          return MainShellPage(navigationShell: navigationShell);
        },
        navigatorContainerBuilder: (context, navigationShell, children) {
          return SmoothTabBranchContainer(
            navigationShell: navigationShell,
            children: children,
          );
        },
        branches: [
          // Branch 0: Asosiy (Shaharlararo)
          StatefulShellBranch(
            navigatorKey: _shellNavigatorHome,
            routes: [
              GoRoute(
                path: '/home',
                builder: (context, state) => const HomePage(),
              ),
            ],
          ),
          // Branch 1: Tezkor Taksi (Xaritada buyurtma berish)
          StatefulShellBranch(
            navigatorKey: _shellNavigatorTaxiMap,
            routes: [
              GoRoute(
                path: '/taxi-map',
                builder: (context, state) => const TaxiMapScreen(),
              ),
            ],
          ),
          // Branch 2: Safarlarim (Trips)
          StatefulShellBranch(
            navigatorKey: _shellNavigatorTrips,
            routes: [
              GoRoute(
                path: '/trips',
                builder: (context, state) => const TripsPage(),
              ),
            ],
          ),
          // Branch 3: Profil
          StatefulShellBranch(
            navigatorKey: _shellNavigatorProfile,
            routes: [
              GoRoute(
                path: '/profile',
                builder: (context, state) => const ProfilePage(),
              ),
            ],
          ),
        ],
      ),

      // Standalone Notifications Route
      GoRoute(
        path: '/notifications',
        builder: (context, state) => const NotificationsPage(),
      ),

      // Search & Booking Routes
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
        path: '/search-results',
        builder: (context, state) => const SearchResultsPage(),
      ),
      GoRoute(
        path: '/ride/:id',
        builder: (context, state) {
          final ride =
              state.extra is RideEntity ? state.extra as RideEntity : null;
          if (ride == null) {
            return const HomePage();
          }
          return RideDetailsPage(ride: ride);
        },
      ),
      GoRoute(
        path: '/booking/:rideId',
        builder: (context, state) {
          final rideId = state.pathParameters['rideId'] ?? '';
          return BookingPage(rideId: rideId);
        },
      ),
      GoRoute(
        path: '/booking-success',
        builder: (context, state) {
          final booking = state.extra is BookingEntity
              ? state.extra as BookingEntity
              : null;
          if (booking == null) {
            return const HomePage();
          }
          return BookingSuccessPage(booking: booking);
        },
      ),

      // Trips & Tracking
      GoRoute(
        path: '/trip-details/:id',
        builder: (context, state) {
          final trip =
              state.extra is TripEntity ? state.extra as TripEntity : null;
          if (trip == null) {
            return const TripsPage();
          }
          return TripDetailsPage(trip: trip);
        },
      ),
      GoRoute(
        path: '/tracking/:id',
        builder: (context, state) {
          final id = state.pathParameters['id'] ?? '';
          final extraTrip = state.extra as TripEntity?;
          return TrackingPage(tripId: id, initialTrip: extraTrip);
        },
      ),

      // Profile, Settings & Support
      GoRoute(
        path: '/profile/edit',
        builder: (context, state) => const EditProfilePage(),
      ),
      GoRoute(
        path: '/settings',
        builder: (context, state) => const SettingsPage(),
      ),
      GoRoute(
        path: '/support',
        builder: (context, state) => const SupportPage(),
      ),

      // Driver Setup & Flow Routes
      GoRoute(
        path: '/driver/register',
        builder: (context, state) => const DriverRegistrationPage(),
      ),
      GoRoute(
        path: '/driver/create-trip',
        builder: (context, state) => const CreateDriverTripPage(),
      ),

      // Driver Standalone Map View (Navigatsiya / Manzilni ko'rish)
      GoRoute(
        path: '/driver/map',
        builder: (context, state) {
          final req = state.extra as DriverIncomingRequestEntity?;
          return DriverHomePage(activeRequest: req);
        },
      ),

      // Driver Bottom Navigation Shell (Dashboard, Trips, Profile)
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
          // Branch 0: Buyurtmalar (Orders / Asosiy)
          StatefulShellBranch(
            navigatorKey: _driverShellNavigatorRadar,
            routes: [
              GoRoute(
                path: '/driver/home',
                builder: (context, state) => const DriverRadarPage(),
              ),
            ],
          ),
          // Branch 1: Qatnovlar (Trips)
          StatefulShellBranch(
            navigatorKey: _driverShellNavigatorTrips,
            routes: [
              GoRoute(
                path: '/driver/trips',
                builder: (context, state) => const DriverTripsPage(),
              ),
            ],
          ),
          // Branch 2: Profil
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
});
