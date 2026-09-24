import 'package:flutter_test/flutter_test.dart';
import 'package:yol_yolakay_driver/core/services/feature_flag_service.dart';

void main() {
  group('FeatureFlagService Tests', () {
    late FeatureFlagServiceImpl service;

    setUp(() {
      service = FeatureFlagServiceImpl();
    });

    test('returns true for default critical flags', () {
      expect(service.taxiRadarEnabled, isTrue);
      expect(service.intercityEnabled, isTrue);
      expect(service.walletTopupEnabled, isTrue);
      expect(service.paymeEnabled, isTrue);
      expect(service.clickEnabled, isTrue);
      expect(service.uzumEnabled, isTrue);
      expect(service.reviewsEnabled, isTrue);
      expect(service.supportChatEnabled, isTrue);
      expect(service.newRadarAlgorithmEnabled, isTrue);
    });

    test('returns defaultValue when flag key is unknown', () {
      expect(
          service.isEnabled('non_existent_flag', defaultValue: false), isFalse);
      expect(
          service.isEnabled('non_existent_flag', defaultValue: true), isTrue);
    });

    test('initialize runs safely without crashing on null or failing backend',
        () async {
      await expectLater(service.initialize(), completes);
    });
  });
}
