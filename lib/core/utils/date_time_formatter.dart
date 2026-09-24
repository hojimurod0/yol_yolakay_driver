import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../localization/app_localizations_helper.dart';

/// Centralized Date & Time Formatter with localization support.
abstract class AppDateTimeFormatter {
  static String formatTime(DateTime dateTime) {
    return DateFormat('HH:mm').format(dateTime);
  }

  static String formatDate(DateTime dateTime, {String locale = 'ru'}) {
    return DateFormat('d MMMM', locale).format(dateTime);
  }

  static String formatDateWithYear(DateTime dateTime, {String locale = 'ru'}) {
    return DateFormat('d MMMM yyyy', locale).format(dateTime);
  }

  static String formatRelativeDate(BuildContext context, DateTime dateTime) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final target = DateTime(dateTime.year, dateTime.month, dateTime.day);
    final differenceInDays = target.difference(today).inDays;

    final l10n = context.l10n;
    if (differenceInDays == 0) {
      return l10n.today;
    } else if (differenceInDays == 1) {
      return l10n.tomorrow;
    } else {
      final locale = Localizations.localeOf(context).languageCode;
      return DateFormat('d MMM', locale).format(dateTime);
    }
  }

  static String formatDuration(Duration duration, {String locale = 'ru'}) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);

    if (locale == 'ru') {
      if (minutes == 0) {
        return '$hours ч';
      }
      return '$hours ч $minutes мин';
    } else if (locale == 'uz') {
      if (minutes == 0) {
        return '$hours soat';
      }
      return '$hours soat $minutes daq';
    }

    if (minutes == 0) {
      return '$hours h';
    }
    return '${hours}h ${minutes}m';
  }
}
