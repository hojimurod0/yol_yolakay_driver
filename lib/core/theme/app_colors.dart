import 'package:flutter/material.dart';

/// Centralized color palette for the YolYolakay Taxi application.
/// Strictly adheres to the modern minimal Taxi Yellow (#FFC107) + Charcoal Black (#111111) identity
/// with a comfortable, eye-friendly Slate-Charcoal Dark Theme (not pure black #000000).
abstract class AppColors {
  // Brand Colors (Taxi Yellow #FFC107 & Charcoal Black #111111)
  static const Color primary = Color(0xFFFFC107); // Taxi Yellow
  static const Color primaryHover = Color(0xFFFFB300);
  static const Color primaryLight = Color(0xFFFFF8E1); // Soft Warm Amber Tint
  static const Color primaryDark = Color(0xFF111111); // Charcoal Black

  // Taxi & Brand Identity Accents
  static const Color taxiYellow = Color(0xFFFFC107);
  static const Color taxiYellowDark = Color(0xFFFFA000);
  static const Color taxiYellowLight = Color(0xFFFFF9C4);
  static const Color charcoalBlack = Color(0xFF111111);

  // Gradient Colors (Clean & Subtle Taxi Highlight)
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFFFC107), Color(0xFFFFB300)],
  );

  static const LinearGradient taxiGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFFFC107), Color(0xFFFFA000)],
  );

  // Secondary & Accents
  static const Color secondary = Color(0xFF111111);
  static const Color accent = Color(0xFFFFC107);
  static const Color accentRose = Color(0xFFEF4444);

  // Status & Feedback
  static const Color success = Color(0xFF22C55E); // Green
  static const Color successLight = Color(0xFFDCFCE7);
  static const Color successDarkBg = Color(0xFF064E3B);
  static const Color warning = Color(0xFFF59E0B); // Amber
  static const Color warningLight = Color(0xFFFEF3C7);
  static const Color error = Color(0xFFEF4444); // Red
  static const Color errorLight = Color(0xFFFEE2E2);
  static const Color errorDarkBg = Color(0xFF2E1717);
  static const Color info = Color(0xFF3B82F6); // Blue
  static const Color infoLight = Color(0xFFEFF6FF);

  // Semantic Driver Application Status Tokens
  static const Color statusOnline = Color(0xFF22C55E); // Active Shift
  static const Color statusOffline = Color(0xFF9CA3AF); // Inactive Shift
  static const Color statusPending =
      Color(0xFFF59E0B); // Verification / Booking Pending
  static const Color statusApproved = Color(0xFF22C55E); // Approved / Confirmed
  static const Color statusRejected = Color(0xFFEF4444); // Rejected / Declined
  static const Color statusActive = Color(0xFF3B82F6); // Trip in progress
  static const Color paymentSuccess = Color(0xFF22C55E);
  static const Color paymentFailure = Color(0xFFEF4444);

  // Light Theme Surfaces & Neutrals
  static const Color backgroundLight =
      Color(0xFFF8F9FA); // Clean Soft Light Gray
  static const Color surfaceLight = Color(0xFFFFFFFF); // Pure White
  static const Color surfaceSubtleLight = Color(0xFFF3F4F6);
  static const Color glassSurfaceLight = Color(0xF5FFFFFF); // 96% opacity white
  static const Color glassBorderLight = Color(0x14000000); // 8% black border
  static const Color borderLight = Color(0xFFE5E7EB); // 1px Subtle Border
  static const Color borderLightHover = Color(0xFFD1D5DB);
  static const Color textPrimaryLight = Color(0xFF1F2937); // Clean Primary Text
  static const Color textSecondaryLight = Color(0xFF6B7280); // Secondary Text
  static const Color textTertiaryLight = Color(0xFF9CA3AF); // Muted Gray

  // Dark Theme Surfaces & Neutrals (Comfortable Slate-Charcoal, not pitch black)
  static const Color backgroundDark =
      Color(0xFF121316); // Eye-friendly Slate Charcoal
  static const Color surfaceDark = Color(0xFF1A1C22); // Card surface
  static const Color surfaceSubtleDark =
      Color(0xFF202228); // Secondary surface & elevated inputs
  static const Color glassSurfaceDark = Color(0xEE1A1C22);
  static const Color glassBorderDark = Color(0x1FFFFFFF);
  static const Color borderDark = Color(0xFF282A30); // Clean 1px dark border
  static const Color borderDarkHover = Color(0xFF3B3E4A);
  static const Color textPrimaryDark =
      Color(0xFFF8F9FA); // Soft Light Gray (not harsh #FFFFFF)
  static const Color textSecondaryDark = Color(0xFF9CA3AF); // Muted Silver
  static const Color textTertiaryDark = Color(0xFF6B7280);

  // Overlays & Utilities
  static const Color overlay = Color(0x80000000);
  static const Color transparent = Colors.transparent;
  static const Color white = Colors.white;
  static const Color black = Colors.black;

  // Rating & Badges
  static const Color starGold = Color(0xFFFFB300);
  static const Color verifiedBadge = Color(0xFFFFC107);

  // Common UI Aliases & Convenience Colors
  static const Color cardBorder = Color(0xFFE5E7EB);
  static const Color cardBorderDark = Color(0xFF282A30);
  static const Color textSecondary = Color(0xFF6B7280);
  static const Color textTertiary = Color(0xFF9CA3AF);
  static const Color darkSurface = Color(0xFF1A1C22);
  static const Color darkCard = Color(0xFF202228);
  static const Color gray50 = Color(0xFFF9FAFB);
  static const Color gray100 = Color(0xFFF3F4F6);
  static const Color gray200 = Color(0xFFE5E7EB);
  static const Color gray300 = Color(0xFFD1D5DB);
  static const Color gray400 = Color(0xFF9CA3AF);
  static const Color gray700 = Color(0xFF374151);
  static const Color gray800 = Color(0xFF1F2937);
  static const Color gray900 = Color(0xFF111827);

  // Taxi Booking UI tokens
  static const Color yandexYellow = Color(0xFFFFC107);
  static const Color yandexBlack = Color(0xFF111111);
  static const Color yandexDarkSurface = Color(0xFF1A1C22);
  static const Color yandexDarkCard = Color(0xFF202228);
  static const Color yandexGreen = Color(0xFF22C55E);
  static const Color yandexRed = Color(0xFFEF4444);

  // Clean Ambient Shadows (Subtle, never overly dark or harsh)
  static final List<BoxShadow> subtleCardShadow = [
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.04),
      blurRadius: 8,
      offset: const Offset(0, 2),
    ),
  ];
}
