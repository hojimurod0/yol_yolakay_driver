import 'package:flutter_test/flutter_test.dart';
import 'package:yol_yolakay_driver/core/services/force_update_service.dart';

void main() {
  group('ForceUpdateService Semantic Version Tests', () {
    test('compares semantic versions correctly', () {
      expect(ForceUpdateService.compareSemanticVersion('1.0.0', '1.0.0'),
          equals(0));
      expect(ForceUpdateService.compareSemanticVersion('1.0.1', '1.0.0'),
          equals(1));
      expect(ForceUpdateService.compareSemanticVersion('1.0.0', '1.0.1'),
          equals(-1));
      expect(ForceUpdateService.compareSemanticVersion('1.2.0', '1.1.9'),
          equals(1));
      expect(ForceUpdateService.compareSemanticVersion('2.0.0', '1.9.9'),
          equals(1));
      expect(ForceUpdateService.compareSemanticVersion('1.0.0+1', '1.0.0+2'),
          equals(0));
    });

    test('evaluates required update when current version is below minimum', () {
      final service = ForceUpdateService();
      const policy = ForceUpdatePolicy(
        minimumSupportedVersion: '1.2.0',
        latestVersion: '1.3.0',
        forceUpdate: false,
      );

      final result =
          service.checkUpdateRequirement(policy, currentVersion: '1.1.0');
      expect(result, equals(UpdateRequirement.required));
    });

    test(
        'evaluates required update when forceUpdate is true and current < latest',
        () {
      final service = ForceUpdateService();
      const policy = ForceUpdatePolicy(
        minimumSupportedVersion: '1.0.0',
        latestVersion: '1.2.0',
        forceUpdate: true,
      );

      final result =
          service.checkUpdateRequirement(policy, currentVersion: '1.1.0');
      expect(result, equals(UpdateRequirement.required));
    });

    test(
        'evaluates optional update when current >= minimum but < latest and forceUpdate is false',
        () {
      final service = ForceUpdateService();
      const policy = ForceUpdatePolicy(
        minimumSupportedVersion: '1.0.0',
        latestVersion: '1.2.0',
        forceUpdate: false,
      );

      final result =
          service.checkUpdateRequirement(policy, currentVersion: '1.1.0');
      expect(result, equals(UpdateRequirement.optional));
    });

    test('evaluates none when current == latest or higher', () {
      final service = ForceUpdateService();
      const policy = ForceUpdatePolicy(
        minimumSupportedVersion: '1.0.0',
        latestVersion: '1.2.0',
        forceUpdate: false,
      );

      final result =
          service.checkUpdateRequirement(policy, currentVersion: '1.2.0');
      expect(result, equals(UpdateRequirement.none));
    });
  });
}
