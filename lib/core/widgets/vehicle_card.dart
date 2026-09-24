import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_radius.dart';
import '../theme/app_shadows.dart';
import 'uzbek_license_plate.dart';

/// Exact Road24 (Roat 24) style Vehicle Card:
/// - Top row: Chevrolet logo badge + "Chevrolet Cobalt" text on left, Edit pen icon on right
/// - Center: Clean side-profile photograph of the car
/// - Bottom: Centered official Uzbek License Plate
class VehicleSideCard extends StatelessWidget {
  const VehicleSideCard({
    super.key,
    this.make = 'Chevrolet',
    this.model = 'Cobalt',
    required this.plateNumber,
    this.onEdit,
  });

  final String make;
  final String model;
  final String plateNumber;
  final VoidCallback? onEdit;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
        borderRadius: AppRadius.borderXl,
        border: Border.all(
          color: isDark ? AppColors.borderDark : AppColors.borderLight,
          width: 1,
        ),
        boxShadow: isDark ? AppShadows.darkSm : AppShadows.sm,
      ),
      padding: const EdgeInsets.fromLTRB(14, 10, 14, 12),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 1. Header Row: Chevy Logo + Make/Model on left, Edit Pen on right
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Chevy Logo Badge + Text
              Row(
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: isDark
                          ? AppColors.surfaceSubtleDark
                          : AppColors.surfaceSubtleLight,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: isDark
                            ? AppColors.borderDark
                            : AppColors.borderLight,
                        width: 1,
                      ),
                    ),
                    padding: const EdgeInsets.all(5),
                    child: Center(
                      child: CustomPaint(
                        size: const Size(20, 10),
                        painter: _ChevyBowtiePainter(),
                      ),
                    ),
                  ),
                  const SizedBox(width: 9),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        make,
                        style: TextStyle(
                          fontSize: 10.5,
                          fontWeight: FontWeight.w600,
                          color: isDark
                              ? AppColors.textSecondaryDark
                              : AppColors.textSecondaryLight,
                          letterSpacing: 0.1,
                          height: 1.1,
                        ),
                      ),
                      const SizedBox(height: 1.5),
                      Text(
                        model,
                        style: TextStyle(
                          fontSize: 14.5,
                          fontWeight: FontWeight.w800,
                          color: isDark
                              ? AppColors.textPrimaryDark
                              : AppColors.textPrimaryLight,
                          letterSpacing: -0.2,
                          height: 1.1,
                        ),
                      ),
                    ],
                  ),
                ],
              ),

              // Edit Button (Pen Icon)
              if (onEdit != null)
                InkWell(
                  onTap: onEdit,
                  borderRadius: BorderRadius.circular(16),
                  child: Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: isDark
                          ? AppColors.surfaceSubtleDark
                          : AppColors.surfaceSubtleLight,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: isDark
                            ? AppColors.borderDark
                            : AppColors.borderLight,
                        width: 1,
                      ),
                    ),
                    child: Icon(
                      Icons.edit_outlined,
                      size: 15,
                      color: isDark
                          ? AppColors.textSecondaryDark
                          : AppColors.textSecondaryLight,
                    ),
                  ),
                ),
            ],
          ),

          const SizedBox(height: 4),

          // 2. Car Side Profile Image
          Container(
            height: 96,
            width: double.infinity,
            alignment: Alignment.center,
            child: Image.asset(
              'assets/images/cobalt_side.jpg',
              cacheWidth: 600,
              filterQuality: FilterQuality.medium,
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  height: 80,
                  color: Colors.transparent,
                  child: const Center(
                    child: Icon(Icons.directions_car_rounded,
                        size: 50, color: Colors.grey),
                  ),
                );
              },
            ),
          ),

          const SizedBox(height: 6),

          // 3. Centered Uzbek License Plate
          Center(
            child: UzbekLicensePlate(
              plateNumber: plateNumber,
              height: 26,
            ),
          ),
        ],
      ),
    );
  }
}

/// Precise Chevrolet Bowtie logo painter
class _ChevyBowtiePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    final path = Path()
      ..moveTo(w * 0.1, h * 0.25)
      ..lineTo(w * 0.9, h * 0.25)
      ..lineTo(w * 0.8, h * 0.75)
      ..lineTo(w * 0.2, h * 0.75)
      ..close();

    final cross = Path()
      ..moveTo(w * 0.38, 0)
      ..lineTo(w * 0.62, 0)
      ..lineTo(w * 0.62, h)
      ..lineTo(w * 0.38, h)
      ..close();

    final goldPaint = Paint()..color = const Color(0xFFEAB308);
    final borderPaint = Paint()
      ..color = const Color(0xFFCA8A04)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.8;

    canvas.drawPath(cross, goldPaint);
    canvas.drawPath(path, goldPaint);
    canvas.drawPath(cross, borderPaint);
    canvas.drawPath(path, borderPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
