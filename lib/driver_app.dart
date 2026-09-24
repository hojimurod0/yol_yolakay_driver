import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:yol_yolakay_driver/l10n/generated/app_localizations.dart';

import 'core/di/injection_container.dart';
import 'core/providers/core_providers.dart';
import 'core/router/driver_router.dart';
import 'core/theme/app_theme.dart';
import 'core/widgets/app_error_boundary.dart';
import 'core/widgets/offline_banner_wrapper.dart';

import 'features/auth/presentation/bloc/auth_bloc.dart';
import 'features/auth/presentation/bloc/auth_event.dart';
import 'features/home/presentation/bloc/home_bloc.dart';
import 'features/intercity_rides/presentation/bloc/intercity_rides_bloc.dart';
import 'features/notifications/presentation/bloc/notifications_bloc.dart';
import 'features/profile/presentation/bloc/profile_bloc.dart';
import 'features/reviews/presentation/bloc/reviews_bloc.dart';
import 'features/support/presentation/bloc/support_bloc.dart';
import 'features/taxi_radar/presentation/bloc/taxi_radar_bloc.dart';
import 'features/verification/presentation/bloc/verification_bloc.dart';
import 'features/verification/presentation/bloc/verification_event.dart';
import 'features/wallet/presentation/bloc/wallet_bloc.dart';

/// Root widget for the standalone YolYolakay Driver application.
/// Injects all production BLoCs via MultiBlocProvider and provides high-performance driver experience.
class YolYolakayDriverApp extends ConsumerWidget {
  const YolYolakayDriverApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(driverRouterProvider);
    final themeMode = ref.watch(themeNotifierProvider);
    final locale = ref.watch(localeNotifierProvider);

    return MultiBlocProvider(
      providers: [
        BlocProvider<AuthBloc>(
          create: (_) => sl.createAuthBloc()..add(const CheckAuthStatusEvent()),
        ),
        BlocProvider<VerificationBloc>(
          create: (_) =>
              sl.createVerificationBloc()..add(const LoadCitiesEvent()),
        ),
        BlocProvider<HomeBloc>(
          create: (_) => sl.createHomeBloc(),
        ),
        BlocProvider<TaxiRadarBloc>(
          create: (_) => sl.createTaxiRadarBloc(),
        ),
        BlocProvider<IntercityRidesBloc>(
          create: (_) => sl.createIntercityRidesBloc(),
        ),
        BlocProvider<WalletBloc>(
          create: (_) => sl.createWalletBloc(),
        ),
        BlocProvider<ReviewsBloc>(
          create: (_) => sl.createReviewsBloc(),
        ),
        BlocProvider<NotificationsBloc>(
          create: (_) => sl.createNotificationsBloc(),
        ),
        BlocProvider<SupportBloc>(
          create: (_) => sl.createSupportBloc(),
        ),
        BlocProvider<ProfileBloc>(
          create: (_) => sl.createProfileBloc(),
        ),
      ],
      child: MaterialApp.router(
        title: 'Yo\'l-Yo\'lakay Haydovchi',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: themeMode,
        locale: locale,
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: AppLocalizations.supportedLocales,
        routerConfig: router,
        builder: (context, child) {
          final mediaQuery = MediaQuery.of(context);
          final boundedScaler = mediaQuery.textScaler.clamp(
            maxScaleFactor: 1.25,
          );
          return MediaQuery(
            data: mediaQuery.copyWith(textScaler: boundedScaler),
            child: AppErrorBoundary(
              child: OfflineBannerWrapper(child: child),
            ),
          );
        },
      ),
    );
  }
}
