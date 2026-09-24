import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:yol_yolakay_driver/l10n/generated/app_localizations.dart';
import 'core/providers/core_providers.dart';
import 'core/router/driver_router.dart';
import 'core/theme/app_theme.dart';
import 'core/widgets/app_error_boundary.dart';
import 'core/widgets/offline_banner_wrapper.dart';

/// Root widget for the standalone YolYolakay Driver application.
class YolYolakayDriverApp extends ConsumerWidget {
  const YolYolakayDriverApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(driverRouterProvider);
    final themeMode = ref.watch(themeNotifierProvider);
    final locale = ref.watch(localeNotifierProvider);

    return MaterialApp.router(
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
    );
  }
}
