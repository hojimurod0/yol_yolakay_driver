import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:yol_yolakay_driver/core/network/api_client.dart';
import 'package:yol_yolakay_driver/core/network/api_exception.dart';
import 'package:yol_yolakay_driver/core/network/api_response.dart';
import 'package:yol_yolakay_driver/features/profile/data/datasources/driver_profile_remote_data_source.dart';
import 'package:yol_yolakay_driver/features/verification/data/models/driver_verification_request_dto.dart';
import 'package:yol_yolakay_driver/features/verification/presentation/widgets/verification_formatters.dart';

class _CapturingApiClient extends Fake implements ApiClient {
  String? lastPath;
  dynamic lastData;

  @override
  Future<ApiResponse<T>> post<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    String? idempotencyKey,
    T Function(dynamic dataJson)? fromData,
  }) async {
    lastPath = path;
    lastData = data;
    return ApiResponse<T>(success: true, message: 'OK', data: null);
  }
}

void main() {
  group('1. Name rejects digits & Auto-capitalization', () {
    test('NameInputFormatter rejects digit characters', () {
      final formatter = NameInputFormatter();
      const oldValue = TextEditingValue.empty;
      const newValue = TextEditingValue(text: 'Alisher123');

      final result = formatter.formatEditUpdate(oldValue, newValue);
      expect(result.text, equals('Alisher'));
    });

    test('NameInputFormatter capitalizes initial letters and keeps spaces and tutuq belgilari', () {
      final formatter = NameInputFormatter();
      const oldValue = TextEditingValue.empty;
      const newValue = TextEditingValue(text: 'anvar o\'g\'li');

      final result = formatter.formatEditUpdate(oldValue, newValue);
      expect(result.text, equals('Anvar O\'g\'li'));
    });

    test('validateFirstName and validateLastName reject digits and short length', () {
      expect(VerificationValidators.validateFirstName('A1'), isNotNull);
      expect(VerificationValidators.validateFirstName('A'), isNotNull);
      expect(VerificationValidators.validateFirstName('Alisher'), isNull);

      expect(VerificationValidators.validateLastName('Usmonov9'), isNotNull);
      expect(VerificationValidators.validateLastName('U'), isNotNull);
      expect(VerificationValidators.validateLastName('Usmonov'), isNull);
    });
  });

  group('2. Passport formatter & normalizer', () {
    test('SeriesInputFormatter enforces uppercase and max length 2', () {
      final formatter = SeriesInputFormatter(maxLength: 2);
      const oldValue = TextEditingValue.empty;
      const newValue = TextEditingValue(text: 'abc');

      final result = formatter.formatEditUpdate(oldValue, newValue);
      expect(result.text, equals('AB'));
    });

    test('DigitsOnlyFormatter restricts to numbers with max length', () {
      final formatter = DigitsOnlyFormatter(maxLength: 7);
      const oldValue = TextEditingValue.empty;
      const newValue = TextEditingValue(text: '12a345678');

      final result = formatter.formatEditUpdate(oldValue, newValue);
      expect(result.text, equals('1234567'));
    });

    test('VerificationNormalizers.normalizePassport outputs normalized format', () {
      final normalized = VerificationNormalizers.normalizePassport('aa', '1234567');
      expect(normalized, equals('AA1234567'));
    });
  });

  group('3. Driver license formatter & normalizer', () {
    test('VerificationNormalizers.normalizeDriverLicense outputs uppercase normalized format', () {
      final normalized = VerificationNormalizers.normalizeDriverLicense('ab', '9876543');
      expect(normalized, equals('AB9876543'));
    });
  });

  group('4. Plate validation & normalizer', () {
    test('validatePlateNumber accepts standard Uzbekistan plates', () {
      expect(VerificationValidators.validatePlateNumber('01 A 777 AA'), isNull);
      expect(VerificationValidators.validatePlateNumber('01A777AA'), isNull);
      expect(VerificationValidators.validatePlateNumber('10 123 AAA'), isNull);
      expect(VerificationValidators.validatePlateNumber('10123AAA'), isNull);
    });

    test('validatePlateNumber rejects invalid formats', () {
      expect(VerificationValidators.validatePlateNumber(''), isNotNull);
      expect(VerificationValidators.validatePlateNumber('INVALID123'), isNotNull);
      expect(VerificationValidators.validatePlateNumber('01 777'), isNotNull);
    });

    test('normalizePlateNumber standardizes raw uppercase license plate', () {
      expect(
        VerificationNormalizers.normalizePlateNumber('01 a 777 aa'),
        equals('01A777AA'),
      );
      expect(
        VerificationNormalizers.normalizePlateNumber('10 123 aaa'),
        equals('10123AAA'),
      );
    });
  });

  group('5. Whitelist constants enforcement', () {
    test('allowedVerificationFileFields contains exactly the 6 backend files', () {
      expect(allowedVerificationFileFields.length, equals(6));
      expect(
        allowedVerificationFileFields,
        containsAllInOrder([
          'driver_license_front',
          'driver_license_back',
          'tech_passport_front',
          'tech_passport_back',
          'car_front_photo',
          'car_interior_photo',
        ]),
      );
    });

    test('allowedVerificationTextFields contains exactly the 12 backend fields', () {
      expect(allowedVerificationTextFields.length, equals(12));
      expect(
        allowedVerificationTextFields,
        containsAll([
          'first_name',
          'last_name',
          'birth_date',
          'gender',
          'car_model',
          'car_color',
          'car_year',
          'plate_number',
          'tech_passport_number',
          'driver_license_number',
          'car_seats_count',
          'has_ac',
        ]),
      );
    });
  });

  group('6. DTO whitelist & id_card_front rejection', () {
    test('DriverVerificationRequestDto strictly discards id_card_front and extra UI fields', () {
      const formData = DriverVerificationFormData(
        firstName: 'Sardor',
        lastName: 'Rahimov',
        birthDate: '1992-04-15',
        carModel: 'Chevrolet Cobalt',
        carColor: 'Oq',
        carYear: 2022,
        plateNumber: '01A777AA',
        carSeatsCount: 4,
        hasAc: true,
        techPassportSeries: 'AAF',
        techPassportNumber: '1234567',
        licenseSeries: 'AA',
        licenseNumber: '9876543',
        photos: {
          'id_card_front': '/path/to/id_front.jpg',
          'id_card_back': '/path/to/id_back.jpg',
          'passport_main_page': '/path/to/passport.jpg',
          'avatar': '/path/to/avatar.jpg',
          'driver_license_front': '/path/to/dl_front.jpg',
          'driver_license_back': '/path/to/dl_back.jpg',
          'tech_passport_front': '/path/to/tp_front.jpg',
          'tech_passport_back': '/path/to/tp_back.jpg',
          'car_front_photo': '/path/to/car_front.jpg',
          'car_interior_photo': '/path/to/car_int.jpg',
          'random_unsupported_key': '/path/to/other.jpg',
        },
      );

      final dto = DriverVerificationRequestDto.fromFormData(formData);

      // Verify text fields map contains only whitelisted fields
      final textMap = dto.toTextFieldsMap();
      expect(textMap.keys.length, equals(12));
      expect(textMap['first_name'], equals('Sardor'));
      expect(textMap['plate_number'], equals('01A777AA'));
      expect(textMap['tech_passport_number'], equals('AAF1234567'));
      expect(textMap['driver_license_number'], equals('AA9876543'));

      // Verify photoFiles only contains exactly whitelisted file fields
      expect(dto.photoFiles.containsKey('id_card_front'), isFalse);
      expect(dto.photoFiles.containsKey('id_card_back'), isFalse);
      expect(dto.photoFiles.containsKey('passport_main_page'), isFalse);
      expect(dto.photoFiles.containsKey('avatar'), isFalse);
      expect(dto.photoFiles.containsKey('random_unsupported_key'), isFalse);

      expect(dto.photoFiles.length, equals(6));
      for (final key in dto.photoFiles.keys) {
        expect(allowedVerificationFileFields.contains(key), isTrue);
      }
    });
  });

  group('7. FCM Token Contract', () {
    test('DriverProfileRemoteDataSource sends fcm_token and device_platform', () async {
      final capturingClient = _CapturingApiClient();
      final dataSource = DriverProfileRemoteDataSourceImpl(capturingClient);

      await dataSource.updateFcmToken('test_fcm_token_123');

      expect(capturingClient.lastPath, equals('/driver/fcm-token'));
      final data = capturingClient.lastData as Map<String, dynamic>;

      // Explicitly verifies backend contract:
      expect(data.containsKey('fcm_token'), isTrue);
      expect(data['fcm_token'], equals('test_fcm_token_123'));
      expect(data.containsKey('device_platform'), isTrue);
      expect(['android', 'ios'].contains(data['device_platform']), isTrue);

      // Explicitly verifies deprecated fields are NOT sent:
      expect(data.containsKey('token'), isFalse);
      expect(data.containsKey('platform'), isFalse);
    });
  });

  group('8. Error Handling & Timeout Mapping', () {
    test('Send timeout maps to friendly localized upload timeout error', () {
      final dioError = DioException(
        type: DioExceptionType.sendTimeout,
        requestOptions: RequestOptions(path: '/driver/verify-application'),
      );

      final apiException = ApiException.fromDioError(dioError);
      expect(apiException, isA<ApiTimeoutException>());
      expect(apiException.message, contains('Fayllarni yuklash vaqti tugadi'));
      // No raw technical jargon
      expect(apiException.message.contains('DioException'), isFalse);
    });

    test('Receive timeout maps to friendly localized server response timeout', () {
      final dioError = DioException(
        type: DioExceptionType.receiveTimeout,
        requestOptions: RequestOptions(path: '/driver/verify-application'),
      );

      final apiException = ApiException.fromDioError(dioError);
      expect(apiException, isA<ApiTimeoutException>());
      expect(apiException.message, contains('Server javob berish vaqti tugadi'));
    });

    test('HTTP 409 maps to duplicate/already submitted error', () {
      final dioError = DioException(
        type: DioExceptionType.badResponse,
        requestOptions: RequestOptions(path: '/driver/verify-application'),
        response: Response(
          statusCode: 409,
          requestOptions: RequestOptions(path: '/driver/verify-application'),
          data: {'message': 'Verification already submitted'},
        ),
      );

      final apiException = ApiException.fromDioError(dioError);
      expect(apiException.message, contains('topshirilgan'));
    });

    test('HTTP 413 maps to file too large error', () {
      final dioError = DioException(
        type: DioExceptionType.badResponse,
        requestOptions: RequestOptions(path: '/driver/verify-application'),
        response: Response(
          statusCode: 413,
          requestOptions: RequestOptions(path: '/driver/verify-application'),
        ),
      );

      final apiException = ApiException.fromDioError(dioError);
      expect(apiException.message, contains('juda katta'));
    });

    test('Sanitizes technical backend strings like MulterError or ValidationPipe', () {
      final dioError = DioException(
        type: DioExceptionType.badResponse,
        requestOptions: RequestOptions(path: '/driver/verify-application'),
        response: Response(
          statusCode: 400,
          requestOptions: RequestOptions(path: '/driver/verify-application'),
          data: {'message': 'MulterError: Unexpected field id_card_front'},
        ),
      );

      final apiException = ApiException.fromDioError(dioError);
      expect(apiException.message.contains('MulterError'), isFalse);
      expect(apiException.message, contains('talablarga mos kelmadi'));
    });
  });
}
