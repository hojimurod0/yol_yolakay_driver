import 'dart:async';
import 'package:yol_yolakay_driver/features/booking/domain/entities/booking_entity.dart';
import 'package:yol_yolakay_driver/features/home/domain/entities/city_entity.dart';
import 'package:yol_yolakay_driver/features/home/domain/entities/location_point_entity.dart';
import 'package:yol_yolakay_driver/features/rides/domain/entities/driver_entity.dart';
import 'package:yol_yolakay_driver/features/rides/domain/entities/ride_entity.dart';
import 'package:yol_yolakay_driver/features/rides/domain/entities/vehicle_entity.dart';
import 'package:yol_yolakay_driver/features/trips/domain/entities/trip_entity.dart';
import 'package:yol_yolakay_driver/features/trips/domain/repositories/trip_repository.dart';

/// Complete Mock Trip Repository providing realistic trip stages, live GPS simulation, and rating feedback.
class MockTripRepository implements TripRepository {
  static const CityEntity _tashkent = CityEntity(
    id: 'city_tashkent',
    nameUz: 'Toshkent',
    nameRu: 'Ташкент',
    nameEn: 'Tashkent',
    region: 'Toshkent shahri',
    isPopular: true,
    latitude: 41.2995,
    longitude: 69.2401,
  );

  static const CityEntity _samarkand = CityEntity(
    id: 'city_samarkand',
    nameUz: 'Samarqand',
    nameRu: 'Самарканд',
    nameEn: 'Samarkand',
    region: 'Samarqand viloyati',
    isPopular: true,
    latitude: 39.6542,
    longitude: 66.9597,
  );

  static const CityEntity _bukhara = CityEntity(
    id: 'city_bukhara',
    nameUz: 'Buxoro',
    nameRu: 'Бухара',
    nameEn: 'Bukhara',
    region: 'Buxoro viloyati',
    isPopular: true,
    latitude: 39.7681,
    longitude: 64.4556,
  );

  static const LocationPointEntity _chilonzor = LocationPointEntity(
    id: 'pickup_tash_chilonzor',
    title: 'Chilonzor metro bekati',
    description: 'Avtovokzal oldidagi kutish joyi',
    latitude: 41.2721,
    longitude: 69.2045,
  );

  static final List<TripEntity> _trips = _generateInitialTrips();

  static List<TripEntity> _generateInitialTrips() {
    final now = DateTime.now();

    final activeRide = RideEntity(
      id: 'ride_active_01',
      departureCity: _tashkent,
      destinationCity: _samarkand,
      departureTime: DateTime(now.year, now.month, now.day, 14, 0),
      estimatedArrivalTime: DateTime(now.year, now.month, now.day, 16, 30),
      driver: const DriverEntity(
        id: 'drv_01',
        name: 'Azizbek Rahimov',
        phoneNumber: '+998 90 987 65 43',
        rating: 4.9,
        completedTrips: 342,
        isVerified: true,
      ),
      vehicle: const VehicleEntity(
        id: 'veh_01',
        make: 'Chevrolet',
        model: 'Cobalt',
        color: 'Oq (White)',
        licensePlate: '01 A 777 BA',
        type: VehicleType.sedan,
      ),
      pricePerSeat: 120000,
      totalSeats: 4,
      availableSeats: 2,
      pickupPoints: [_chilonzor],
      dropoffPoints: const [
        LocationPointEntity(
          id: 'drop_sam_registan',
          title: 'Registon maydoni',
          description: 'Markaziy maydon',
          latitude: 39.6548,
          longitude: 66.9750,
        ),
      ],
    );

    final upcomingRide = RideEntity(
      id: 'ride_up_01',
      departureCity: _tashkent,
      destinationCity: _bukhara,
      departureTime: now.add(const Duration(days: 2, hours: 3)),
      estimatedArrivalTime:
          now.add(const Duration(days: 2, hours: 8, minutes: 30)),
      driver: const DriverEntity(
        id: 'drv_04',
        name: 'Dilshod Normatov',
        phoneNumber: '+998 91 222 33 44',
        rating: 4.85,
        completedTrips: 189,
        isVerified: true,
      ),
      vehicle: const VehicleEntity(
        id: 'veh_04',
        make: 'Chevrolet',
        model: 'Tracker 2',
        color: 'Oq (White)',
        licensePlate: '80 A 123 AA',
        type: VehicleType.crossover,
      ),
      pricePerSeat: 220000,
      totalSeats: 4,
      availableSeats: 3,
      pickupPoints: [_chilonzor],
      dropoffPoints: const [
        LocationPointEntity(
          id: 'drop_bux_vokzal',
          title: 'Buxoro Temiryo\'l Vokzali',
          description: 'Kogon shahrida',
          latitude: 39.7183,
          longitude: 64.5512,
        ),
      ],
    );

    final completedRide = RideEntity(
      id: 'ride_comp_01',
      departureCity: _samarkand,
      destinationCity: _tashkent,
      departureTime: now.subtract(const Duration(days: 5, hours: 4)),
      estimatedArrivalTime:
          now.subtract(const Duration(days: 5, hours: 1, minutes: 30)),
      driver: const DriverEntity(
        id: 'drv_03',
        name: 'Jahongir Qodirov',
        phoneNumber: '+998 97 111 22 33',
        rating: 5.0,
        completedTrips: 520,
        isVerified: true,
      ),
      vehicle: const VehicleEntity(
        id: 'veh_03',
        make: 'BYD',
        model: 'Song Plus EV',
        color: 'Kulrang (Grey)',
        licensePlate: '01 001 VIP',
        type: VehicleType.crossover,
      ),
      pricePerSeat: 160000,
      totalSeats: 4,
      availableSeats: 1,
      pickupPoints: const [
        LocationPointEntity(
          id: 'drop_sam_registan',
          title: 'Registon maydoni',
          description: 'Markaziy maydon',
          latitude: 39.6548,
          longitude: 66.9750,
        ),
      ],
      dropoffPoints: [_chilonzor],
    );

    return [
      TripEntity(
        id: 'trip_act_01',
        booking: BookingEntity(
          id: 'YYK-ACT9021',
          ride: activeRide,
          passengerId: 'usr_uz_default_01',
          passengerName: 'Rizo Karimov',
          passengerPhone: '+998 90 123 45 67',
          seatCount: 1,
          pickupPoint: _chilonzor,
          totalPrice: 120000,
          status: BookingStatus.active,
          paymentType: PaymentType.cash,
          createdAt: now.subtract(const Duration(hours: 1)),
        ),
        progressStatus: TripProgressStatus.tripStarted,
        currentDriverLat: 40.5200,
        currentDriverLng: 68.2100,
        estimatedArrivalRemainingMinutes: 75,
      ),
      TripEntity(
        id: 'trip_up_01',
        booking: BookingEntity(
          id: 'YYK-UPK3301',
          ride: upcomingRide,
          passengerId: 'usr_uz_default_01',
          passengerName: 'Rizo Karimov',
          passengerPhone: '+998 90 123 45 67',
          seatCount: 2,
          pickupPoint: _chilonzor,
          totalPrice: 440000,
          status: BookingStatus.confirmed,
          paymentType: PaymentType.click,
          createdAt: now.subtract(const Duration(days: 1)),
        ),
        progressStatus: TripProgressStatus.bookingConfirmed,
        currentDriverLat: 41.2721,
        currentDriverLng: 69.2045,
        estimatedArrivalRemainingMinutes: 360,
      ),
      TripEntity(
        id: 'trip_comp_01',
        booking: BookingEntity(
          id: 'YYK-CMP7712',
          ride: completedRide,
          passengerId: 'usr_uz_default_01',
          passengerName: 'Rizo Karimov',
          passengerPhone: '+998 90 123 45 67',
          seatCount: 1,
          pickupPoint: const LocationPointEntity(
            id: 'drop_sam_registan',
            title: 'Registon maydoni',
            description: 'Markaziy maydon',
            latitude: 39.6548,
            longitude: 66.9750,
          ),
          totalPrice: 160000,
          status: BookingStatus.completed,
          paymentType: PaymentType.payme,
          createdAt: now.subtract(const Duration(days: 5)),
        ),
        progressStatus: TripProgressStatus.tripCompleted,
        currentDriverLat: 41.2721,
        currentDriverLng: 69.2045,
        estimatedArrivalRemainingMinutes: 0,
        hasRated: true,
        rating: 5,
        reviewFeedback: 'Mashina juda toza, haydovchi xushmuomala. Rahmat!',
      ),
    ];
  }

  @override
  Future<List<TripEntity>> getUpcomingTrips() async {
    await Future.delayed(const Duration(milliseconds: 300));
    return _trips
        .where((t) => t.booking.status == BookingStatus.confirmed)
        .toList();
  }

  @override
  Future<List<TripEntity>> getActiveTrips() async {
    await Future.delayed(const Duration(milliseconds: 300));
    return _trips
        .where((t) => t.booking.status == BookingStatus.active)
        .toList();
  }

  @override
  Future<List<TripEntity>> getCompletedTrips() async {
    await Future.delayed(const Duration(milliseconds: 300));
    return _trips
        .where((t) => t.booking.status == BookingStatus.completed)
        .toList();
  }

  @override
  Future<List<TripEntity>> getCancelledTrips() async {
    await Future.delayed(const Duration(milliseconds: 300));
    return _trips
        .where((t) => t.booking.status == BookingStatus.cancelled)
        .toList();
  }

  @override
  Future<TripEntity> getTripDetails(String tripId) async {
    await Future.delayed(const Duration(milliseconds: 200));
    return _trips.firstWhere(
      (t) => t.id == tripId,
      orElse: () => _trips.first,
    );
  }

  @override
  Stream<TripEntity> trackTrip(String tripId) async* {
    var trip = await getTripDetails(tripId);
    yield trip;

    final coordinates = [
      [40.8500, 68.7500],
      [40.6000, 68.4500],
      [40.3500, 68.1000],
      [40.1200, 67.8400],
      [39.8800, 67.4000],
      [39.6548, 66.9750],
    ];

    for (int i = 0; i < coordinates.length; i++) {
      await Future.delayed(const Duration(seconds: 3));
      trip = trip.copyWith(
        currentDriverLat: coordinates[i][0],
        currentDriverLng: coordinates[i][1],
        estimatedArrivalRemainingMinutes: (70 - (i * 12)).clamp(5, 70),
        progressStatus: i > 3
            ? TripProgressStatus.nearDestination
            : TripProgressStatus.tripStarted,
      );
      yield trip;
    }
  }

  @override
  Future<void> rateTrip({
    required String tripId,
    required int rating,
    required String feedback,
    List<String>? tags,
  }) async {
    await Future.delayed(const Duration(milliseconds: 500));
    final index = _trips.indexWhere((t) => t.id == tripId);
    if (index != -1) {
      _trips[index] = _trips[index].copyWith(
        hasRated: true,
        rating: rating,
        reviewFeedback: feedback,
      );
    }
  }
}
