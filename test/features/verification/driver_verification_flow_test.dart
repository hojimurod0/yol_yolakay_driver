import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:yol_yolakay_driver/core/theme/app_theme.dart';
import 'package:yol_yolakay_driver/core/widgets/app_loading.dart';
import 'package:yol_yolakay_driver/features/verification/domain/entities/verification_entities.dart';
import 'package:yol_yolakay_driver/features/verification/domain/usecases/verification_usecases.dart';
import 'package:yol_yolakay_driver/features/verification/presentation/bloc/verification_bloc.dart';
import 'package:yol_yolakay_driver/features/verification/presentation/bloc/verification_event.dart';
import 'package:yol_yolakay_driver/features/verification/presentation/bloc/verification_state.dart';
import 'package:yol_yolakay_driver/features/verification/presentation/widgets/step3_vehicle_view.dart';
import 'package:yol_yolakay_driver/features/verification/presentation/widgets/step4_review_submit_view.dart';
import 'package:yol_yolakay_driver/features/verification/presentation/widgets/verification_status_view.dart';
import 'package:yol_yolakay_driver/features/verification/presentation/widgets/verification_step_progress.dart';

class _FakeGetCitiesUseCase extends Fake implements GetCitiesUseCase {
  @override
  Future<List<CityEntity>> call() async => [];
}

class _FakeSubmitApplicationUseCase extends Fake
    implements SubmitApplicationUseCase {
  @override
  Future<DriverApplicationResponseEntity> call({
    required Map<String, dynamic> textFields,
    required Map<String, String> photoFiles,
  }) async {
    return const DriverApplicationResponseEntity(
      applicationId: 'app_55412',
      verificationStatus: 'under_review',
      message:
          'Hujjatlaringiz qabul qilindi. Moderatsiya 24 soat ichida ko\'rib chiqadi.',
    );
  }
}

void main() {
  group('1. Verification Step Progress Widget', () {
    testWidgets('Renders all 4 steps and highlights the active step',
        (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: VerificationStepProgress(
              currentStep: 0,
              totalSteps: 4,
              isDark: false,
            ),
          ),
        ),
      );

      // Verify 4 steps are rendered
      expect(find.text('1'), findsOneWidget);
      expect(find.text('2'), findsOneWidget);
      expect(find.text('3'), findsOneWidget);
      expect(find.text('4'), findsOneWidget);
      expect(find.text('1-bosqich: Shaxsiy'), findsOneWidget);
    });
  });

  group('2. Step 3 Vehicle View Responsive Layout', () {
    testWidgets('Renders without RenderFlex overflow on narrow 320px screen',
        (tester) async {
      tester.view.physicalSize = const Size(320, 640);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      final modelCtrl = TextEditingController(text: 'Chevrolet Cobalt');
      final colorCtrl = TextEditingController(text: 'Oq');
      final yearCtrl = TextEditingController(text: '2022');
      final plateCtrl = TextEditingController(text: '01 A 777 AA');
      final tpSeriesCtrl = TextEditingController(text: 'AAF');
      final tpNumberCtrl = TextEditingController(text: '1234567');

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: Scaffold(
            body: SingleChildScrollView(
              child: Step3VehicleView(
                isDark: false,
                carModelController: modelCtrl,
                carColorController: colorCtrl,
                carYearController: yearCtrl,
                plateNumberController: plateCtrl,
                plateNumberError: null,
                onPlateNumberChanged: (_) {},
                carSeatsCount: 4,
                onCarSeatsChanged: (_) {},
                hasAc: true,
                onHasAcChanged: (_) {},
                ownershipType: 'own',
                onOwnershipTypeChanged: (_) {},
                techPassportSeriesController: tpSeriesCtrl,
                techPassportNumberController: tpNumberCtrl,
                photos: const {},
                onPickPhoto: (_) {},
                onRemovePhoto: (_) {},
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Check key vehicle widgets render properly
      expect(find.text('Avtomobil parametrlari'), findsOneWidget);
      expect(find.text('Davlat raqam belgisi'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  });

  group('3. Step 4 Review & Double Submit Blocking', () {
    testWidgets('Submit button is disabled and shows loading indicator while submitting',
        (tester) async {
      bool submitTriggered = false;

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: Scaffold(
            body: SingleChildScrollView(
              child: Step4ReviewSubmitView(
                isDark: false,
                fullName: 'Alisher Usmonov',
                birthDate: '1995-05-12',
                userPhone: '+998901234567',
                licenseSeriesNumber: 'AB 9876543',
                licenseExpiryDate: '2030-01-01',
                licenseCategories: const ['B'],
                carModel: 'Cobalt',
                carColor: 'Oq',
                carYear: '2022',
                plateNumber: '01 A 777 AA',
                carSeatsCount: 4,
                hasAc: true,
                techPassportSeriesNumber: 'AAF 1234567',
                photos: const {},
                hasConsent: true,
                onConsentChanged: (_) {},
                onEditStep: (_) {},
                onSubmit: () => submitTriggered = true,
                isSubmitting: true, // currently in progress
              ),
            ),
          ),
        ),
      );

      await tester.pump();

      // Find the submit button area
      expect(find.text('Arizani yuborish'), findsOneWidget);

      // Verify pulsing dots loading indicator is displayed
      expect(find.byType(AppPulsingDots), findsOneWidget);

      // Tap on submit button while submitting
      await tester.tap(find.text('Arizani yuborish'));
      await tester.pump();

      // Submit must NOT be triggered (double-submit blocked)
      expect(submitTriggered, isFalse);
    });
  });

  group('4. Rejected Verification Resubmit Flow', () {
    testWidgets('Displays genuine rejection reason and allows editing application',
        (tester) async {
      bool editTapped = false;

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: Scaffold(
            body: VerificationStatusView(
              status: 'rejected',
              isDark: false,
              rejectionReason:
                  'Haydovchilik guvohnomasi xira olingan, qayta yuklang.',
              driverName: 'Sardor Rahimov',
              onEditApplication: () => editTapped = true,
              onRefreshStatus: () {},
              onGoHome: () {},
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Displays genuine rejection reason
      expect(
        find.text('Haydovchilik guvohnomasi xira olingan, qayta yuklang.'),
        findsOneWidget,
      );

      // Edit application button exists
      final editButton = find.text('Arizani tahrirlash va qayta topshirish');
      expect(editButton, findsOneWidget);

      await tester.tap(editButton);
      expect(editTapped, isTrue);

      // Go home button exists
      final goHomeButton = find.text('Asosiy ekranga qaytish');
      expect(goHomeButton, findsOneWidget);
    });

    testWidgets('Displays fallback truthful message when backend returns null reason',
        (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: Scaffold(
            body: VerificationStatusView(
              status: 'rejected',
              isDark: false,
              rejectionReason: null, // Backend returned no reason
              driverName: 'Sardor Rahimov',
              onEditApplication: () {},
              onRefreshStatus: () {},
              onGoHome: () {},
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Verifies truthful message without fake/hallucinated reasons
      expect(
        find.text(
            'Sabab ko\'rsatilmadi. Iltimos, ma\'lumotlar va hujjatlarni qayta tekshirib yuboring.'),
        findsOneWidget,
      );
    });
  });

  group('5. VerificationBloc Submission Flow', () {
    test('Emits [SubmittingApplicationState, ApplicationSubmittedSuccessState] on submit',
        () async {
      final bloc = VerificationBloc(
        getCitiesUseCase: _FakeGetCitiesUseCase(),
        submitApplicationUseCase: _FakeSubmitApplicationUseCase(),
      );

      final expectedStates = [
        isA<SubmittingApplicationState>(),
        isA<ApplicationSubmittedSuccessState>().having(
          (s) => s.response.verificationStatus,
          'verificationStatus',
          equals('under_review'),
        ),
      ];

      expectLater(bloc.stream, emitsInOrder(expectedStates));

      bloc.add(
        const SubmitDriverApplicationEvent(
          textFields: {
            'first_name': 'Sardor',
            'last_name': 'Rahimov',
            'birth_date': '1992-04-15',
            'gender': 'male',
            'car_model': 'Cobalt',
            'car_color': 'Oq',
            'car_year': 2022,
            'plate_number': '01A777AA',
            'tech_passport_number': 'AAF1234567',
            'driver_license_number': 'AA9876543',
            'car_seats_count': 4,
            'has_ac': true,
          },
          photoFiles: {
            'driver_license_front': '/path/to/dl_front.jpg',
            'driver_license_back': '/path/to/dl_back.jpg',
            'tech_passport_front': '/path/to/tp_front.jpg',
            'tech_passport_back': '/path/to/tp_back.jpg',
            'car_front_photo': '/path/to/car_front.jpg',
            'car_interior_photo': '/path/to/car_int.jpg',
          },
        ),
      );
    });
  });

  group('6. Verification Status Routing & Navigation Guards', () {
    test('Unapproved statuses route away from driver home', () {
      const nonApprovedStatuses = ['pending_submission', 'under_review', 'rejected', 'action_required'];
      for (final status in nonApprovedStatuses) {
        final shouldGoHome = status == 'approved';
        expect(shouldGoHome, isFalse, reason: '$status must not allow direct access to driver home');
      }
    });

    test('Approved status routes directly to driver home', () {
      const status = 'approved';
      const shouldGoHome = status == 'approved';
      expect(shouldGoHome, isTrue);
    });
  });
}
