import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:yol_yolakay_driver/core/utils/app_date_formatter.dart';

void main() {
  setUpAll(() async {
    await initializeDateFormatting('uz', null);
    await initializeDateFormatting('ru', null);
    await initializeDateFormatting('en', null);
  });

  group('AppDateFormatter Tests', () {
    final testDate = DateTime(2026, 9, 21, 14, 30);

    test('formatFullDate formats correctly for uz, ru, and en', () {
      final uzDate = AppDateFormatter.formatFullDate(testDate, locale: 'uz');
      final ruDate = AppDateFormatter.formatFullDate(testDate, locale: 'ru');
      final enDate = AppDateFormatter.formatFullDate(testDate, locale: 'en');

      expect(uzDate, contains('21'));
      expect(ruDate, contains('21'));
      expect(enDate, contains('21'));
      expect(enDate, contains('2026'));
    });

    test('formatTime returns HH:mm 24-hour time', () {
      final timeStr = AppDateFormatter.formatTime(testDate);
      expect(timeStr, '14:30');
    });

    test('formatShortDate returns d MMM format', () {
      final uzShort = AppDateFormatter.formatShortDate(testDate, locale: 'uz');
      final ruShort = AppDateFormatter.formatShortDate(testDate, locale: 'ru');
      expect(uzShort, contains('21'));
      expect(ruShort, contains('21'));
    });

    test('formatDateTime combines date and time', () {
      final uzCombined =
          AppDateFormatter.formatDateTime(testDate, locale: 'uz');
      expect(uzCombined, contains('14:30'));
    });

    test('formatRelative returns relative times for recent and older events',
        () {
      final now = DateTime.now();
      expect(AppDateFormatter.formatRelative(now, locale: 'uz'), 'Hozirgina');
      expect(AppDateFormatter.formatRelative(now, locale: 'ru'), 'Только что');
      expect(AppDateFormatter.formatRelative(now, locale: 'en'), 'Just now');

      final fiveMinsAgo = now.subtract(const Duration(minutes: 5));
      expect(AppDateFormatter.formatRelative(fiveMinsAgo, locale: 'uz'),
          '5 daqiqa oldin');

      final pastDate = DateTime(2025, 1, 1);
      final pastStr = AppDateFormatter.formatRelative(pastDate, locale: 'en');
      expect(pastStr, isNotEmpty);
    });
  });
}
