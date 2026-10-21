/// Centralized typographic scale for font sizes across the YolYolakay application.
/// Provides a unified, predictable scale so text sizes are consistent across all screens.
abstract class AppTextSizes {
  /// 10.0 - Micro annotations, license plate subscripts
  static const double xxs = 10.0;

  /// 11.0 - Small badges, subtle status text, caption pills
  static const double xs = 11.0;

  /// 12.0 - Secondary labels, timestamps, secondary body text
  static const double sm = 12.0;

  /// 13.0 - Compact body text, dense list subtitles
  static const double compact = 13.0;

  /// 14.0 - Standard body text, form field labels, secondary headers
  static const double md = 14.0;

  /// 15.0 - Card subtitles, emphasis body text, list item titles
  static const double base = 15.0;

  /// 16.0 - Section headers, button text, card primary titles
  static const double lg = 16.0;

  /// 18.0 - Highlighted prices, dialog titles, prominent headlines
  static const double xl = 18.0;

  /// 20.0 - Screen headers, modal titles, route highlights
  static const double xxl = 20.0;

  /// 22.0 - Top page titles, boarding pass headers
  static const double title = 22.0;

  /// 26.0 - Display headers, hero counters
  static const double display = 26.0;
}
