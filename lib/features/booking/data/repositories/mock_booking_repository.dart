import 'dart:async';
import 'package:uuid/uuid.dart';
import 'package:yol_yolakay_driver/features/booking/domain/entities/booking_entity.dart';
import 'package:yol_yolakay_driver/features/booking/domain/repositories/booking_repository.dart';
import 'package:yol_yolakay_driver/features/home/domain/entities/city_entity.dart';
import 'package:yol_yolakay_driver/features/home/domain/entities/location_point_entity.dart';
import 'package:yol_yolakay_driver/features/rides/data/repositories/mock_ride_repository.dart';
import 'package:yol_yolakay_driver/features/rides/domain/entities/driver_entity.dart';
import 'package:yol_yolakay_driver/features/rides/domain/entities/ride_entity.dart';
import 'package:yol_yolakay_driver/features/rides/domain/entities/vehicle_entity.dart';

/// Mock Booking repository simulating real-time booking generation and cancellation policy.
class MockBookingRepository implements BookingRepository {
  MockBookingRepository(this._rideRepository);

  final MockRideRepository _rideRepository;
  final List<BookingEntity> _bookings = [];

  @override
  Future<BookingEntity> createBooking(CreateBookingParams params) async {
    await Future.delayed(const Duration(milliseconds: 700));

    final ride = await _rideRepository.getRideDetails(params.rideId);
    final booking = BookingEntity(
      id: 'YYK-${const Uuid().v4().substring(0, 8).toUpperCase()}',
      ride: ride,
      passengerId: 'usr_uz_default_01',
      passengerName: params.passengerName,
      passengerPhone: params.passengerPhone,
      seatCount: params.seatCount,
      pickupPoint: params.pickupPoint,
      totalPrice: ride.pricePerSeat * params.seatCount,
      status: BookingStatus.confirmed,
      paymentType: params.paymentType,
      createdAt: DateTime.now(),
    );

    _bookings.insert(0, booking);
    return booking;
  }

  @override
  Future<BookingEntity> getBooking(String bookingId) async {
    await Future.delayed(const Duration(milliseconds: 300));
    return _bookings.firstWhere(
      (b) => b.id == bookingId,
      orElse: () => _createFallbackBooking(bookingId),
    );
  }

  @override
  Future<BookingEntity> cancelBooking(String bookingId, String reason) async {
    await Future.delayed(const Duration(milliseconds: 500));
    final index = _bookings.indexWhere((b) => b.id == bookingId);
    if (index != -1) {
      final updated = _bookings[index].copyWith(
        status: BookingStatus.cancelled,
        cancellationReason: reason,
      );
      _bookings[index] = updated;
      return updated;
    }
    final fallback = _createFallbackBooking(bookingId).copyWith(
      status: BookingStatus.cancelled,
      cancellationReason: reason,
    );
    return fallback;
  }

  BookingEntity _createFallbackBooking(String id) {
    final now = DateTime.now();
    const tashkent = CityEntity(
      id: 'city_tashkent',
      nameUz: 'Toshkent',
      nameRu: 'Ташкент',
      nameEn: 'Tashkent',
      region: 'Toshkent',
      latitude: 41.2995,
      longitude: 69.2401,
    );
    const samarkand = CityEntity(
      id: 'city_samarkand',
      nameUz: 'Samarqand',
      nameRu: 'Самарканд',
      nameEn: 'Samarkand',
      region: 'Samarqand',
      latitude: 39.6542,
      longitude: 66.9597,
    );
    const pickup = LocationPointEntity(
      id: 'pickup_tash_chilonzor',
      title: 'Chilonzor metro bekati',
      description: 'Avtovokzal oldidagi kutish joyi',
      latitude: 41.2721,
      longitude: 69.2045,
    );

    final fallbackRide = RideEntity(
      id: 'ride_fallback',
      departureCity: tashkent,
      destinationCity: samarkand,
      departureTime: now.add(const Duration(hours: 2)),
      estimatedArrivalTime: now.add(const Duration(hours: 4, minutes: 30)),
      driver: const DriverEntity(
        id: 'drv_01',
        name: 'Azizbek Rahimov',
        phoneNumber: '+998 90 987 65 43',
        rating: 4.9,
        completedTrips: 342,
      ),
      vehicle: const VehicleEntity(
        id: 'veh_01',
        make: 'Chevrolet',
        model: 'Cobalt',
        color: 'Oq',
        licensePlate: '01 A 777 BA',
        type: VehicleType.sedan,
      ),
      pricePerSeat: 120000,
      totalSeats: 4,
      availableSeats: 3,
      pickupPoints: const [pickup],
      dropoffPoints: const [],
    );

    return BookingEntity(
      id: id,
      ride: fallbackRide,
      passengerId: 'usr_uz_default_01',
      passengerName: 'Rizo Karimov',
      passengerPhone: '+998 90 123 45 67',
      seatCount: 1,
      pickupPoint: pickup,
      totalPrice: 120000,
      status: BookingStatus.confirmed,
      paymentType: PaymentType.cash,
      createdAt: now,
    );
  }
}
