import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:yol_yolakay_driver/features/home/domain/entities/city_entity.dart';
import 'package:yol_yolakay_driver/features/rides/domain/entities/ride_entity.dart';
import 'package:yol_yolakay_driver/features/rides/domain/repositories/ride_repository.dart';

enum RideSortOption { cheapest, earliest, fastest, rating }

class RideSearchFilter {
  const RideSearchFilter({
    this.maxPrice,
    this.minRating,
    this.hasAc,
    this.carType,
    this.sortOption = RideSortOption.cheapest,
  });

  final int? maxPrice;
  final double? minRating;
  final bool? hasAc;
  final String? carType;
  final RideSortOption sortOption;

  RideSearchFilter copyWith({
    int? maxPrice,
    double? minRating,
    bool? hasAc,
    String? carType,
    RideSortOption? sortOption,
  }) {
    return RideSearchFilter(
      maxPrice: maxPrice ?? this.maxPrice,
      minRating: minRating ?? this.minRating,
      hasAc: hasAc ?? this.hasAc,
      carType: carType ?? this.carType,
      sortOption: sortOption ?? this.sortOption,
    );
  }
}

class RideSearchState {
  const RideSearchState({
    this.departureCity,
    this.destinationCity,
    this.travelDate,
    this.passengerCount = 1,
    this.rides = const [],
    this.filteredRides = const [],
    this.isLoading = false,
    this.filter = const RideSearchFilter(),
  });

  final CityEntity? departureCity;
  final CityEntity? destinationCity;
  final DateTime? travelDate;
  final int passengerCount;
  final List<RideEntity> rides;
  final List<RideEntity> filteredRides;
  final bool isLoading;
  final RideSearchFilter filter;

  RideSearchState copyWith({
    CityEntity? departureCity,
    CityEntity? destinationCity,
    DateTime? travelDate,
    int? passengerCount,
    List<RideEntity>? rides,
    List<RideEntity>? filteredRides,
    bool? isLoading,
    RideSearchFilter? filter,
  }) {
    return RideSearchState(
      departureCity: departureCity ?? this.departureCity,
      destinationCity: destinationCity ?? this.destinationCity,
      travelDate: travelDate ?? this.travelDate,
      passengerCount: passengerCount ?? this.passengerCount,
      rides: rides ?? this.rides,
      filteredRides: filteredRides ?? this.filteredRides,
      isLoading: isLoading ?? this.isLoading,
      filter: filter ?? this.filter,
    );
  }
}

class RideSearchNotifier extends StateNotifier<RideSearchState> {
  RideSearchNotifier(this._rideRepository) : super(const RideSearchState());

  final RideRepository _rideRepository;

  void setDepartureCity(CityEntity? city) {
    state = RideSearchState(
      departureCity: city,
      destinationCity: state.destinationCity,
      travelDate: state.travelDate,
      passengerCount: state.passengerCount,
      rides: state.rides,
      filteredRides: state.filteredRides,
      isLoading: state.isLoading,
      filter: state.filter,
    );
  }

  void setDestinationCity(CityEntity? city) {
    state = RideSearchState(
      departureCity: state.departureCity,
      destinationCity: city,
      travelDate: state.travelDate,
      passengerCount: state.passengerCount,
      rides: state.rides,
      filteredRides: state.filteredRides,
      isLoading: state.isLoading,
      filter: state.filter,
    );
  }

  void clearDepartureCity() => setDepartureCity(null);

  void clearDestinationCity() => setDestinationCity(null);

  void swapCities() {
    final temp = state.departureCity;
    state = state.copyWith(
      departureCity: state.destinationCity,
      destinationCity: temp,
    );
  }

  void setTravelDate(DateTime date) {
    state = state.copyWith(travelDate: date);
  }

  void setPassengerCount(int count) {
    state = state.copyWith(passengerCount: count);
  }

  Future<void> searchRides() async {
    if (state.departureCity == null || state.destinationCity == null) return;

    state = state.copyWith(isLoading: true);
    final results = await _rideRepository.searchRides(
      RideSearchParams(
        departureCityId: state.departureCity!.id,
        destinationCityId: state.destinationCity!.id,
        date: state.travelDate ?? DateTime.now(),
        passengerCount: state.passengerCount,
      ),
    );

    state = state.copyWith(
      rides: results,
      isLoading: false,
    );
    applyFilter(state.filter);
  }

  void applyFilter(RideSearchFilter filter) {
    var list = List<RideEntity>.from(state.rides);

    if (filter.maxPrice != null) {
      list = list.where((r) => r.pricePerSeat <= filter.maxPrice!).toList();
    }
    if (filter.minRating != null) {
      list = list.where((r) => r.driver.rating >= filter.minRating!).toList();
    }
    if (filter.hasAc == true) {
      list = list.where((r) => r.vehicle.hasAc).toList();
    }

    switch (filter.sortOption) {
      case RideSortOption.cheapest:
        list.sort((a, b) => a.pricePerSeat.compareTo(b.pricePerSeat));
        break;
      case RideSortOption.earliest:
        list.sort((a, b) => a.departureTime.compareTo(b.departureTime));
        break;
      case RideSortOption.fastest:
        list.sort((a, b) => a.duration.compareTo(b.duration));
        break;
      case RideSortOption.rating:
        list.sort((a, b) => b.driver.rating.compareTo(a.driver.rating));
        break;
    }

    state = state.copyWith(
      filter: filter,
      filteredRides: list,
    );
  }
}

final rideSearchNotifierProvider =
    StateNotifierProvider<RideSearchNotifier, RideSearchState>((ref) {
  final repo = ref.watch(rideRepositoryProvider);
  return RideSearchNotifier(repo);
});

final popularRidesProvider = FutureProvider<List<RideEntity>>((ref) {
  final repo = ref.watch(rideRepositoryProvider);
  return repo.getPopularRides();
});
