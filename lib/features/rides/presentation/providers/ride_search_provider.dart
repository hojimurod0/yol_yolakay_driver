import 'package:yol_yolakay_driver/features/home/domain/entities/city_entity.dart';
import 'package:yol_yolakay_driver/features/rides/domain/entities/ride_entity.dart';

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
    this.filter = const RideSearchFilter(),
    this.allRides = const [],
    this.filteredRides = const [],
    this.isLoading = false,
    this.hasSearched = false,
  });

  final CityEntity? departureCity;
  final CityEntity? destinationCity;
  final DateTime? travelDate;
  final int passengerCount;
  final RideSearchFilter filter;
  final List<RideEntity> allRides;
  final List<RideEntity> filteredRides;
  final bool isLoading;
  final bool hasSearched;
}
