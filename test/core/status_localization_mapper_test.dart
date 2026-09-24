import 'package:flutter_test/flutter_test.dart';
import 'package:yol_yolakay_driver/core/utils/status_localization_mapper.dart';
import 'package:yol_yolakay_driver/core/widgets/app_status_chip.dart';

void main() {
  group('StatusLocalizationMapper Tests', () {
    test('maps all backend status strings across uz, ru, and en', () {
      // Pending
      expect(StatusLocalizationMapper.mapStatus('pending', locale: 'uz'),
          'Kutilmoqda');
      expect(StatusLocalizationMapper.mapStatus('pending', locale: 'ru'),
          'Ожидается');
      expect(StatusLocalizationMapper.mapStatus('pending', locale: 'en'),
          'Pending');
      expect(StatusLocalizationMapper.mapVariant('pending'),
          StatusVariant.pending);

      // Approved / Confirmed
      expect(StatusLocalizationMapper.mapStatus('approved', locale: 'uz'),
          'Tasdiqlangan');
      expect(StatusLocalizationMapper.mapStatus('confirmed', locale: 'ru'),
          'Подтверждено');
      expect(StatusLocalizationMapper.mapVariant('approved'),
          StatusVariant.approved);

      // Completed
      expect(StatusLocalizationMapper.mapStatus('completed', locale: 'uz'),
          'Yakunlangan');
      expect(StatusLocalizationMapper.mapStatus('completed', locale: 'en'),
          'Completed');
      expect(StatusLocalizationMapper.mapVariant('completed'),
          StatusVariant.completed);

      // Cancelled
      expect(StatusLocalizationMapper.mapStatus('cancelled', locale: 'uz'),
          'Bekor qilingan');
      expect(StatusLocalizationMapper.mapStatus('cancelled', locale: 'ru'),
          'Отменено');
      expect(StatusLocalizationMapper.mapVariant('cancelled'),
          StatusVariant.cancelled);

      // In Progress / Active
      expect(
          StatusLocalizationMapper.mapStatus('active', locale: 'uz'), 'Faol');
      expect(
          StatusLocalizationMapper.mapVariant('active'), StatusVariant.active);
      expect(StatusLocalizationMapper.mapVariant('in_progress'),
          StatusVariant.inProgress);

      // Rejected
      expect(StatusLocalizationMapper.mapStatus('rejected', locale: 'uz'),
          'Rad etilgan');
      expect(StatusLocalizationMapper.mapVariant('rejected'),
          StatusVariant.rejected);
    });
  });
}
