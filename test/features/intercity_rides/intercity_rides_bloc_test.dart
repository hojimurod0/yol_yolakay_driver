import 'package:flutter_test/flutter_test.dart';
import 'package:yol_yolakay_driver/core/network/api_response.dart';
import 'package:yol_yolakay_driver/features/intercity_rides/domain/entities/intercity_ride_entity.dart';
import 'package:yol_yolakay_driver/features/intercity_rides/domain/repositories/intercity_rides_repository.dart';
import 'package:yol_yolakay_driver/features/intercity_rides/domain/usecases/intercity_rides_usecases.dart';
import 'package:yol_yolakay_driver/features/intercity_rides/presentation/bloc/intercity_rides_bloc.dart';
import 'package:yol_yolakay_driver/features/intercity_rides/presentation/bloc/intercity_rides_event.dart';
import 'package:yol_yolakay_driver/features/intercity_rides/presentation/bloc/intercity_rides_state.dart';

class FakeIntercityRidesRepository implements IntercityRidesRepository {
  final List<IntercityRideEntity> _rides = [
    IntercityRideEntity(
      id: 'ride-1',
      fromCity: 'Toshkent',
      toCity: 'Samarqand',
      departureTime: DateTime(2026, 9, 21, 15, 0),
      pricePerSeat: 80000,
      totalSeats: 4,
      bookedSeats: 1,
      availableSeats: 3,
      status: 'active',
      passengers: const [
        RidePassengerEntity(
          bookingId: 'b-1',
          seatsCount: 1,
          totalPrice: 80000,
          status: 'pending',
          passengerId: 'p-1',
          passengerName: 'Anvar Karimov',
          passengerPhone: '+998901234567',
        ),
      ],
    ),
  ];

  @override
  Future<PaginatedResponse<IntercityRideEntity>> getRides({
    String status = 'active',
    int page = 1,
    int limit = 15,
  }) async {
    return PaginatedResponse<IntercityRideEntity>(
      items: _rides,
      pagination: const PaginationModel(
        page: 1,
        limit: 15,
        totalItems: 1,
        totalPages: 1,
      ),
    );
  }

  @override
  Future<String> createRide(Map<String, dynamic> rideData) async {
    return 'new-ride-id';
  }

  @override
  Future<IntercityRideEntity> getRideDetails(String rideId) async {
    return _rides.first;
  }

  @override
  Future<void> updateRideStatus({
    required String rideId,
    required String status,
    String? cancelReason,
  }) async {}

  @override
  Future<void> handleBookingAction({
    required String bookingId,
    required String action,
    String? rejectReason,
  }) async {}

  @override
  Future<void> cancelBooking({
    required String bookingId,
    required String reason,
  }) async {}

  @override
  Future<void> markPickedUp(String bookingId) async {}

  @override
  Future<void> startRide(String rideId) async {}

  @override
  Future<void> completeRide(String rideId) async {}

  @override
  Future<void> updateRide({
    required String rideId,
    required Map<String, dynamic> rideData,
  }) async {}

  @override
  Future<void> deleteRide({
    required String rideId,
    String? reason,
  }) async {}
}

void main() {
  late FakeIntercityRidesRepository fakeRepo;
  late IntercityRidesBloc bloc;

  setUp(() {
    fakeRepo = FakeIntercityRidesRepository();
    bloc = IntercityRidesBloc(
      getRidesUseCase: GetRidesUseCase(fakeRepo),
      createRideUseCase: CreateRideUseCase(fakeRepo),
      getRideDetailsUseCase: GetRideDetailsUseCase(fakeRepo),
      updateRideStatusUseCase: UpdateRideStatusUseCase(fakeRepo),
      handleBookingActionUseCase: HandleBookingActionUseCase(fakeRepo),
      cancelBookingUseCase: CancelBookingUseCase(fakeRepo),
    );
  });

  tearDown(() {
    bloc.close();
  });

  group('IntercityRidesBloc Tests', () {
    test('initial state is IntercityRidesInitial', () {
      expect(bloc.state, const IntercityRidesInitial());
    });

    test('LoadRidesEvent emits [IntercityRidesLoading, IntercityRidesLoaded]',
        () async {
      bloc.add(const LoadRidesEvent(status: 'active'));

      await expectLater(
        bloc.stream,
        emitsInOrder([
          isA<IntercityRidesLoading>(),
          predicate<IntercityRidesLoaded>(
              (s) => s.rides.length == 1 && s.rides.first.id == 'ride-1'),
        ]),
      );
    });

    test('CreateRideEvent emits [CreatingRideState, RideCreatedSuccessState]',
        () async {
      bloc.add(const CreateRideEvent({
        'from_city': 'Toshkent',
        'to_city': 'Buxoro',
        'price_per_seat': 100000,
        'total_seats': 4,
      }));

      await expectLater(
        bloc.stream,
        emitsInOrder([
          isA<CreatingRideState>(),
          predicate<RideCreatedSuccessState>((s) => s.rideId == 'new-ride-id'),
        ]),
      );
    });

    test(
        'LoadRideDetailsEvent emits [IntercityRidesLoading, IntercityRideDetailsLoaded]',
        () async {
      bloc.add(const LoadRideDetailsEvent('ride-1'));

      await expectLater(
        bloc.stream,
        emitsInOrder([
          isA<IntercityRidesLoading>(),
          predicate<IntercityRideDetailsLoaded>(
              (s) => s.ride.id == 'ride-1' && s.ride.passengers.length == 1),
        ]),
      );
    });
  });
}
