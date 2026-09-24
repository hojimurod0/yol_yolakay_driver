import 'package:flutter/material.dart';
import 'uzbek_license_plate.dart';

/// Clean, compact Chevrolet Cobalt front view widget with real photo and mounted Uzbek license plate.
class CobaltFrontView extends StatelessWidget {
  const CobaltFrontView({
    super.key,
    required this.plateNumber,
    this.carColor = 'Oq',
    this.isDark = false,
  });

  final String plateNumber;
  final String carColor;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: 260,
        height: 130,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: isDark
                  ? Colors.black.withValues(alpha: 0.5)
                  : Colors.black.withValues(alpha: 0.08),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Stack(
            alignment: Alignment.center,
            children: [
              // 1. Real Chevrolet Cobalt Front Photo
              Positioned.fill(
                child: Image.asset(
                  'assets/images/cobalt_front.jpg',
                  cacheWidth: 600,
                  filterQuality: FilterQuality.medium,
                  fit: BoxFit.cover,
                  alignment: const Alignment(0.0, -0.2),
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      color: isDark
                          ? const Color(0xFF1E2128)
                          : const Color(0xFFE2E8F0),
                      child: const Center(
                        child: Icon(Icons.directions_car_rounded,
                            size: 50, color: Colors.grey),
                      ),
                    );
                  },
                ),
              ),

              // 2. Subtle Vignette / Gradient Overlay to make the car & plate pop
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        Colors.black.withValues(alpha: 0.15),
                        Colors.black.withValues(alpha: 0.55),
                      ],
                      stops: const [0.4, 0.75, 1.0],
                    ),
                  ),
                ),
              ),

              // 3. Mounted Real Uzbek License Plate on the Bumper
              Positioned(
                bottom: 8,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 2, vertical: 1.5),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0F172A),
                    borderRadius: BorderRadius.circular(4),
                    border:
                        Border.all(color: const Color(0xFF334155), width: 1.0),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.45),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: UzbekLicensePlate(
                    plateNumber: plateNumber,
                    height: 20,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
