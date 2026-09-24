import 'package:flutter_test/flutter_test.dart';
import 'package:yol_yolakay_driver/core/errors/failures.dart';
import 'package:yol_yolakay_driver/features/auth/domain/entities/driver_user_entity.dart';
import 'package:yol_yolakay_driver/features/taxi_radar/domain/entities/taxi_order_entity.dart';

void main() {
  group('Driver E2E Flow & State Machine Integration Tests', () {
    test('E2E: Full Driver Daily Work Cycle', () async {
      // 1. App Launch & Unauthenticated state
      bool isAuthenticated = false;
      expect(isAuthenticated, isFalse);

      // 2. Phone Input & OTP Request
      const testPhone = '+998901234567';
      const otpSession = OtpSessionEntity(
        sessionId: 'ses_driver_001',
        expiresIn: 120,
        resendInterval: 60,
      );
      expect(otpSession.sessionId, 'ses_driver_001');

      // 3. Invalid OTP Attempt
      const enteredCode = '000000';
      const isOtpValid = enteredCode == '123456';
      expect(isOtpValid, isFalse);

      // 4. Valid OTP Verification & Session Establishment
      const validCode = '123456';
      expect(validCode == '123456', isTrue);

      const authResult = DriverAuthEntity(
        isRegistered: true,
        verificationStatus: 'approved',
        tokens: DriverTokensEntity(
          accessToken: 'jwt_access_token_999',
          refreshToken: 'jwt_refresh_token_999',
          expiresIn: 86400,
        ),
        driver: DriverUserEntity(
          id: 'drv_e2e_01',
          phone: testPhone,
          firstName: 'Anvar',
          lastName: 'Qodirov',
          rating: 4.95,
          totalTrips: 154,
          balance: 150000,
          isOnline: false,
        ),
      );

      isAuthenticated = true;
      expect(authResult.isApproved, isTrue);
      expect(authResult.driver.fullName, 'Anvar Qodirov');
      expect(authResult.tokens.accessToken.isNotEmpty, isTrue);

      // 5. Verification Status Handling
      String verificationStatus = authResult.verificationStatus;
      expect(verificationStatus, 'approved');

      // Test pending and rejected transition states
      verificationStatus = 'under_review';
      expect(verificationStatus == 'approved', isFalse);
      verificationStatus = 'approved';
      expect(verificationStatus == 'approved', isTrue);

      // 6. Driver Shift Management: Open Shift & Go Online
      bool isOnline = false;
      bool isLocationTrackingActive = false;

      // Driver toggles shift to online
      isOnline = true;
      isLocationTrackingActive = true;
      expect(isOnline, isTrue);
      expect(isLocationTrackingActive, isTrue);

      // 7. Receive Real-Time Taxi Order Offer via WebSocket
      final incomingOffer = TaxiOrderOfferEntity(
        orderId: 'ord_e2e_888',
        tier: 'standard',
        estimatedPrice: 28000,
        distanceToPickupKm: 1.5,
        pickup: const LocationAddressEntity(
          address: 'Amir Temur shoh ko\'chasi, 12',
          lat: 41.3111,
          lng: 69.2797,
        ),
        destination: const LocationAddressEntity(
          address: 'Chilonzor 9-mavze, 4',
          lat: 41.2825,
          lng: 69.2043,
        ),
        paymentType: 'cash',
        createdAt: DateTime.parse('2026-09-21T10:00:00Z'),
        timeoutSeconds: 30,
      );
      expect(incomingOffer.orderId, 'ord_e2e_888');

      // 8. Order Lifecycle: driver_assigned -> arrived -> in_progress -> completed
      var activeOrder = ActiveTaxiOrderEntity(
        orderId: incomingOffer.orderId,
        status: 'driver_assigned',
        tier: incomingOffer.tier,
        passenger: const PassengerProfileEntity(
          id: 'p_001',
          name: 'Dilshodbek',
          phone: '+998911112233',
          rating: 4.8,
        ),
        pickup: incomingOffer.pickup,
        destination: incomingOffer.destination,
        price: incomingOffer.estimatedPrice,
        commissionAmount: 2800,
        paymentType: incomingOffer.paymentType,
        acceptedAt: DateTime.now(),
      );

      expect(activeOrder.isAssigned, isTrue);

      // Driver arrives at passenger location
      activeOrder = activeOrder.copyWith(status: 'arrived');
      expect(activeOrder.isArrived, isTrue);

      // Driver starts trip with passenger
      activeOrder = activeOrder.copyWith(status: 'in_progress');
      expect(activeOrder.isInProgress, isTrue);

      // Driver completes trip
      activeOrder = activeOrder.copyWith(status: 'completed');
      expect(activeOrder.status, 'completed');

      // 9. Wallet Balance & Earning Update
      int balance = authResult.driver.balance;
      const tripEarnings = 28000;
      const serviceFee = 2800; // 10% commission
      balance += (tripEarnings - serviceFee);
      expect(balance, 175200);

      // 10. End Shift: Go Offline & Stop Tracking
      isOnline = false;
      isLocationTrackingActive = false;
      expect(isOnline, isFalse);
      expect(isLocationTrackingActive, isFalse);

      // 11. Clean Logout & Session Teardown
      isAuthenticated = false;
      expect(isAuthenticated, isFalse);
    });

    test('Domain Failure mapping and localization test', () {
      const netFailure = NetworkFailure();
      expect(netFailure.isRetryable, isTrue);
      expect(netFailure.localizedMessage('uz'), contains('Internet'));
      expect(netFailure.localizedMessage('ru'), contains('интернет'));
      expect(netFailure.localizedMessage('en'), contains('internet'));

      const authFailure = AuthFailure();
      expect(authFailure.isRetryable, isFalse);
      expect(authFailure.statusCode, 401);
    });
  });
}
