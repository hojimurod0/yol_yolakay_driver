import 'package:yol_yolakay_driver/core/utils/distance_calculator.dart';
import 'package:yol_yolakay_driver/features/home/domain/entities/city_entity.dart';
import 'package:yol_yolakay_driver/features/home/domain/entities/location_point_entity.dart';
import 'package:yol_yolakay_driver/features/rides/domain/entities/driver_entity.dart';
import 'package:yol_yolakay_driver/features/rides/domain/entities/ride_entity.dart';
import 'package:yol_yolakay_driver/features/rides/domain/entities/vehicle_entity.dart';
import 'package:yol_yolakay_driver/features/rides/domain/repositories/ride_repository.dart';

/// Dynamic, realistic ride repository strictly for Fergana Valley routes
/// (Andijon, Farg'ona, Namangan) with authentic drivers, vehicles, and real intercity routes.
class MockRideRepository implements RideRepository {
  static const CityEntity _defaultFrom = CityEntity(
    id: 'andijan_markaz',
    nameUz: 'Andijon - Markaz (Shahar)',
    nameRu: 'Андижан - Центр (Город)',
    nameEn: 'Andijan - Center (City)',
    region: 'Andijon viloyati',
    isPopular: true,
    latitude: 40.7821,
    longitude: 72.3442,
  );

  static const CityEntity _defaultTo = CityEntity(
    id: 'fergana_qoqon',
    nameUz: 'Farg\'ona - Qo\'qon shahri',
    nameRu: 'Фергана - г. Коканд',
    nameEn: 'Fergana - Kokand City',
    region: 'Farg\'ona viloyati',
    isPopular: true,
    latitude: 40.5286,
    longitude: 70.9425,
  );

  static final List<DriverEntity> _drivers = [
    const DriverEntity(
      id: 'drv_01',
      name: 'Azizbek Rahimov',
      phoneNumber: '+998 90 987 65 43',
      rating: 4.95,
      completedTrips: 420,
      isVerified: true,
      telegramHandle: 'aziz_vodiy_taxi',
      experienceYears: 6,
      bio:
          'Toshkent-Vodiy qatnovi bo\'yicha 6 yillik professional haydovchi. Yangi Chevrolet Cobalt.',
    ),
    const DriverEntity(
      id: 'drv_02',
      name: 'Sherzod Aliyev',
      phoneNumber: '+998 93 456 12 34',
      rating: 4.88,
      completedTrips: 312,
      isVerified: true,
      telegramHandle: 'sherzod_driver',
      experienceYears: 4,
      bio: 'Konditsionerli Gentra, xavfsiz va tezkor yetkazish.',
    ),
    const DriverEntity(
      id: 'drv_03',
      name: 'Jahongir Qodirov',
      phoneNumber: '+998 97 111 22 33',
      rating: 5.0,
      completedTrips: 680,
      isVerified: true,
      telegramHandle: 'jahongir_trans',
      experienceYears: 8,
      bio:
          'Oliy toifali haydovchi, BYD Song Plus qulay va shinam elektromobil.',
    ),
    const DriverEntity(
      id: 'drv_04',
      name: 'Dilshodbek Normatov',
      phoneNumber: '+998 91 222 33 44',
      rating: 4.85,
      completedTrips: 195,
      isVerified: true,
      telegramHandle: 'dilshod_taxi',
      experienceYears: 3,
      bio: 'Posilka va yo\'lovchilar uchun katta bagajli Monza.',
    ),
    const DriverEntity(
      id: 'drv_05',
      name: 'Rustamjon Ismoilov',
      phoneNumber: '+998 90 555 77 88',
      rating: 4.9,
      completedTrips: 540,
      isVerified: true,
      telegramHandle: 'rustam_express',
      experienceYears: 7,
      bio: 'Tezkor va xushmuomala xizmat ko\'rsatish.',
    ),
    const DriverEntity(
      id: 'drv_06',
      name: 'Otabek Mirzayev',
      phoneNumber: '+998 94 333 44 55',
      rating: 4.82,
      completedTrips: 270,
      isVerified: true,
      telegramHandle: 'otabek_fergana',
      experienceYears: 5,
    ),
    const DriverEntity(
      id: 'drv_07',
      name: 'Bobur Mansurov',
      phoneNumber: '+998 99 888 11 22',
      rating: 4.92,
      completedTrips: 380,
      isVerified: true,
      telegramHandle: 'bobur_andijan',
      experienceYears: 6,
    ),
    const DriverEntity(
      id: 'drv_08',
      name: 'Ulug\'bek Turg\'unov',
      phoneNumber: '+998 90 777 44 55',
      rating: 4.89,
      completedTrips: 450,
      isVerified: true,
      telegramHandle: 'ulugbek_namangan',
      experienceYears: 7,
    ),
  ];

  static final List<VehicleEntity> _vehicles = [
    const VehicleEntity(
      id: 'veh_01',
      make: 'Chevrolet',
      model: 'Cobalt',
      color: 'Oq (White)',
      licensePlate: '60 A 777 BA',
      type: VehicleType.sedan,
      hasAc: true,
      hasSpaciousTrunk: true,
      hasWifi: false,
    ),
    const VehicleEntity(
      id: 'veh_02',
      make: 'Chevrolet',
      model: 'Gentra',
      color: 'Qora (Black)',
      licensePlate: '40 O 001 AA',
      type: VehicleType.sedan,
      hasAc: true,
      hasSpaciousTrunk: true,
      hasWifi: true,
    ),
    const VehicleEntity(
      id: 'veh_03',
      make: 'Chevrolet',
      model: 'Monza',
      color: 'Kulrang (Grey)',
      licensePlate: '50 X 555 YA',
      type: VehicleType.sedan,
      hasAc: true,
      hasSpaciousTrunk: true,
      hasWifi: true,
    ),
    const VehicleEntity(
      id: 'veh_04',
      make: 'Chevrolet',
      model: 'Nexia 3',
      color: 'Oq (White)',
      licensePlate: '60 B 123 CA',
      type: VehicleType.sedan,
      hasAc: true,
      hasSpaciousTrunk: false,
      hasWifi: false,
    ),
    const VehicleEntity(
      id: 'veh_05',
      make: 'Chevrolet',
      model: 'Tracker',
      color: 'Oq (White)',
      licensePlate: '40 T 789 AA',
      type: VehicleType.crossover,
      hasAc: true,
      hasSpaciousTrunk: true,
      hasWifi: true,
    ),
    const VehicleEntity(
      id: 'veh_06',
      make: 'Kia',
      model: 'K5',
      color: 'Qora (Black)',
      licensePlate: '50 K 700 AA',
      type: VehicleType.sedan,
      hasAc: true,
      hasSpaciousTrunk: true,
      hasWifi: true,
    ),
  ];

  static final List<RideEntity> _popularVodiyRides = [
    // 1. Andijon Markaz -> Farg'ona Qo'qon
    RideEntity(
      id: 'ride_vodiy_01',
      driver: _drivers[0],
      vehicle: _vehicles[0],
      departureCity: const CityEntity(
        id: 'andijan_markaz',
        nameUz: 'Andijon - Markaz (Shahar)',
        nameRu: 'Андижан - Центр (Город)',
        nameEn: 'Andijan - Center (City)',
        region: 'Andijon viloyati',
        isPopular: true,
        latitude: 40.7821,
        longitude: 72.3442,
      ),
      destinationCity: const CityEntity(
        id: 'fergana_qoqon',
        nameUz: 'Farg\'ona - Qo\'qon shahri',
        nameRu: 'Фергана - г. Коканд',
        nameEn: 'Fergana - Kokand City',
        region: 'Farg\'ona viloyati',
        isPopular: true,
        latitude: 40.5286,
        longitude: 70.9425,
      ),
      departureTime: DateTime.now().add(const Duration(hours: 1, minutes: 15)),
      estimatedArrivalTime:
          DateTime.now().add(const Duration(hours: 3, minutes: 0)),
      pricePerSeat: 45000,
      totalSeats: 4,
      availableSeats: 3,
      pickupPoints: const [
        LocationPointEntity(
          id: 'pickup_and_01',
          title: 'Andijon Avtovokzal',
          description: 'Bobur shoh ko\'chasi, Andijon',
          latitude: 40.7821,
          longitude: 72.3442,
        ),
      ],
      dropoffPoints: const [
        LocationPointEntity(
          id: 'drop_qoq_01',
          title: 'Qo\'qon Markaziy Vokzal',
          description: 'Furqat ko\'chasi, Qo\'qon',
          latitude: 40.5286,
          longitude: 70.9425,
        ),
      ],
    ),

    // 2. Namangan Markaz -> Farg'ona Markaz
    RideEntity(
      id: 'ride_vodiy_02',
      driver: _drivers[1],
      vehicle: _vehicles[1],
      departureCity: const CityEntity(
        id: 'namangan_markaz',
        nameUz: 'Namangan - Markaz (Shahar)',
        nameRu: 'Наманган - Центр (Город)',
        nameEn: 'Namangan - Center (City)',
        region: 'Namangan viloyati',
        isPopular: true,
        latitude: 41.0011,
        longitude: 71.6683,
      ),
      destinationCity: const CityEntity(
        id: 'fergana_markaz',
        nameUz: 'Farg\'ona - Markaz (Shahar)',
        nameRu: 'Фергана - Центр (Город)',
        nameEn: 'Fergana - Center (City)',
        region: 'Farg\'ona viloyati',
        isPopular: true,
        latitude: 40.3864,
        longitude: 71.7864,
      ),
      departureTime: DateTime.now().add(const Duration(hours: 2)),
      estimatedArrivalTime:
          DateTime.now().add(const Duration(hours: 3, minutes: 40)),
      pricePerSeat: 35000,
      totalSeats: 4,
      availableSeats: 2,
      pickupPoints: const [
        LocationPointEntity(
          id: 'pickup_nam_01',
          title: 'Namangan Sardoba bozori',
          description: 'Uychi ko\'chasi, Namangan',
          latitude: 41.0011,
          longitude: 71.6683,
        ),
      ],
      dropoffPoints: const [
        LocationPointEntity(
          id: 'drop_fer_01',
          title: 'Farg\'ona Yoshlar markazi',
          description: 'Al-Farg\'oniy ko\'chasi, Farg\'ona',
          latitude: 40.3864,
          longitude: 71.7864,
        ),
      ],
    ),

    // 3. Andijon Asaka -> Farg'ona Marg'ilon
    RideEntity(
      id: 'ride_vodiy_03',
      driver: _drivers[2],
      vehicle: _vehicles[2],
      departureCity: const CityEntity(
        id: 'andijan_asaka',
        nameUz: 'Andijon - Asaka shahri',
        nameRu: 'Андижан - г. Асака',
        nameEn: 'Andijan - Asaka City',
        region: 'Andijon viloyati',
        isPopular: true,
        latitude: 40.6417,
        longitude: 72.2389,
      ),
      destinationCity: const CityEntity(
        id: 'fergana_margilon',
        nameUz: 'Farg\'ona - Marg\'ilon shahri',
        nameRu: 'Фергана - г. Маргилан',
        nameEn: 'Fergana - Margilan City',
        region: 'Farg\'ona viloyati',
        isPopular: true,
        latitude: 40.4722,
        longitude: 71.7139,
      ),
      departureTime: DateTime.now().add(const Duration(hours: 2, minutes: 45)),
      estimatedArrivalTime:
          DateTime.now().add(const Duration(hours: 3, minutes: 50)),
      pricePerSeat: 30000,
      totalSeats: 4,
      availableSeats: 4,
      pickupPoints: const [
        LocationPointEntity(
          id: 'pickup_asa_01',
          title: 'Asaka Avtoshahar',
          description: 'Z.M. Bobur ko\'chasi, Asaka',
          latitude: 40.6417,
          longitude: 72.2389,
        ),
      ],
      dropoffPoints: const [
        LocationPointEntity(
          id: 'drop_mar_01',
          title: 'Marg\'ilon Ipak bozori',
          description: 'B. Marg\'iloniy ko\'chasi, Marg\'ilon',
          latitude: 40.4722,
          longitude: 71.7139,
        ),
      ],
    ),

    // 4. Namangan Chust -> Andijon Markaz
    RideEntity(
      id: 'ride_vodiy_04',
      driver: _drivers[3],
      vehicle: _vehicles[4],
      departureCity: const CityEntity(
        id: 'namangan_chust',
        nameUz: 'Namangan - Chust shahri',
        nameRu: 'Наманган - г. Чуст',
        nameEn: 'Namangan - Chust',
        region: 'Namangan viloyati',
        isPopular: true,
        latitude: 41.0000,
        longitude: 71.2333,
      ),
      destinationCity: const CityEntity(
        id: 'andijan_markaz',
        nameUz: 'Andijon - Markaz (Shahar)',
        nameRu: 'Андижан - Центр (Город)',
        nameEn: 'Andijan - Center (City)',
        region: 'Andijon viloyati',
        isPopular: true,
        latitude: 40.7821,
        longitude: 72.3442,
      ),
      departureTime: DateTime.now().add(const Duration(hours: 3, minutes: 30)),
      estimatedArrivalTime:
          DateTime.now().add(const Duration(hours: 5, minutes: 15)),
      pricePerSeat: 50000,
      totalSeats: 4,
      availableSeats: 2,
      pickupPoints: const [
        LocationPointEntity(
          id: 'pickup_chu_01',
          title: 'Chust Pichoqchilar rastasi',
          description: 'Markaziy ko\'cha, Chust',
          latitude: 41.0000,
          longitude: 71.2333,
        ),
      ],
      dropoffPoints: const [
        LocationPointEntity(
          id: 'drop_and_02',
          title: 'Andijon Yangi bozor',
          description: 'Mashrab ko\'chasi, Andijon',
          latitude: 40.7821,
          longitude: 72.3442,
        ),
      ],
    ),
  ];

  @override
  Future<List<RideEntity>> searchRides(RideSearchParams params) async {
    await Future.delayed(const Duration(milliseconds: 300));

    final from = _popularVodiyRides
            .where((r) => r.departureCity.id == params.departureCityId)
            .map((r) => r.departureCity)
            .firstOrNull ??
        _defaultFrom;

    final to = _popularVodiyRides
            .where((r) => r.destinationCity.id == params.destinationCityId)
            .map((r) => r.destinationCity)
            .firstOrNull ??
        _defaultTo;

    final travelDate = params.date;

    final distanceKm = DistanceCalculator.calculateDistanceKm(
      lat1: from.latitude,
      lon1: from.longitude,
      lat2: to.latitude,
      lon2: to.longitude,
    );

    final basePrice = DistanceCalculator.calculatePricePerSeat(distanceKm);
    final durationMinutes =
        DistanceCalculator.estimateDurationMinutes(distanceKm);

    return List.generate(4, (index) {
      final driver = _drivers[index % _drivers.length];
      final vehicle = _vehicles[index % _vehicles.length];
      final depTime =
          travelDate.add(Duration(hours: index * 2 + 1, minutes: index * 15));
      final arrTime = depTime.add(Duration(minutes: durationMinutes));

      final priceVariance = (index - 1) * 3000;
      final finalPrice = ((basePrice + priceVariance) / 1000).round() * 1000;
      final clampedPrice = finalPrice.clamp(10000, 90000);

      return RideEntity(
        id: 'ride_${from.id}_${to.id}_$index',
        driver: driver,
        vehicle: vehicle,
        departureCity: from,
        destinationCity: to,
        departureTime: depTime,
        estimatedArrivalTime: arrTime,
        pricePerSeat: clampedPrice,
        totalSeats: 4,
        availableSeats: (4 - index).clamp(1, 4),
        pickupPoints: [
          LocationPointEntity(
            id: 'pick_${from.id}_$index',
            title: '${from.nameUz} (Asosiy bekat)',
            description: 'Markaziy avtoshoxbekat',
            latitude: from.latitude,
            longitude: from.longitude,
          ),
        ],
        dropoffPoints: [
          LocationPointEntity(
            id: 'drop_${to.id}_$index',
            title: '${to.nameUz} (Tushish joyi)',
            description: 'Markaziy bekat / Manzil bo\'yicha',
            latitude: to.latitude,
            longitude: to.longitude,
          ),
        ],
      );
    });
  }

  @override
  Future<List<RideEntity>> getPopularRides() async {
    await Future.delayed(const Duration(milliseconds: 200));
    return _popularVodiyRides;
  }

  @override
  Future<RideEntity> getRideDetails(String rideId) async {
    await Future.delayed(const Duration(milliseconds: 150));
    try {
      return _popularVodiyRides.firstWhere((r) => r.id == rideId);
    } catch (_) {
      return _popularVodiyRides.first;
    }
  }
}
