import 'package:flutter/material.dart';
import 'app_text_sizes.dart';

/// Centralized typographic scale for YolYolakay Driver.
/// Balanced, modern, highly readable and aligned with AppTextSizes.
abstract class AppTypography {
  static const TextStyle displayLarge = TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.w900,
    letterSpacing: -0.5,
    height: 1.2,
  );

  static const TextStyle displayMedium = TextStyle(
    fontSize: AppTextSizes.display, // 26.0
    fontWeight: FontWeight.w800,
    letterSpacing: -0.4,
    height: 1.25,
  );

  static const TextStyle headlineLarge = TextStyle(
    fontSize: AppTextSizes.xxl, // 20.0
    fontWeight: FontWeight.w800,
    letterSpacing: -0.3,
    height: 1.3,
  );

  static const TextStyle headlineMedium = TextStyle(
    fontSize: AppTextSizes.xl, // 18.0
    fontWeight: FontWeight.w700,
    letterSpacing: -0.2,
    height: 1.3,
  );

  static const TextStyle titleLarge = TextStyle(
    fontSize: AppTextSizes.lg, // 16.0
    fontWeight: FontWeight.w700,
    letterSpacing: -0.1,
    height: 1.35,
  );

  static const TextStyle titleMedium = TextStyle(
    fontSize: AppTextSizes.base, // 15.0
    fontWeight: FontWeight.w700,
    height: 1.35,
  );

  static const TextStyle titleSmall = TextStyle(
    fontSize: AppTextSizes.md, // 14.0
    fontWeight: FontWeight.w600,
    height: 1.35,
  );

  static const TextStyle bodyLarge = TextStyle(
    fontSize: AppTextSizes.base, // 15.0
    fontWeight: FontWeight.w500,
    height: 1.4,
  );

  static const TextStyle bodyMedium = TextStyle(
    fontSize: AppTextSizes.md, // 14.0
    fontWeight: FontWeight.w500,
    height: 1.4,
  );

  static const TextStyle bodySmall = TextStyle(
    fontSize: AppTextSizes.sm, // 12.0
    fontWeight: FontWeight.w500,
    height: 1.35,
  );

  static const TextStyle labelLarge = TextStyle(
    fontSize: AppTextSizes.md, // 14.0
    fontWeight: FontWeight.w700,
    letterSpacing: 0.1,
    height: 1.3,
  );

  static const TextStyle labelMedium = TextStyle(
    fontSize: AppTextSizes.sm, // 12.0
    fontWeight: FontWeight.w600,
    letterSpacing: 0.1,
    height: 1.3,
  );

  static const TextStyle labelSmall = TextStyle(
    fontSize: AppTextSizes.xs, // 11.0
    fontWeight: FontWeight.w600,
    letterSpacing: 0.2,
    height: 1.25,
  );
}
