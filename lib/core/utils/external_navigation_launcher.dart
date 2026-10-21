import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';

import '../theme/app_colors.dart';
import '../theme/app_radius.dart';
import '../theme/app_spacing.dart';
import '../theme/app_typography.dart';
import 'app_logger.dart';

/// Dedicated utility for launching external navigation applications
/// (Yandex Navigator, Yandex Maps, 2GIS, Google Maps) with coordinates.
class ExternalNavigationLauncher {
  ExternalNavigationLauncher._();

  /// Launch Yandex Navigator directly
  static Future<bool> openYandexNavigator({
    required double lat,
    required double lng,
  }) async {
    HapticFeedback.selectionClick();
    final nativeUri =
        Uri.parse('yandexnavi://build_route_on_map?lat_to=$lat&lon_to=$lng');
    final webFallback =
        Uri.parse('https://yandex.uz/maps/?rtext=~$lat,$lng&rtt=auto');

    try {
      if (await canLaunchUrl(nativeUri)) {
        return await launchUrl(nativeUri);
      }
      return await launchUrl(webFallback, mode: LaunchMode.externalApplication);
    } catch (e) {
      AppLogger.warning('Failed to open Yandex Navigator: $e',
          module: LogModule.system);
      return false;
    }
  }

  /// Launch Yandex Maps app or browser
  static Future<bool> openYandexMaps({
    required double lat,
    required double lng,
  }) async {
    HapticFeedback.selectionClick();
    final nativeUri =
        Uri.parse('yandexmaps://maps.yandex.ru/?rtext=~$lat,$lng&rtt=auto');
    final webFallback =
        Uri.parse('https://yandex.uz/maps/?rtext=~$lat,$lng&rtt=auto');

    try {
      if (await canLaunchUrl(nativeUri)) {
        return await launchUrl(nativeUri);
      }
      return await launchUrl(webFallback, mode: LaunchMode.externalApplication);
    } catch (e) {
      AppLogger.warning('Failed to open Yandex Maps: $e',
          module: LogModule.system);
      return false;
    }
  }

  /// Launch 2GIS navigator directly
  static Future<bool> open2Gis({
    required double lat,
    required double lng,
  }) async {
    HapticFeedback.selectionClick();
    // 2GIS format: lon,lat
    final nativeUri =
        Uri.parse('dgis://2gis.ru/routeSearch/rsType/car/to/$lng,$lat');
    final webFallback =
        Uri.parse('https://2gis.uz/directions/points/~$lng,$lat');

    try {
      if (await canLaunchUrl(nativeUri)) {
        return await launchUrl(nativeUri);
      }
      return await launchUrl(webFallback, mode: LaunchMode.externalApplication);
    } catch (e) {
      AppLogger.warning('Failed to open 2GIS: $e', module: LogModule.system);
      return false;
    }
  }

  /// Launch Google Maps turn-by-turn navigation
  static Future<bool> openGoogleMaps({
    required double lat,
    required double lng,
  }) async {
    HapticFeedback.selectionClick();
    final nativeUri = Uri.parse('google.navigation:q=$lat,$lng');
    final webFallback = Uri.parse(
        'https://www.google.com/maps/dir/?api=1&destination=$lat,$lng');

    try {
      if (await canLaunchUrl(nativeUri)) {
        return await launchUrl(nativeUri);
      }
      return await launchUrl(webFallback, mode: LaunchMode.externalApplication);
    } catch (e) {
      AppLogger.warning('Failed to open Google Maps: $e',
          module: LogModule.system);
      return false;
    }
  }

  /// Displays an interactive modal bottom sheet allowing the driver to select
  /// their preferred navigation app for the given coordinates.
  static Future<void> showNavigationChooser(
    BuildContext context, {
    required double lat,
    required double lng,
    String? destinationTitle,
  }) async {
    HapticFeedback.lightImpact();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: isDark ? AppColors.surfaceDark : Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (bottomContext) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.lg,
              vertical: AppSpacing.md,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    margin: const EdgeInsets.only(bottom: AppSpacing.md),
                    decoration: BoxDecoration(
                      color: Colors.grey.withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                Text(
                  'Navigatsiya dasturini tanlang',
                  style: AppTypography.titleMedium.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                if (destinationTitle != null && destinationTitle.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    destinationTitle,
                    style: AppTypography.bodySmall.copyWith(
                      color: AppColors.textSecondary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
                const SizedBox(height: AppSpacing.md),
                _buildNavOption(
                  context: bottomContext,
                  icon: Icons.navigation_rounded,
                  iconColor: const Color(0xFFFC3F1D), // Yandex Red
                  title: 'Yandex Navigator',
                  subtitle: 'Avtomobil yo\'nalishi va tirbandliklar',
                  onTap: () {
                    Navigator.of(bottomContext).pop();
                    openYandexNavigator(lat: lat, lng: lng);
                  },
                ),
                _buildNavOption(
                  context: bottomContext,
                  icon: Icons.map_outlined,
                  iconColor: const Color(0xFFFFCC00), // Yandex Maps Yellow
                  title: 'Yandex Xaritalar',
                  subtitle: 'Batafsil shahar xaritasi',
                  onTap: () {
                    Navigator.of(bottomContext).pop();
                    openYandexMaps(lat: lat, lng: lng);
                  },
                ),
                _buildNavOption(
                  context: bottomContext,
                  icon: Icons.explore_rounded,
                  iconColor: const Color(0xFF00AA44), // 2GIS Green
                  title: '2GIS',
                  subtitle: 'Aniq kirish yo\'llari va binolar',
                  onTap: () {
                    Navigator.of(bottomContext).pop();
                    open2Gis(lat: lat, lng: lng);
                  },
                ),
                _buildNavOption(
                  context: bottomContext,
                  icon: Icons.near_me_rounded,
                  iconColor: const Color(0xFF4285F4), // Google Blue
                  title: 'Google Xaritalar',
                  subtitle: 'Standart Google navigatsiyasi',
                  onTap: () {
                    Navigator.of(bottomContext).pop();
                    openGoogleMaps(lat: lat, lng: lng);
                  },
                ),
                const SizedBox(height: AppSpacing.xs),
              ],
            ),
          ),
        );
      },
    );
  }

  static Widget _buildNavOption({
    required BuildContext context,
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.xs),
      child: ListTile(
        onTap: onTap,
        contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
        shape: const RoundedRectangleBorder(
          borderRadius: AppRadius.borderMd,
        ),
        leading: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: iconColor.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: iconColor, size: 24),
        ),
        title: Text(
          title,
          style: AppTypography.bodyMedium.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: AppTypography.bodySmall.copyWith(
            color: isDark ? Colors.white60 : AppColors.textSecondary,
          ),
        ),
        trailing: const Icon(
          Icons.chevron_right_rounded,
          color: Colors.grey,
          size: 20,
        ),
      ),
    );
  }
}
