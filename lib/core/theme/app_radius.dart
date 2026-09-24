import 'package:flutter/material.dart';

/// Centralized border radii tokens for cards, buttons, modals, and chips.
abstract class AppRadius {
  static const double xs = 4.0;
  static const double sm = 8.0;
  static const double md = 12.0;
  static const double lg = 16.0;
  static const double xl = 20.0;
  static const double xxl = 24.0;
  static const double pill = 999.0;

  static const Radius radiusXs = Radius.circular(xs);
  static const Radius radiusSm = Radius.circular(sm);
  static const Radius radiusMd = Radius.circular(md);
  static const Radius radiusLg = Radius.circular(lg);
  static const Radius radiusXl = Radius.circular(xl);
  static const Radius radiusXxl = Radius.circular(xxl);
  static const Radius radiusPill = Radius.circular(pill);

  static const BorderRadius borderXs = BorderRadius.all(radiusXs);
  static const BorderRadius borderSm = BorderRadius.all(radiusSm);
  static const BorderRadius borderMd = BorderRadius.all(radiusMd);
  static const BorderRadius borderLg = BorderRadius.all(radiusLg);
  static const BorderRadius borderXl = BorderRadius.all(radiusXl);
  static const BorderRadius borderXxl = BorderRadius.all(radiusXxl);
  static const BorderRadius borderPill = BorderRadius.all(radiusPill);

  static const BorderRadius topMd = BorderRadius.vertical(top: radiusMd);
  static const BorderRadius topLg = BorderRadius.vertical(top: radiusLg);
  static const BorderRadius topXl = BorderRadius.vertical(top: radiusXl);
  static const BorderRadius topXxl = BorderRadius.vertical(top: radiusXxl);
}
