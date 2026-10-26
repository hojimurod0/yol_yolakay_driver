import 'package:flutter_test/flutter_test.dart';
import 'package:yol_yolakay_driver/features/auth/domain/entities/driver_user_entity.dart';
import 'package:yol_yolakay_driver/features/auth/presentation/pages/pilot_auth_pages.dart';

DriverAuthEntity _auth(String status) => DriverAuthEntity(
      isRegistered: true,
      verificationStatus: status,
      tokens: const DriverTokensEntity(
          accessToken: 'a', refreshToken: 'r', expiresIn: 3600),
      driver: const DriverUserEntity(
        id: 'd1',
        phone: '+998934567890',
        firstName: 'Akmal',
        lastName: 'K',
        rating: 4.9,
        totalTrips: 10,
        balance: 0,
        isOnline: false,
        role: 'driver',
      ),
    );

void main() {
  test('new or rejected drivers go to documents, others go home', () {
    expect(PilotDriverOtpPage.nextRouteFor(_auth('pending_submission')),
        '/verification');
    expect(PilotDriverOtpPage.nextRouteFor(_auth('rejected')), '/verification');
    expect(PilotDriverOtpPage.nextRouteFor(_auth('under_review')),
        '/driver/home');
    expect(PilotDriverOtpPage.nextRouteFor(_auth('approved')), '/driver/home');
  });

  test('phone formatter groups digits and drops +998', () {
    String f(String s) => UzPhoneFormatter()
        .formatEditUpdate(TextEditingValue.empty, TextEditingValue(text: s))
        .text;
    expect(f('934567890'), '93 456 78 90');
    expect(f('+998 93 456 78 90'), '93 456 78 90');
  });
}
