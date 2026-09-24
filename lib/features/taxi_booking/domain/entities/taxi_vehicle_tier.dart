/// Vehicle tier options for Yo‘l-Yo‘lakay Taxi Booking (Economy, Comfort, Business/VIP).
enum VehicleTierType {
  economy,
  comfort,
  business,
}

class TaxiVehicleTier {
  const TaxiVehicleTier({
    required this.type,
    required this.nameUz,
    required this.nameRu,
    required this.nameEn,
    required this.carModels,
    required this.baseFare,
    required this.pricePerKm,
    required this.estimatedFare,
    required this.etaMinutes,
    required this.capacity,
    required this.description,
  });

  final VehicleTierType type;
  final String nameUz;
  final String nameRu;
  final String nameEn;
  final String carModels;
  final int baseFare;
  final int pricePerKm;
  final int estimatedFare;
  final int etaMinutes;
  final int capacity;
  final String description;

  String localizedName(String localeCode) {
    switch (localeCode) {
      case 'ru':
        return nameRu;
      case 'en':
        return nameEn;
      default:
        return nameUz;
    }
  }

  TaxiVehicleTier copyWith({
    int? estimatedFare,
    int? etaMinutes,
  }) {
    return TaxiVehicleTier(
      type: type,
      nameUz: nameUz,
      nameRu: nameRu,
      nameEn: nameEn,
      carModels: carModels,
      baseFare: baseFare,
      pricePerKm: pricePerKm,
      estimatedFare: estimatedFare ?? this.estimatedFare,
      etaMinutes: etaMinutes ?? this.etaMinutes,
      capacity: capacity,
      description: description,
    );
  }
}
