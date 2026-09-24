import 'package:intl/intl.dart';

/// Centralized currency formatter for Uzbek Sum with space separators.
/// In Russian/Cyrillic mode, formats as "120 000 сум" (no Latin characters like UZS).
abstract class AppCurrencyFormatter {
  static final NumberFormat _formatter = NumberFormat('#,###', 'ru_RU');

  static String format(int amount, {String locale = 'ru'}) {
    final formattedNumber = _formatter
        .format(amount)
        .replaceAll(',', ' ')
        .replaceAll('\u00A0', ' ');
    final currencySymbol =
        locale == 'en' ? 'UZS' : (locale == 'uz' ? 'so\'m' : 'сум');
    return '$formattedNumber $currencySymbol';
  }

  static String formatShort(int amount, {String locale = 'ru'}) {
    final currencySymbol =
        locale == 'en' ? 'UZS' : (locale == 'uz' ? 'so\'m' : 'сум');
    final mlnSuffix = locale == 'en' ? 'mln' : (locale == 'uz' ? 'mln' : 'млн');
    final thousandSuffix =
        locale == 'en' ? 'k' : (locale == 'uz' ? 'ming' : 'тыс.');

    if (amount >= 1000000) {
      final millions = (amount / 1000000).toStringAsFixed(1);
      return '${millions.endsWith('.0') ? millions.substring(0, millions.length - 2) : millions} $mlnSuffix $currencySymbol';
    }
    if (amount >= 1000) {
      final thousands = (amount / 1000).toStringAsFixed(0);
      return '$thousands $thousandSuffix $currencySymbol';
    }
    return format(amount, locale: locale);
  }
}
