import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../utils/app_logger.dart';

/// Centralized service to launch external GPS navigation apps
/// (Yandex Navigator, Yandex Maps, Google Maps) tailored for Uzbek drivers.
class NavigationLauncherService {
  NavigationLauncherService._();
  static final NavigationLauncherService instance = NavigationLauncherService._();

  /// Launches the best available navigator for the given coordinates or address.
  /// Prefers Yandex Navigator (the industry standard in Uzbekistan),
  /// falling back sequentially to Google Maps and web-based maps.
  Future<bool> launchNavigation({
    double? latitude,
    double? longitude,
    String? address,
    String? label,
  }) async {
    try {
      if (latitude != null && longitude != null) {
        // 1. Try Yandex Navigator directly
        final yandexNaviUri = Uri.parse(
          'yandexnavi://build_route_on_map?lat_to=$latitude&lon_to=$longitude',
        );
        if (await canLaunchUrl(yandexNaviUri)) {
          return await launchUrl(yandexNaviUri, mode: LaunchMode.externalApplication);
        }

        // 2. Try Yandex Maps
        final yandexMapsUri = Uri.parse(
          'yandexmaps://maps.yandex.ru/?pt=$longitude,$latitude&z=16&l=map',
        );
        if (await canLaunchUrl(yandexMapsUri)) {
          return await launchUrl(yandexMapsUri, mode: LaunchMode.externalApplication);
        }

        // 3. Try Google Navigation intent
        final googleNavUri = Uri.parse('google.navigation:q=$latitude,$longitude');
        if (await canLaunchUrl(googleNavUri)) {
          return await launchUrl(googleNavUri, mode: LaunchMode.externalApplication);
        }

        // 4. Try geo: scheme
        final geoUri = Uri.parse('geo:$latitude,$longitude?q=$latitude,$longitude($label)');
        if (await canLaunchUrl(geoUri)) {
          return await launchUrl(geoUri, mode: LaunchMode.externalApplication);
        }

        // 5. Fallback to Google Maps Web
        final webMapsUri = Uri.parse(
          'https://www.google.com/maps/dir/?api=1&destination=$latitude,$longitude',
        );
        return await launchUrl(webMapsUri, mode: LaunchMode.externalApplication);
      } else if (address != null && address.trim().isNotEmpty) {
        final query = Uri.encodeComponent(address.trim());

        // 1. Try Yandex Navigator search
        final yandexNaviUri = Uri.parse('yandexnavi://map_search?text=$query');
        if (await canLaunchUrl(yandexNaviUri)) {
          return await launchUrl(yandexNaviUri, mode: LaunchMode.externalApplication);
        }

        // 2. Try Yandex Maps search
        final yandexMapsUri = Uri.parse('yandexmaps://maps.yandex.ru/?text=$query');
        if (await canLaunchUrl(yandexMapsUri)) {
          return await launchUrl(yandexMapsUri, mode: LaunchMode.externalApplication);
        }

        // 3. Google Maps Web search
        final webMapsUri = Uri.parse('https://www.google.com/maps/search/?api=1&query=$query');
        return await launchUrl(webMapsUri, mode: LaunchMode.externalApplication);
      }
      return false;
    } catch (e, st) {
      AppLogger.error(
        'NavigationLauncherService error: $e',
        error: e,
        stackTrace: st,
      );
      return false;
    }
  }

  /// Shows a modal bottom sheet allowing the driver to pick their preferred navigation tool.
  Future<void> showNavigationPickerModal({
    required BuildContext context,
    double? latitude,
    double? longitude,
    String? address,
    String? title,
  }) async {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF191B24) : Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: isDark ? Colors.white24 : Colors.black12,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              title ?? 'Navigatorda ochish',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 16),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.red.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.navigation_rounded, color: Colors.red, size: 24),
              ),
              title: const Text('Yandex Navigator', style: TextStyle(fontWeight: FontWeight.w700)),
              subtitle: const Text('O\'zbekiston bo\'yicha eng aniq yo\'l yo\'riqnomasi', style: TextStyle(fontSize: 12)),
              trailing: const Icon(Icons.chevron_right_rounded),
              onTap: () {
                Navigator.pop(ctx);
                launchNavigation(
                  latitude: latitude,
                  longitude: longitude,
                  address: address,
                );
              },
            ),
            const Divider(height: 12),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.blue.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.map_rounded, color: Colors.blue, size: 24),
              ),
              title: const Text('Google Maps', style: TextStyle(fontWeight: FontWeight.w700)),
              subtitle: const Text('Standart xaritalar va navigatsiya', style: TextStyle(fontSize: 12)),
              trailing: const Icon(Icons.chevron_right_rounded),
              onTap: () async {
                Navigator.pop(ctx);
                if (latitude != null && longitude != null) {
                  final googleNavUri = Uri.parse('google.navigation:q=$latitude,$longitude');
                  if (await canLaunchUrl(googleNavUri)) {
                    await launchUrl(googleNavUri, mode: LaunchMode.externalApplication);
                    return;
                  }
                  final webMapsUri = Uri.parse(
                    'https://www.google.com/maps/dir/?api=1&destination=$latitude,$longitude',
                  );
                  await launchUrl(webMapsUri, mode: LaunchMode.externalApplication);
                } else if (address != null) {
                  final query = Uri.encodeComponent(address.trim());
                  final webMapsUri = Uri.parse('https://www.google.com/maps/search/?api=1&query=$query');
                  await launchUrl(webMapsUri, mode: LaunchMode.externalApplication);
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
