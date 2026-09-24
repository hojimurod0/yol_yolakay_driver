import 'dart:convert';
import 'dart:io';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Localization Key Parity Test', () {
    test(
        'app_uz.arb, app_ru.arb, and app_en.arb must have identical translation keys',
        () {
      final uzFile = File('lib/l10n/app_uz.arb');
      final ruFile = File('lib/l10n/app_ru.arb');
      final enFile = File('lib/l10n/app_en.arb');

      expect(uzFile.existsSync(), isTrue, reason: 'app_uz.arb must exist');
      expect(ruFile.existsSync(), isTrue, reason: 'app_ru.arb must exist');
      expect(enFile.existsSync(), isTrue, reason: 'app_en.arb must exist');

      final uzMap =
          jsonDecode(uzFile.readAsStringSync()) as Map<String, dynamic>;
      final ruMap =
          jsonDecode(ruFile.readAsStringSync()) as Map<String, dynamic>;
      final enMap =
          jsonDecode(enFile.readAsStringSync()) as Map<String, dynamic>;

      final uzKeys = uzMap.keys.where((k) => !k.startsWith('@')).toSet();
      final ruKeys = ruMap.keys.where((k) => !k.startsWith('@')).toSet();
      final enKeys = enMap.keys.where((k) => !k.startsWith('@')).toSet();

      final missingInRu = uzKeys.difference(ruKeys);
      final missingInEn = uzKeys.difference(enKeys);
      final extraInRu = ruKeys.difference(uzKeys);
      final extraInEn = enKeys.difference(uzKeys);

      expect(missingInRu, isEmpty,
          reason: 'Keys present in uz but missing in ru: $missingInRu');
      expect(missingInEn, isEmpty,
          reason: 'Keys present in uz but missing in en: $missingInEn');
      expect(extraInRu, isEmpty,
          reason: 'Keys present in ru but missing in uz: $extraInRu');
      expect(extraInEn, isEmpty,
          reason: 'Keys present in en but missing in uz: $extraInEn');

      expect(uzKeys.length, ruKeys.length);
      expect(uzKeys.length, enKeys.length);
    });
  });
}
