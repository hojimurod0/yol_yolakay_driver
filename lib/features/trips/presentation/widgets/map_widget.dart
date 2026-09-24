import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';

/// Decoupled interactive MapWidget abstraction.
/// Renders highway route lines, driver real-time marker, passenger pickup points, and zoom controls.
/// Ready to attach Google Maps or Yandex Maps SDK without modifying trip tracking presentation logic.
class MapWidget extends StatelessWidget {
  const MapWidget({
    super.key,
    required this.driverLat,
    required this.driverLng,
    required this.pickupTitle,
    required this.destinationTitle,
    this.remainingMinutes = 45,
    this.height = 280.0,
  });

  final double driverLat;
  final double driverLng;
  final String pickupTitle;
  final String destinationTitle;
  final int remainingMinutes;
  final double height;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final localeCode = Localizations.localeOf(context).languageCode;
    final pickupLabel = localeCode == 'ru'
        ? 'Посадка'
        : (localeCode == 'en' ? 'Pickup' : 'Chiqish');
    final destLabel = localeCode == 'ru'
        ? 'Место'
        : (localeCode == 'en' ? 'Dest.' : 'Manzil');
    final minuteSuffix =
        localeCode == 'ru' ? 'мин' : (localeCode == 'en' ? 'm' : 'daq');

    return Container(
      height: height,
      width: double.infinity,
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF0F172A) : const Color(0xFFE2E8F0),
        borderRadius: AppRadius.borderLg,
      ),
      child: ClipRRect(
        borderRadius: AppRadius.borderLg,
        child: Stack(
          children: [
            // Custom Map Canvas (Roads, highway, terrain abstraction)
            CustomPaint(
              size: Size.infinite,
              painter: _MapCanvasPainter(isDark: isDark),
            ),

            // Pickup Marker
            Positioned(
              left: 40,
              bottom: 60,
              child: _MapPin(
                label: pickupLabel,
                color: AppColors.primary,
                icon: Icons.person_pin_circle_rounded,
              ),
            ),

            // Destination Marker
            Positioned(
              right: 40,
              top: 50,
              child: _MapPin(
                label: destLabel,
                color: AppColors.error,
                icon: Icons.flag_rounded,
              ),
            ),

            // Live Moving Driver Vehicle Marker
            Positioned(
              left: 140,
              top: 110,
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: const BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: AppRadius.borderPill,
                      boxShadow: [
                        BoxShadow(
                          color: Color(0x33000000),
                          blurRadius: 8,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Text(
                      '$remainingMinutes $minuteSuffix',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      color: AppColors.white,
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColors.primary, width: 2),
                      boxShadow: const [
                        BoxShadow(
                          color: Color(0x33000000),
                          blurRadius: 10,
                          offset: Offset(0, 4),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.directions_car_rounded,
                      color: AppColors.primary,
                      size: 22,
                    ),
                  ),
                ],
              ),
            ),

            // Map Controls (Zoom / Recenter)
            Positioned(
              right: 12,
              bottom: 12,
              child: Column(
                children: [
                  _buildMapControl(Icons.add_rounded, () {}),
                  const SizedBox(height: 6),
                  _buildMapControl(Icons.remove_rounded, () {}),
                  const SizedBox(height: 6),
                  _buildMapControl(Icons.my_location_rounded, () {}),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMapControl(IconData icon, VoidCallback onTap) {
    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: const [
          BoxShadow(
            color: Color(0x20000000),
            blurRadius: 6,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: IconButton(
        padding: EdgeInsets.zero,
        icon: Icon(icon, size: 20, color: const Color(0xFF0F172A)),
        onPressed: onTap,
      ),
    );
  }
}

class _MapPin extends StatelessWidget {
  const _MapPin({
    required this.label,
    required this.color,
    required this.icon,
  });

  final String label;
  final Color color;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
          decoration: BoxDecoration(
            color: color,
            borderRadius: AppRadius.borderPill,
          ),
          child: Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 10,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        Icon(icon, color: color, size: 28),
      ],
    );
  }
}

class _MapCanvasPainter extends CustomPainter {
  _MapCanvasPainter({required this.isDark});
  final bool isDark;

  @override
  void paint(Canvas canvas, Size size) {
    final bgPaint = Paint()
      ..color = isDark ? const Color(0xFF131B2E) : const Color(0xFFE2E8F0);
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), bgPaint);

    // Minor roads
    final minorRoadPaint = Paint()
      ..color = isDark ? const Color(0xFF1E293B) : const Color(0xFFCBD5E1)
      ..strokeWidth = 3.0
      ..style = PaintingStyle.stroke;

    final path1 = Path()
      ..moveTo(0, size.height * 0.3)
      ..cubicTo(size.width * 0.4, size.height * 0.2, size.width * 0.6,
          size.height * 0.8, size.width, size.height * 0.7);
    canvas.drawPath(path1, minorRoadPaint);

    // Major Intercity Highway Route (M39 Tashkent-Samarkand route)
    final highwayCasingPaint = Paint()
      ..color = isDark ? const Color(0xFF003D99) : const Color(0xFF93C5FD)
      ..strokeWidth = 8.0
      ..style = PaintingStyle.stroke;

    final highwayRoutePaint = Paint()
      ..color = AppColors.primary
      ..strokeWidth = 5.0
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final routePath = Path()
      ..moveTo(40, size.height - 60)
      ..cubicTo(
        size.width * 0.35,
        size.height * 0.65,
        size.width * 0.6,
        size.height * 0.45,
        size.width - 40,
        50,
      );

    canvas.drawPath(routePath, highwayCasingPaint);
    canvas.drawPath(routePath, highwayRoutePaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
