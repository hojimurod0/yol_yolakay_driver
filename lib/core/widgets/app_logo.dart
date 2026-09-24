import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

/// Authentic ILOVAMNI Taxi / GO Taxi Logo & Badge with Taxi Yellow & Charcoal Black.
class AppLogo extends StatelessWidget {
  const AppLogo({
    super.key,
    this.size = 80,
    this.showGlow = true,
    this.isCircle = true,
    this.isWide = false,
    this.borderRadius,
  });

  const AppLogo.wide({
    super.key,
    this.size = 50,
    this.showGlow = false,
    this.isCircle = false,
    this.borderRadius,
  }) : isWide = true;

  final double size;
  final bool showGlow;
  final bool isCircle;
  final bool isWide;
  final BorderRadius? borderRadius;

  @override
  Widget build(BuildContext context) {
    if (isWide) {
      final width = size * 1.77; // 16:9 aspect ratio
      final effectiveRadius =
          borderRadius ?? BorderRadius.circular(size * 0.22);

      return Container(
        width: width,
        height: size,
        decoration: BoxDecoration(
          color: Colors.black,
          borderRadius: effectiveRadius,
          border: Border.all(
            color: AppColors.taxiYellowDark.withValues(alpha: 0.6),
            width: 1.2,
          ),
          boxShadow: showGlow
              ? [
                  BoxShadow(
                    color: AppColors.taxiYellow.withValues(alpha: 0.35),
                    blurRadius: size * 0.3,
                    offset: Offset(0, size * 0.04),
                  ),
                ]
              : [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.2),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
        ),
        child: ClipRRect(
          borderRadius: effectiveRadius,
          child: Image.asset(
            'assets/icon/app_icon.png',
            width: width,
            height: size,
            fit: BoxFit.contain,
            errorBuilder: (context, error, stackTrace) => Container(
              color: Colors.black,
              alignment: Alignment.center,
              child: Icon(
                Icons.local_taxi_rounded,
                size: size * 0.55,
                color: AppColors.taxiYellow,
              ),
            ),
          ),
        ),
      );
    }

    if (isCircle) {
      return Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: AppColors.taxiYellow,
          shape: BoxShape.circle,
          border: Border.all(
            color: AppColors.taxiYellowDark,
            width: 1.5,
          ),
          boxShadow: showGlow
              ? [
                  BoxShadow(
                    color: AppColors.taxiYellow.withValues(alpha: 0.4),
                    blurRadius: size * 0.28,
                    offset: Offset(0, size * 0.03),
                  ),
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.15),
                    blurRadius: size * 0.1,
                  ),
                ]
              : [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.12),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
        ),
        child: ClipOval(
          child: Padding(
            padding: EdgeInsets.all(size * 0.04),
            child: Image.asset(
              'assets/icon/app_icon.png',
              width: size,
              height: size,
              fit: BoxFit.contain,
              filterQuality: FilterQuality.medium,
              errorBuilder: (context, error, stackTrace) => Container(
                color: AppColors.charcoalBlack,
                alignment: Alignment.center,
                child: Icon(
                  Icons.local_taxi_rounded,
                  size: size * 0.5,
                  color: AppColors.taxiYellow,
                ),
              ),
            ),
          ),
        ),
      );
    }

    final effectiveRadius = borderRadius ?? BorderRadius.circular(size * 0.24);

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: effectiveRadius,
        border: Border.all(
          color: AppColors.taxiYellowDark.withValues(alpha: 0.6),
          width: 1.5,
        ),
        boxShadow: showGlow
            ? [
                BoxShadow(
                  color: AppColors.taxiYellow.withValues(alpha: 0.35),
                  blurRadius: size * 0.3,
                  offset: Offset(0, size * 0.04),
                ),
              ]
            : [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.2),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
      ),
      child: ClipRRect(
        borderRadius: effectiveRadius,
        child: Padding(
          padding: EdgeInsets.all(size * 0.08),
          child: Image.asset(
            'assets/icon/app_icon.png',
            width: size,
            height: size,
            fit: BoxFit.contain,
            errorBuilder: (context, error, stackTrace) => Container(
              color: Colors.black,
              alignment: Alignment.center,
              child: Icon(
                Icons.local_taxi_rounded,
                size: size * 0.5,
                color: AppColors.taxiYellow,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
