import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:yol_yolakay_driver/core/di/injection_container.dart';
import 'package:yol_yolakay_driver/core/network/network_info_provider.dart';
import 'package:yol_yolakay_driver/core/providers/core_providers.dart';
import 'package:yol_yolakay_driver/driver_app.dart';

void main() {
  setUpAll(() {
    sl.init();
  });

  testWidgets('Driver App initializes without crashing',
      (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({
      'theme_mode': 'dark',
      'app_locale': 'uz',
      'has_selected_language': true,
      'user_role': 'driver',
    });

    final prefs = await SharedPreferences.getInstance();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(prefs),
          networkStatusProvider.overrideWith(
              (ref) => NetworkConnectivityNotifier(autoInit: false)),
        ],
        child: const YolYolakayDriverApp(),
      ),
    );

    // Pump past the splash delay to settle all timers
    await tester.pump(const Duration(seconds: 3));
    await tester.pump(const Duration(milliseconds: 500));

    expect(find.byType(YolYolakayDriverApp), findsOneWidget);
  });
}
