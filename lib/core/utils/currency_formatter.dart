import 'package:intl/intl.dart';

/// Centralized currency formatter for Uzbek Sum with space separators:
/// "120 000 so'm" (Latin), "120 000 сўм" (Cyrillic), "120 000 сум" (Russian).
abstract class AppCurrencyFormatter {
  static final NumberFormat _formatter = NumberFormat('#,###', 'ru_RU');

  /// App language tag (`uz`, `uz_Cyrl`, `ru`, `en`), kept in sync by
  /// LocaleCubit so callers that pass no locale follow the UI language.
  static String currentLocale = 'uz';

  static String _symbol(String locale) => switch (locale) {
        'en' => 'UZS',
        'uz' => 'so\'m',
        'uz_Cyrl' => 'сўм',
        _ => 'сум',
      };

  static String format(int amount, {String? locale}) {
    final formattedNumber = _formatter
        .format(amount)
        .replaceAll(',', ' ')
        .replaceAll(String.fromCharCode(0xA0), ' ');
    return '$formattedNumber ${_symbol(locale ?? currentLocale)}';
  }

  static String formatShort(int amount, {String? locale}) {
    final tag = locale ?? currentLocale;
    final currencySymbol = _symbol(tag);
    final mlnSuffix = switch (tag) {
      'en' || 'uz' => 'mln',
      _ => 'млн',
    };
    final thousandSuffix = switch (tag) {
      'en' => 'k',
      'uz' => 'ming',
      'uz_Cyrl' => 'минг',
      _ => 'тыс.',
    };

    if (amount >= 1000000) {
      final millions = (amount / 1000000).toStringAsFixed(1);
      return '${millions.endsWith('.0') ? millions.substring(0, millions.length - 2) : millions} $mlnSuffix $currencySymbol';
    }
    if (amount >= 1000) {
      final thousands = (amount / 1000).toStringAsFixed(0);
      return '$thousands $thousandSuffix $currencySymbol';
    }
    return format(amount, locale: tag);
  }
}
