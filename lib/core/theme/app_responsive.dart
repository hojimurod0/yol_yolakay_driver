import 'package:flutter/material.dart';

/// Responsive helper providing standard screen breakpoints and responsive design utilities.
abstract class AppResponsive {
  /// Breakpoint below which screens are treated as small phones (e.g. iPhone SE, compact Androids).
  static const double smallPhoneBreakpoint = 360.0;

  /// Breakpoint above which screens are treated as tablets or foldables.
  static const double tabletBreakpoint = 600.0;

  /// Max comfortable width for cards and content in central columns.
  static const double maxContentWidth = 560.0;

  /// True if the current device width is less than 360 logical pixels.
  static bool isSmallPhone(BuildContext context) =>
      MediaQuery.sizeOf(context).width < smallPhoneBreakpoint;

  /// True if the current device is a tablet or desktop width (>= 600 logical pixels).
  static bool isTablet(BuildContext context) =>
      MediaQuery.sizeOf(context).width >= tabletBreakpoint;

  /// Logical screen width.
  static double width(BuildContext context) =>
      MediaQuery.sizeOf(context).width;

  /// Logical screen height.
  static double height(BuildContext context) =>
      MediaQuery.sizeOf(context).height;

  /// Responsive horizontal padding: compact on small phones (12), standard on phones (16), roomy on tablets (24).
  static double horizontalPadding(BuildContext context) {
    final w = MediaQuery.sizeOf(context).width;
    if (w < smallPhoneBreakpoint) return 12.0;
    if (w >= tabletBreakpoint) return 24.0;
    return 16.0;
  }
}
