import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:yol_yolakay_driver/l10n/generated/app_localizations.dart';

import 'core/di/injection.dart';
import 'core/localization/locale_cubit.dart';
import 'core/network/network_cubit.dart';
import 'core/router/driver_router.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/theme_cubit.dart';
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
/// Wraps application with core BLoC providers and reactive themes/locales.
class YolYolakayDriverApp extends StatelessWidget {
  const YolYolakayDriverApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<ThemeCubit>(create: (_) => sl<ThemeCubit>()),
        BlocProvider<LocaleCubit>(create: (_) => sl<LocaleCubit>()),
        BlocProvider<NetworkCubit>(create: (_) => sl<NetworkCubit>()),
        BlocProvider<AuthBloc>(
          create: (_) => sl<AuthBloc>()..add(const CheckAuthStatusEvent()),
        ),
        BlocProvider<VerificationBloc>(
          create: (_) => sl<VerificationBloc>()..add(const LoadCitiesEvent()),
        ),
        BlocProvider<HomeBloc>(create: (_) => sl<HomeBloc>()),
        BlocProvider<TaxiRadarBloc>(create: (_) => sl<TaxiRadarBloc>()),
        BlocProvider<IntercityRidesBloc>(
          create: (_) => sl<IntercityRidesBloc>(),
        ),
        BlocProvider<WalletBloc>(create: (_) => sl<WalletBloc>()),
        BlocProvider<ReviewsBloc>(create: (_) => sl<ReviewsBloc>()),
        BlocProvider<NotificationsBloc>(create: (_) => sl<NotificationsBloc>()),
        BlocProvider<SupportBloc>(create: (_) => sl<SupportBloc>()),
        BlocProvider<ProfileBloc>(create: (_) => sl<ProfileBloc>()),
      ],
      child: const _DriverAppView(),
    );
  }
}

class _DriverAppView extends StatelessWidget {
  const _DriverAppView();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ThemeCubit, ThemeMode>(
      builder: (context, themeMode) {
        return BlocBuilder<LocaleCubit, Locale>(
          builder: (context, locale) {
            return MaterialApp.router(
              title: 'Yol-Yolakay',
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
              routerConfig: driverRouter,
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
            );
          },
        );
      },
    );
  }
}
