import 'package:flutter_test/flutter_test.dart';
import 'package:yol_yolakay_driver/core/errors/app_error_handler.dart';
import 'package:yol_yolakay_driver/core/errors/exceptions.dart';
import 'package:yol_yolakay_driver/core/services/location_service.dart';
import 'package:yol_yolakay_driver/core/utils/app_logger.dart';
import 'package:yol_yolakay_driver/core/utils/currency_formatter.dart';
import 'package:yol_yolakay_driver/core/utils/cyrillic_converter.dart';
import 'package:yol_yolakay_driver/core/utils/validator.dart';
import 'package:yol_yolakay_driver/features/booking/data/repositories/mock_booking_repository.dart';
import 'package:yol_yolakay_driver/features/booking/domain/entities/booking_entity.dart';
import 'package:yol_yolakay_driver/features/booking/domain/repositories/booking_repository.dart';
import 'package:yol_yolakay_driver/features/driver/data/repositories/mock_driver_repository.dart';
import 'package:yol_yolakay_driver/features/home/domain/entities/city_entity.dart';
import 'package:yol_yolakay_driver/features/home/domain/entities/location_point_entity.dart';
import 'package:yol_yolakay_driver/features/rides/data/repositories/mock_ride_repository.dart';
import 'package:yol_yolakay_driver/features/rides/domain/entities/driver_entity.dart';
import 'package:yol_yolakay_driver/features/rides/domain/entities/ride_entity.dart';
import 'package:yol_yolakay_driver/features/rides/domain/repositories/ride_repository.dart';

void main() {
  group('CyrillicConverter Tests', () {
    test(
        'converts Uzbek Latin and brands to Cyrillic without Latin letters remaining',
        () {
      expect(
          CyrillicConverter.toCyrillic('Chevrolet Cobalt'), 'Шевроле Кобальт');
      expect(CyrillicConverter.toCyrillic('Toshkent'), 'Ташкент');
      expect(CyrillicConverter.toCyrillic('Samarqand'), 'Самарканд');
      expect(CyrillicConverter.toCyrillic('Oq (White)'), 'Белый');
      expect(
          CyrillicConverter.toCyrillic('Azizbek Rahimov'), 'Азизбек Рахимов');
      expect(CyrillicConverter.toCyrillic('Qashqadaryo'), 'Кашкадарья');
    });

    test('maybeConvert only converts when languageCode is ru', () {
      expect(CyrillicConverter.maybeConvert('Toshkent', 'ru'), 'Ташкент');
      expect(CyrillicConverter.maybeConvert('Toshkent', 'uz'), 'Toshkent');
    });
  });

  group('AppCurrencyFormatter Tests', () {
    test('formats Cyrillic currency by default and in ru locale', () {
      expect(AppCurrencyFormatter.format(120000, locale: 'ru'), '120 000 сум');
      expect(AppCurrencyFormatter.format(50000, locale: 'ru'), '50 000 сум');
      expect(
          AppCurrencyFormatter.format(1250000, locale: 'ru'), '1 250 000 сум');
      expect(AppCurrencyFormatter.format(120000, locale: 'en'), '120 000 UZS');
    });

    test('formats short currency correctly', () {
      expect(AppCurrencyFormatter.formatShort(120000, locale: 'ru'),
          '120 тыс. сум');
      expect(AppCurrencyFormatter.formatShort(1500000, locale: 'ru'),
          '1.5 млн сум');
    });
  });

  group('AppValidator Tests', () {
    test('validates Uzbekistan phone numbers correctly', () {
      expect(AppValidator.isValidUzPhone('901234567'), isTrue);
      expect(AppValidator.isValidUzPhone('998901234567'), isTrue);
      expect(AppValidator.isValidUzPhone('12345'), isFalse);
    });

    test('formats Uzbekistan phone numbers nicely', () {
      expect(
        AppValidator.formatUzPhone('901234567'),
        '+998 (90) 123-45-67',
      );
    });
  });

  group('MockRideRepository & Search Tests', () {
    late MockRideRepository repository;

    setUp(() {
      repository = MockRideRepository();
    });

    test('searches available rides between Andijan and Kokand', () async {
      final results = await repository.searchRides(
        RideSearchParams(
          departureCityId: 'andijan_markaz',
          destinationCityId: 'fergana_qoqon',
          date: DateTime.now(),
          passengerCount: 1,
        ),
      );

      expect(results, isNotEmpty);
      expect(results.first.departureCity.id, 'andijan_markaz');
      expect(results.first.destinationCity.id, 'fergana_qoqon');
      expect(results.first.pricePerSeat, greaterThan(0));
    });
  });

  group('MockBookingRepository Tests', () {
    late MockRideRepository rideRepo;
    late MockBookingRepository bookingRepo;

    setUp(() {
      rideRepo = MockRideRepository();
      bookingRepo = MockBookingRepository(rideRepo);
    });

    test('creates and retrieves a booking successfully', () async {
      const pickup = LocationPointEntity(
        id: 'pickup_and_01',
        title: 'Andijon Avtovokzal',
        description: 'Bekat yonida',
        latitude: 40.7821,
        longitude: 72.3442,
      );

      final booking = await bookingRepo.createBooking(
        const CreateBookingParams(
          rideId: 'ride_vodiy_01',
          seatCount: 2,
          pickupPoint: pickup,
          passengerName: 'Rizo Karimov',
          passengerPhone: '+998 90 123 45 67',
          paymentType: PaymentType.cash,
        ),
      );

      expect(booking.id, startsWith('YYK-'));
      expect(booking.seatCount, 2);
      expect(booking.status, BookingStatus.confirmed);
      expect(booking.totalPrice, 90000); // 45,000 * 2
    });
  });

  group('MockDriverRepository & Planned Route Passenger Matching Tests', () {
    test(
        'starts with empty rides and requests, and loads passengers only upon planning a trip',
        () async {
      final repo = MockDriverRepository();

      // Initially no rides and no requests
      final initialRides = await repo.getDriverRides();
      final initialRequests = await repo.getIncomingRequests();
      expect(initialRides, isEmpty);
      expect(initialRequests, isEmpty);

      // Create and publish a planned route from Toshkent to Samarqand
      final profile = await repo.getDriverProfile();
      final newRide = RideEntity(
        id: 'test_ride_001',
        departureCity: const CityEntity(
          id: 'tashkent',
          nameUz: 'Toshkent',
          nameRu: 'Ташкент',
          nameEn: 'Tashkent',
          region: 'Toshkent',
          latitude: 41.2995,
          longitude: 69.2401,
          isPopular: true,
        ),
        destinationCity: const CityEntity(
          id: 'samarkand',
          nameUz: 'Samarqand',
          nameRu: 'Самарканд',
          nameEn: 'Samarkand',
          region: 'Samarqand',
          latitude: 39.6270,
          longitude: 66.9750,
          isPopular: true,
        ),
        departureTime: DateTime.now().add(const Duration(hours: 3)),
        estimatedArrivalTime: DateTime.now().add(const Duration(hours: 7)),
        driver: DriverEntity(
          id: profile.id,
          name: profile.fullName,
          phoneNumber: profile.phoneNumber,
          rating: profile.rating,
          completedTrips: profile.completedTripsCount,
        ),
        vehicle: profile.vehicle,
        pricePerSeat: 95000,
        totalSeats: 4,
        availableSeats: 3,
        pickupPoints: const [],
        dropoffPoints: const [],
      );

      await repo.publishRide(newRide);

      // Now rides and requests exist and strictly match Toshkent -> Samarqand
      final updatedRides = await repo.getDriverRides();
      final updatedRequests = await repo.getIncomingRequests();

      expect(updatedRides.length, 1);
      expect(updatedRides.first.id, 'test_ride_001');
      expect(updatedRequests, isNotEmpty);
      for (final req in updatedRequests) {
        expect(req.rideId, 'test_ride_001');
        expect(req.departureCity, 'Toshkent');
        expect(req.destinationCity, 'Samarqand');
      }

      // Cancelling the ride cleans up the route and associated passenger requests
      await repo.cancelRide('test_ride_001');
      final ridesAfterCancel = await repo.getDriverRides();
      final requestsAfterCancel = await repo.getIncomingRequests();
      expect(ridesAfterCancel, isEmpty);
      expect(requestsAfterCancel, isEmpty);
    });
  });

  group('AppErrorHandler Tests', () {
    test(
        'maps NetworkException to user-friendly messages in all supported locales',
        () {
      final uzErr =
          AppErrorHandler.parse(NetworkException(), languageCode: 'uz');
      expect(uzErr.isNetworkError, isTrue);
      expect(uzErr.title, 'Tarmoq xatoligi');
      expect(uzErr.message, contains('Server'));

      final ruErr =
          AppErrorHandler.parse(NetworkException(), languageCode: 'ru');
      expect(ruErr.isNetworkError, isTrue);
      expect(ruErr.title, 'Ошибка сети');

      final enErr =
          AppErrorHandler.parse(NetworkException(), languageCode: 'en');
      expect(enErr.isNetworkError, isTrue);
      expect(enErr.title, 'Network Error');
    });

    test(
        'maps AuthException to friendly session message without technical jargon',
        () {
      final authErr = AppErrorHandler.parse(AuthException('token invalid'),
          languageCode: 'uz');
      expect(authErr.isAuthError, isTrue);
      expect(authErr.title, 'Kirish xatosi');
      expect(authErr.message, contains('Sessiya muddati tugadi'));
    });

    test('maps ApiException with message directly', () {
      final apiErr = AppErrorHandler.parse(
          ApiException(message: 'Haydovchi topilmadi', statusCode: 404),
          languageCode: 'uz');
      expect(apiErr.title, 'So\'rov xatoligi');
      expect(apiErr.message, 'Haydovchi topilmadi');
    });
  });

  group('AppLogger & Sanitization Tests', () {
    test('logs debug, info, warn, error without throwing exceptions', () {
      expect(
          () =>
              AppLogger.debug('Testing debug message', module: LogModule.auth),
          returnsNormally);
      expect(
          () => AppLogger.info('Testing info message', module: LogModule.api),
          returnsNormally);
      expect(
          () =>
              AppLogger.warn('Testing warning message', module: LogModule.taxi),
          returnsNormally);
      expect(
          () => AppLogger.error('Testing error message',
              module: LogModule.system),
          returnsNormally);
    });
  });

  group('LocationService Tests', () {
    test('calculates geographic distance accurately', () {
      final service = LocationService();
      // Tashkent to Samarkand distance is approx 270 km
      final distance =
          service.distanceBetween(41.2995, 69.2401, 39.6270, 66.9750);
      expect(distance, greaterThan(250000)); // meters
      expect(distance, lessThan(350000));
    });
  });
}
