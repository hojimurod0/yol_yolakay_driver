import 'package:intl/intl.dart';

/// Centralized, locale-aware date and time formatting utility.
abstract class AppDateFormatter {
  /// Formats date into localized day and month (e.g., "19 sen", "19 сен.", "Sep 19")
  static String formatShortDate(DateTime date, {String locale = 'uz'}) {
    final intlLocale = _resolveIntlLocale(locale);
    return DateFormat('d MMM', intlLocale).format(date);
  }

  /// Formats date into localized full format (e.g., "19-sentabr, 2026", "19 сентября 2026 г.")
  static String formatFullDate(DateTime date, {String locale = 'uz'}) {
    final intlLocale = _resolveIntlLocale(locale);
    return DateFormat.yMMMMd(intlLocale).format(date);
  }

  /// Formats time in 24-hour HH:mm format
  static String formatTime(DateTime date) {
    return DateFormat('HH:mm').format(date);
  }

  /// Formats both date and time (e.g., "19 sen, 14:30")
  static String formatDateTime(DateTime date, {String locale = 'uz'}) {
    final intlLocale = _resolveIntlLocale(locale);
    return '${DateFormat('d MMM', intlLocale).format(date)}, ${DateFormat('HH:mm').format(date)}';
  }

  /// Formats relative time (e.g., "Hozirgina", "5 daqiqa oldin", "5 минут назад", "5 minutes ago")
  static String formatRelative(DateTime date, {String locale = 'uz'}) {
    final difference = DateTime.now().difference(date);

    if (difference.inSeconds < 60) {
      return switch (locale) {
        'ru' => 'Только что',
        'en' => 'Just now',
        _ => 'Hozirgina',
      };
    }

    if (difference.inMinutes < 60) {
      final mins = difference.inMinutes;
      return switch (locale) {
        'ru' => '$mins мин. назад',
        'en' => '$mins min ago',
        _ => '$mins daqiqa oldin',
      };
    }

    if (difference.inHours < 24) {
      final hours = difference.inHours;
      return switch (locale) {
        'ru' => '$hours ч. назад',
        'en' => '$hours h ago',
        _ => '$hours soat oldin',
      };
    }

    return formatShortDate(date, locale: locale);
  }

  static String _resolveIntlLocale(String locale) {
    return switch (locale) {
      'ru' => 'ru_RU',
      'en' => 'en_US',
      _ => 'uz_UZ',
    };
  }
}
