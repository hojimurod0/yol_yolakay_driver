import '../../../rides/domain/entities/ride_entity.dart';
import '../../../rides/domain/entities/vehicle_entity.dart';
import '../../domain/entities/driver_incoming_request_entity.dart';
import '../../domain/entities/driver_profile_entity.dart';
import '../../domain/repositories/driver_repository.dart';

class MockDriverRepository implements DriverRepository {
  MockDriverRepository() {
    _initMockData();
  }

  late DriverProfileEntity _profile;
  final List<RideEntity> _driverRides = [];
  final List<DriverIncomingRequestEntity> _incomingRequests = [];

  void _initMockData() {
    const vehicle = VehicleEntity(
      id: 'veh_driver_01',
      make: 'Chevrolet',
      model: 'Cobalt',
      color: 'Oq (Gaz-Benzin)',
      licensePlate: '01 A 777 AA',
      type: VehicleType.sedan,
      hasAc: true,
      hasSpaciousTrunk: true,
      hasWifi: true,
      isSmokingAllowed: false,
    );

    _profile = const DriverProfileEntity(
      id: 'drv_me',
      fullName: 'Rizo Karimov',
      phoneNumber: '+998 90 123 45 67',
      telegramHandle: '@rizo_driver',
      vehicle: vehicle,
      rating: 4.95,
      ratingCount: 148,
      completedTripsCount: 312,
      status: DriverOnlineStatus.online,
      todayEarnings: 480000,
      isVerified: true,
      licenseNumber: 'AB 8839201',
      experienceYears: 7,
      isAcceptingParcels: true,
    );
  }

  List<DriverIncomingRequestEntity> _generateMatchingRequestsForRide(
      RideEntity ride) {
    final dep = ride.departureCity.nameUz;
    final dest = ride.destinationCity.nameUz;
    final depPickup = ride.pickupPoints.isNotEmpty
        ? ride.pickupPoints.first.title
        : '$dep markazi';
    final destDropoff = ride.dropoffPoints.isNotEmpty
        ? ride.dropoffPoints.first.title
        : '$dest markazi';
    final destDropoffAlt = ride.dropoffPoints.length > 1
        ? ride.dropoffPoints[1].title
        : '$dest vokzali';

    final requests = <DriverIncomingRequestEntity>[
      DriverIncomingRequestEntity(
        id: 'req_${ride.id}_01',
        rideId: ride.id,
        passengerName: 'Akmal Rustamov',
        passengerPhone: '+998 91 445 22 11',
        passengerAvatar: null,
        passengerRating: 4.9,
        departureCity: dep,
        destinationCity: dest,
        pickupAddress: depPickup,
        dropoffAddress: destDropoff,
        departureTime: ride.departureTime,
        seatsCount: 1,
        totalPrice: ride.pricePerSeat,
        type: DriverRequestType.passengerSeat,
        status: DriverRequestStatus.pending,
        comment:
            '1 ta chamadonim bor, old o‘rindiqda ketishni ma’qul ko‘raman.',
        telegramHandle: '@akmal_rustam',
      ),
    ];

    if (ride.isParcelAllowed) {
      requests.add(
        DriverIncomingRequestEntity(
          id: 'req_${ride.id}_02',
          rideId: ride.id,
          passengerName: 'Dilnoza Karimova (Pochta)',
          passengerPhone: '+998 93 881 70 05',
          passengerAvatar: null,
          passengerRating: 5.0,
          departureCity: dep,
          destinationCity: dest,
          pickupAddress: '$dep bekat yonida',
          dropoffAddress: destDropoffAlt,
          departureTime: ride.departureTime,
          seatsCount: 0,
          totalPrice: ride.parcelPrice,
          type: DriverRequestType.expressParcel,
          status: DriverRequestStatus.pending,
          comment:
              'Kichik quti va shoshilinch hujjatlar. Manzilda ukam kutib oladi.',
          telegramHandle: '@dilnoza_pochta',
        ),
      );
    }

    if (ride.availableSeats >= 2) {
      requests.add(
        DriverIncomingRequestEntity(
          id: 'req_${ride.id}_03',
          rideId: ride.id,
          passengerName: 'Bobur Mirzayev',
          passengerPhone: '+998 97 712 34 56',
          passengerAvatar: null,
          passengerRating: 4.85,
          departureCity: dep,
          destinationCity: dest,
          pickupAddress: '$dep Janubiy vokzal maydoni',
          dropoffAddress: destDropoff,
          departureTime: ride.departureTime.add(const Duration(minutes: 20)),
          seatsCount: 2,
          totalPrice: ride.pricePerSeat * 2,
          type: DriverRequestType.passengerSeat,
          status: DriverRequestStatus.pending,
          comment: '2 kishi, 1 ta sumka. Vaqtida yo‘lga chiqsak bo‘ldi.',
          telegramHandle: '@bobur_m',
        ),
      );
    }

    return requests;
  }

  @override
  Future<DriverProfileEntity> getDriverProfile() async {
    await Future.delayed(const Duration(milliseconds: 150));
    return _profile;
  }

  @override
  Future<DriverProfileEntity> updateDriverProfile(
      DriverProfileEntity profile) async {
    await Future.delayed(const Duration(milliseconds: 200));
    _profile = profile;
    return _profile;
  }

  @override
  Future<void> setOnlineStatus(DriverOnlineStatus status) async {
    await Future.delayed(const Duration(milliseconds: 150));
    _profile = _profile.copyWith(status: status);
  }

  @override
  Future<List<RideEntity>> getDriverRides() async {
    await Future.delayed(const Duration(milliseconds: 180));
    return List.unmodifiable(_driverRides);
  }

  @override
  Future<RideEntity> publishRide(RideEntity ride) async {
    await Future.delayed(const Duration(milliseconds: 300));
    _driverRides.insert(0, ride);
    final newRequests = _generateMatchingRequestsForRide(ride);
    _incomingRequests.insertAll(0, newRequests);
    return ride;
  }

  @override
  Future<void> cancelRide(String rideId) async {
    await Future.delayed(const Duration(milliseconds: 200));
    _driverRides.removeWhere((r) => r.id == rideId);
    _incomingRequests.removeWhere((r) => r.rideId == rideId);
  }

  @override
  Future<void> completeRide(String rideId) async {
    await Future.delayed(const Duration(milliseconds: 200));
    final index = _driverRides.indexWhere((r) => r.id == rideId);
    if (index != -1) {
      final old = _driverRides[index];
      _driverRides[index] = RideEntity(
        id: old.id,
        departureCity: old.departureCity,
        destinationCity: old.destinationCity,
        departureTime: old.departureTime,
        estimatedArrivalTime: old.estimatedArrivalTime,
        driver: old.driver,
        vehicle: old.vehicle,
        pricePerSeat: old.pricePerSeat,
        totalSeats: old.totalSeats,
        availableSeats: old.availableSeats,
        pickupPoints: old.pickupPoints,
        dropoffPoints: old.dropoffPoints,
        status: RideStatus.completed,
      );
      _incomingRequests.removeWhere(
          (r) => r.rideId == rideId && r.status == DriverRequestStatus.pending);
      _profile = _profile.copyWith(
        completedTripsCount: _profile.completedTripsCount + 1,
        todayEarnings: _profile.todayEarnings +
            (old.pricePerSeat * (old.totalSeats - old.availableSeats)),
      );
    }
  }

  @override
  Future<List<DriverIncomingRequestEntity>> getIncomingRequests() async {
    await Future.delayed(const Duration(milliseconds: 150));
    return List.unmodifiable(_incomingRequests);
  }

  @override
  Future<void> acceptRequest(String requestId) async {
    await Future.delayed(const Duration(milliseconds: 200));
    final index = _incomingRequests.indexWhere((r) => r.id == requestId);
    if (index != -1) {
      final req = _incomingRequests[index];
      _incomingRequests[index] =
          req.copyWith(status: DriverRequestStatus.accepted);

      // Reduce available seats if passenger request
      if (req.type == DriverRequestType.passengerSeat) {
        final rideIndex = _driverRides.indexWhere((r) => r.id == req.rideId);
        if (rideIndex != -1) {
          final ride = _driverRides[rideIndex];
          final newAvailable =
              (ride.availableSeats - req.seatsCount).clamp(0, ride.totalSeats);
          _driverRides[rideIndex] = RideEntity(
            id: ride.id,
            departureCity: ride.departureCity,
            destinationCity: ride.destinationCity,
            departureTime: ride.departureTime,
            estimatedArrivalTime: ride.estimatedArrivalTime,
            driver: ride.driver,
            vehicle: ride.vehicle,
            pricePerSeat: ride.pricePerSeat,
            totalSeats: ride.totalSeats,
            availableSeats: newAvailable,
            pickupPoints: ride.pickupPoints,
            dropoffPoints: ride.dropoffPoints,
            status: newAvailable == 0 ? RideStatus.full : ride.status,
          );
        }
      }
    }
  }

  @override
  Future<void> rejectRequest(String requestId) async {
    await Future.delayed(const Duration(milliseconds: 200));
    final index = _incomingRequests.indexWhere((r) => r.id == requestId);
    if (index != -1) {
      _incomingRequests[index] = _incomingRequests[index]
          .copyWith(status: DriverRequestStatus.rejected);
    }
  }
}
