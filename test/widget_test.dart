import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:yol_yolakay_driver/core/di/injection.dart';
import 'package:yol_yolakay_driver/driver_app.dart';

void main() {
  testWidgets('Driver App initializes without crashing',
      (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({
      'theme_mode': 'dark',
      'app_locale': 'uz',
      'has_selected_language': true,
      'user_role': 'driver',
    });

    await configureDependencies();

    await tester.pumpWidget(const YolYolakayDriverApp());

    await tester.pump(const Duration(milliseconds: 500));
    expect(find.byType(YolYolakayDriverApp), findsOneWidget);
  });
}
