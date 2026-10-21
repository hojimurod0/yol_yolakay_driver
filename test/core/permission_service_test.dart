import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:yol_yolakay_driver/core/services/location_service.dart';
import 'package:yol_yolakay_driver/core/services/permission_service.dart';

class MockLocationService extends LocationService {
  LocationPermissionStatus returnStatus = LocationPermissionStatus.granted;

  @override
  Future<LocationPermissionStatus> checkAndRequestPermission() async {
    return returnStatus;
  }
}

void main() {
  group('PermissionService Tests', () {
    late MockLocationService mockLocation;
    late PermissionService service;

    setUp(() {
      mockLocation = MockLocationService();
      service = PermissionService(locationService: mockLocation);
    });

    test(
        'checkStatus maps LocationPermissionStatus.granted to AppPermissionStatus.granted',
        () async {
      mockLocation.returnStatus = LocationPermissionStatus.granted;
      final status =
          await service.checkStatus(AppPermissionType.foregroundLocation);
      expect(status, equals(AppPermissionStatus.granted));
    });

    test(
        'checkStatus maps LocationPermissionStatus.denied to AppPermissionStatus.denied',
        () async {
      mockLocation.returnStatus = LocationPermissionStatus.denied;
      final status =
          await service.checkStatus(AppPermissionType.foregroundLocation);
      expect(status, equals(AppPermissionStatus.denied));
    });

    test(
        'checkStatus maps LocationPermissionStatus.permanentlyDenied to AppPermissionStatus.permanentlyDenied',
        () async {
      mockLocation.returnStatus = LocationPermissionStatus.permanentlyDenied;
      final status =
          await service.checkStatus(AppPermissionType.foregroundLocation);
      expect(status, equals(AppPermissionStatus.permanentlyDenied));
    });

    test(
        'checkStatus maps LocationPermissionStatus.serviceDisabled to AppPermissionStatus.serviceDisabled',
        () async {
      mockLocation.returnStatus = LocationPermissionStatus.serviceDisabled;
      final status =
          await service.checkStatus(AppPermissionType.foregroundLocation);
      expect(status, equals(AppPermissionStatus.serviceDisabled));
    });

    testWidgets(
        'showPermissionRationaleDialog renders title, content, and handles buttons',
        (tester) async {
      bool? dialogResult;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (ctx) => ElevatedButton(
                onPressed: () async {
                  dialogResult = await service.showPermissionRationaleDialog(
                    context: ctx,
                    title: 'Lokatsiya ruxsati',
                    explanation:
                        'Buyurtmalarni olish uchun lokatsiyani yoqing.',
                  );
                },
                child: const Text('Open Dialog'),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Open Dialog'));
      await tester.pumpAndSettle();

      expect(find.text('Lokatsiya ruxsati'), findsOneWidget);
      expect(find.text('Buyurtmalarni olish uchun lokatsiyani yoqing.'),
          findsOneWidget);

      await tester.tap(find.text('Ruxsat berish'));
      await tester.pumpAndSettle();

      expect(dialogResult, isTrue);
    });

    test('validateCanGoOnline returns unauthenticated when not logged in',
        () async {
      final reason = await service.validateCanGoOnline(
        isAuthenticated: false,
        verificationStatus: 'approved',
      );
      expect(reason, equals(CannotGoOnlineReason.unauthenticated));
    });

    test(
        'validateCanGoOnline returns accountBlocked when driver is suspended or blocked',
        () async {
      final reasonBlocked = await service.validateCanGoOnline(
        isAuthenticated: true,
        verificationStatus: 'blocked',
      );
      expect(reasonBlocked, equals(CannotGoOnlineReason.accountBlocked));

      final reasonSuspended = await service.validateCanGoOnline(
        isAuthenticated: true,
        verificationStatus: 'suspended',
      );
      expect(reasonSuspended, equals(CannotGoOnlineReason.accountBlocked));
    });

    test(
        'validateCanGoOnline returns verificationRequired when status is pending_submission',
        () async {
      final reasonPending = await service.validateCanGoOnline(
        isAuthenticated: true,
        verificationStatus: 'pending_submission',
      );
      expect(reasonPending, equals(CannotGoOnlineReason.verificationRequired));
    });
  });
}
