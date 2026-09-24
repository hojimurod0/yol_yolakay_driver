import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:yol_yolakay_driver/core/theme/app_colors.dart';
import 'package:yol_yolakay_driver/core/widgets/app_buttons.dart';
import 'package:yol_yolakay_driver/core/widgets/app_status_chip.dart';

void main() {
  group(
      'Responsive and High Text Scale Tests (320px narrow screens & 1.5x scale)',
      () {
    testWidgets(
        'Renders buttons without overflow on narrow 320px screen with 1.5x text scaling',
        (tester) async {
      tester.view.physicalSize = const Size(320 * 2.0, 640 * 2.0);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData.light(),
          darkTheme: ThemeData.dark(),
          home: MediaQuery(
            data: const MediaQueryData(
              size: Size(320, 640),
              textScaler: TextScaler.linear(1.5),
            ),
            child: Scaffold(
              body: Padding(
                padding: const EdgeInsets.all(16),
                child: ListView(
                  children: [
                    const Text(
                      'Haydovchi tizimi',
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 12),
                    const Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        AppStatusChip(
                            label: 'Faol', variant: StatusVariant.active),
                        AppStatusChip(
                            label: 'Kutilmoqda',
                            variant: StatusVariant.pending),
                        AppStatusChip(
                            label: 'Bekor qilingan',
                            variant: StatusVariant.cancelled),
                      ],
                    ),
                    const SizedBox(height: 16),
                    AppPrimaryButton(
                      text: 'Buyurtmani qabul qilish',
                      onPressed: () {},
                    ),
                    const SizedBox(height: 8),
                    AppSecondaryButton(
                      text: 'Rad etish',
                      onPressed: () {},
                    ),
                    const SizedBox(height: 8),
                    AppDestructiveButton(
                      text: 'Hisobni o\'chirish',
                      onPressed: () {},
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Haydovchi tizimi'), findsOneWidget);
      expect(find.text('Buyurtmani qabul qilish'), findsOneWidget);
      expect(tester.takeException(), isNull); // No RenderFlex overflow
    });

    testWidgets(
        'Renders modal dialogs without overflow in Dark mode and English locale',
        (tester) async {
      tester.view.physicalSize = const Size(320 * 2.0, 640 * 2.0);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData.dark(),
          home: MediaQuery(
            data: const MediaQueryData(
              size: Size(320, 640),
              textScaler: TextScaler.linear(1.3),
            ),
            child: Scaffold(
              body: Center(
                child: Container(
                  width: 280,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceDark,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.location_on,
                          color: AppColors.taxiYellow, size: 36),
                      const SizedBox(height: 8),
                      const Text(
                        'Location Permission Required',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Background location is required to receive taxi orders when screen is locked.',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 12),
                      ),
                      const SizedBox(height: 16),
                      AppPrimaryButton(
                        text: 'Allow in Settings',
                        onPressed: () {},
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Location Permission Required'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  });
}
