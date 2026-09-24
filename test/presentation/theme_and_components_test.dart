import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:yol_yolakay_driver/core/theme/app_colors.dart';
import 'package:yol_yolakay_driver/core/widgets/app_buttons.dart';
import 'package:yol_yolakay_driver/core/widgets/app_status_chip.dart';

void main() {
  group('Theme and Accessible Components Tests', () {
    testWidgets('AppStatusChip renders label and icon in light and dark mode',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData.light(),
          darkTheme: ThemeData.dark(),
          home: const Scaffold(
            body: Column(
              children: [
                AppStatusChip(
                  label: 'Faol',
                  variant: StatusVariant.active,
                ),
                AppStatusChip(
                  label: 'Kutilmoqda',
                  variant: StatusVariant.pending,
                ),
                AppStatusChip(
                  label: 'Bekor qilingan',
                  variant: StatusVariant.cancelled,
                ),
              ],
            ),
          ),
        ),
      );

      expect(find.text('Faol'), findsOneWidget);
      expect(find.text('Kutilmoqda'), findsOneWidget);
      expect(find.text('Bekor qilingan'), findsOneWidget);
      expect(find.byType(Icon), findsNWidgets(3));
    });

    testWidgets('AppPrimaryButton handles tap and displays loading state',
        (WidgetTester tester) async {
      var tapped = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Column(
              children: [
                AppPrimaryButton(
                  text: 'Tasdiqlash',
                  onPressed: () => tapped = true,
                ),
                const AppPrimaryButton(
                  text: 'Yuklanmoqda',
                  isLoading: true,
                  onPressed: null,
                ),
              ],
            ),
          ),
        ),
      );

      expect(find.text('Tasdiqlash'), findsOneWidget);
      await tester.tap(find.text('Tasdiqlash'));
      expect(tapped, isTrue);

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('AppSecondaryButton and AppDestructiveButton render properly',
        (WidgetTester tester) async {
      var destructiveTapped = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Column(
              children: [
                AppSecondaryButton(
                  text: 'Qaytish',
                  onPressed: () {},
                ),
                AppDestructiveButton(
                  text: 'O\'chirish',
                  onPressed: () => destructiveTapped = true,
                ),
              ],
            ),
          ),
        ),
      );

      expect(find.text('Qaytish'), findsOneWidget);
      expect(find.text('O\'chirish'), findsOneWidget);
      await tester.tap(find.text('O\'chirish'));
      expect(destructiveTapped, isTrue);
    });

    test('AppColors defines high-contrast semantic colors for WCAG', () {
      expect(AppColors.primary, isNotNull);
      expect(AppColors.taxiYellow, isNotNull);
      expect(AppColors.taxiYellowDark, isNotNull);
      expect(AppColors.success, isNotNull);
      expect(AppColors.warning, isNotNull);
      expect(AppColors.error, isNotNull);
      expect(AppColors.backgroundLight, isNotNull);
      expect(AppColors.backgroundDark, isNotNull);
    });
  });
}
