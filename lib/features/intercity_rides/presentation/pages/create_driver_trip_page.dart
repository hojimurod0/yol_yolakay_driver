import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_responsive.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/app_date_formatter.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_snackbar.dart';
import '../../../../l10n/generated/app_localizations.dart';
import '../../../profile/presentation/bloc/profile_bloc.dart';
import '../../../verification/domain/entities/verification_entities.dart';
import '../../../verification/presentation/bloc/verification_bloc.dart';
import '../../../verification/presentation/bloc/verification_event.dart';
import '../../../verification/presentation/bloc/verification_state.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../domain/entities/intercity_ride_entity.dart';
import '../bloc/intercity_rides_bloc.dart';
import '../bloc/intercity_rides_event.dart';
import '../bloc/intercity_rides_state.dart';

/// Intelligent Uzbekistan intercity pricing recommendation model
class RoutePriceRecommendation {
  const RoutePriceRecommendation({
    required this.economyPrice,
    required this.recommendedPrice,
    required this.comfortPrice,
    required this.distanceKm,
    required this.routeName,
  });

  final int economyPrice;
  final int recommendedPrice;
  final int comfortPrice;
  final int distanceKm;
  final String routeName;
}

class CreateDriverTripPage extends StatefulWidget {
  const CreateDriverTripPage({super.key, this.editRide});

  final IntercityRideEntity? editRide;

  @override
  State<CreateDriverTripPage> createState() => _CreateDriverTripPageState();
}

class _CreateDriverTripPageState extends State<CreateDriverTripPage> {
  final _formKey = GlobalKey<FormState>();

  // Full default list of Uzbekistan cities so user is never blocked
  static const List<CityEntity> _defaultCities = [
    CityEntity(id: 'tashkent', name: 'Toshkent', region: 'Toshkent shahri', latitude: 41.2995, longitude: 69.2401),
    CityEntity(id: 'samarkand', name: 'Samarqand', region: 'Samarqand viloyati', latitude: 39.6547, longitude: 66.9758),
    CityEntity(id: 'bukhara', name: 'Buxoro', region: 'Buxoro viloyati', latitude: 39.7681, longitude: 64.4556),
    CityEntity(id: 'andijan', name: 'Andijon', region: 'Andijon viloyati', latitude: 40.7821, longitude: 72.3442),
    CityEntity(id: 'fergana', name: 'Farg\'ona', region: 'Farg\'ona viloyati', latitude: 40.3842, longitude: 71.7843),
    CityEntity(id: 'namangan', name: 'Namangan', region: 'Namangan viloyati', latitude: 40.9983, longitude: 71.6726),
    CityEntity(id: 'qarshi', name: 'Qarshi', region: 'Qashqadaryo viloyati', latitude: 38.8606, longitude: 65.7891),
    CityEntity(id: 'termez', name: 'Termiz', region: 'Surxondaryo viloyati', latitude: 37.2286, longitude: 67.2753),
    CityEntity(id: 'navoiy', name: 'Navoiy', region: 'Navoiy viloyati', latitude: 40.0844, longitude: 65.3792),
    CityEntity(id: 'jizzakh', name: 'Jizzax', region: 'Jizzax viloyati', latitude: 40.1158, longitude: 67.8422),
    CityEntity(id: 'gulistan', name: 'Guliston', region: 'Sirdaryo viloyati', latitude: 40.4897, longitude: 68.7842),
    CityEntity(id: 'urgench', name: 'Urganch', region: 'Xorazm viloyati', latitude: 41.5562, longitude: 60.6313),
    CityEntity(id: 'nukus', name: 'Nukus', region: 'Qoraqalpog\'iston', latitude: 42.4619, longitude: 59.6166),
    CityEntity(id: 'khiva', name: 'Xiva', region: 'Xorazm viloyati', latitude: 41.3783, longitude: 60.3639),
    CityEntity(id: 'kokand', name: 'Qo\'qon', region: 'Farg\'ona viloyati', latitude: 40.5342, longitude: 70.9428),
    CityEntity(id: 'shakhrisabz', name: 'Shahrisabz', region: 'Qashqadaryo viloyati', latitude: 39.0573, longitude: 66.8339),
  ];

  String _fromCityId = 'tashkent';
  String _toCityId = 'samarkand';

  DateTime _departureDateTime = DateTime.now().add(const Duration(hours: 2));
  final _priceController = TextEditingController(text: '80000');
  int _totalSeats = 4;
  bool _hasAc = true;
  bool _allowLuggage = true;
  bool _womenOnly = false;
  final _pickupController = TextEditingController(text: 'Shahar markazi');
  final _dropoffController = TextEditingController(text: 'Vokzal maydoni');
  final _commentController = TextEditingController();

  bool get _isEditMode => widget.editRide != null;
  Map<String, dynamic>? _lastSavedTrip;

  @override
  void initState() {
    super.initState();
    context.read<VerificationBloc>().add(const LoadCitiesEvent());

    if (widget.editRide != null) {
      final ride = widget.editRide!;
      _fromCityId = _resolveCityIdFromName(ride.fromCity);
      _toCityId = _resolveCityIdFromName(ride.toCity);
      _departureDateTime = ride.departureTime;
      _priceController.text = ride.pricePerSeat.toString();
      _totalSeats = ride.totalSeats;
      _hasAc = ride.hasAc;
      _allowLuggage = ride.allowLuggage;
      _womenOnly = ride.womenOnly;
      if (ride.comment != null && ride.comment!.isNotEmpty) {
        _commentController.text = ride.comment!;
      }
    } else {
      _loadLastSavedTrip();
      if (_lastSavedTrip == null) {
        final rec = _calculateRoutePricing(_fromCityId, _toCityId);
        _priceController.text = rec.recommendedPrice.toString();
      }
    }
  }

  String _resolveCityIdFromName(String cityName) {
    final lower = cityName.trim().toLowerCase();
    for (final c in _defaultCities) {
      if (c.id.toLowerCase() == lower || c.name.toLowerCase() == lower) {
        return c.id;
      }
    }
    return lower;
  }

  void _loadLastSavedTrip() {
    try {
      final storage = sl<SharedPreferences>();
      final from = storage.getString('last_trip_from');
      final to = storage.getString('last_trip_to');
      final price = storage.getInt('last_trip_price');
      final seats = storage.getInt('last_trip_seats');
      if (from != null && to != null && from.isNotEmpty && to.isNotEmpty) {
        setState(() {
          _lastSavedTrip = {
            'from': from,
            'to': to,
            'price': price ?? 80000,
            'seats': seats ?? 4,
          };
        });
      }
    } catch (_) {}
  }

  void _applyLastTrip() {
    if (_lastSavedTrip == null) return;
    HapticFeedback.mediumImpact();
    setState(() {
      _fromCityId = _lastSavedTrip!['from'] as String;
      _toCityId = _lastSavedTrip!['to'] as String;
      _priceController.text = (_lastSavedTrip!['price'] as int).toString();
      _totalSeats = _lastSavedTrip!['seats'] as int;
    });
    AppSnackBar.showSuccess(context, 'Oxirgi qatnov parametrlari tiklandi!');
  }

  void _saveLastTrip(String from, String to, int price, int seats) {
    try {
      final storage = sl<SharedPreferences>();
      storage.setString('last_trip_from', from);
      storage.setString('last_trip_to', to);
      storage.setInt('last_trip_price', price);
      storage.setInt('last_trip_seats', seats);
    } catch (_) {}
  }

  @override
  void dispose() {
    _priceController.dispose();
    _pickupController.dispose();
    _dropoffController.dispose();
    _commentController.dispose();
    super.dispose();
  }

  List<CityEntity> _resolveCities(VerificationState vState) {
    if (vState is CitiesLoadedState && vState.cities.isNotEmpty) {
      final map = <String, CityEntity>{};
      for (final c in _defaultCities) {
        map[c.id] = c;
      }
      for (final c in vState.cities) {
        map[c.id] = c;
      }
      return map.values.toList();
    }
    return _defaultCities;
  }

  CityEntity _getCityById(String id, List<CityEntity> cities) {
    return cities.firstWhere(
      (c) => c.id == id,
      orElse: () => CityEntity(id: id, name: id, region: ''),
    );
  }

  RoutePriceRecommendation _calculateRoutePricing(String fromId, String toId,
      [List<CityEntity>? cities]) {
    final cityList = cities ?? _defaultCities;
    final fromCity = _getCityById(fromId, cityList);
    final toCity = _getCityById(toId, cityList);
    final routeName = '${fromCity.name} ➔ ${toCity.name}';

    final pair = [fromId.toLowerCase().trim(), toId.toLowerCase().trim()]
      ..sort();
    final pairKey = '${pair[0]}_${pair[1]}';

    const Map<String, List<int>> knownRoutes = {
      'samarkand_tashkent': [75000, 85000, 100000, 305],
      'bukhara_tashkent': [130000, 150000, 180000, 580],
      'navoiy_tashkent': [115000, 130000, 155000, 485],
      'fergana_tashkent': [75000, 85000, 100000, 310],
      'andijan_tashkent': [85000, 95000, 115000, 360],
      'namangan_tashkent': [75000, 85000, 100000, 295],
      'kokand_tashkent': [70000, 80000, 95000, 235],
      'qarshi_tashkent': [105000, 120000, 140000, 450],
      'tashkent_termez': [160000, 180000, 210000, 670],
      'tashkent_urgench': [220000, 250000, 290000, 970],
      'khiva_tashkent': [230000, 260000, 300000, 1000],
      'nukus_tashkent': [250000, 280000, 320000, 1100],
      'jizzakh_tashkent': [45000, 55000, 70000, 205],
      'gulistan_tashkent': [30000, 35000, 45000, 115],
      'shakhrisabz_tashkent': [95000, 110000, 130000, 410],
      'bukhara_samarkand': [55000, 65000, 80000, 270],
      'qarshi_samarkand': [40000, 50000, 65000, 160],
      'navoiy_samarkand': [35000, 45000, 60000, 175],
      'jizzakh_samarkand': [35000, 40000, 50000, 110],
      'samarkand_termez': [115000, 130000, 155000, 380],
      'samarkand_shakhrisabz': [30000, 35000, 45000, 90],
      'bukhara_navoiy': [30000, 35000, 45000, 105],
      'bukhara_urgench': [120000, 140000, 170000, 440],
      'bukhara_qarshi': [60000, 70000, 85000, 200],
      'andijan_fergana': [20000, 25000, 35000, 75],
      'fergana_namangan': [20000, 25000, 35000, 80],
      'andijan_namangan': [20000, 25000, 35000, 70],
      'fergana_kokand': [20000, 25000, 35000, 85],
      'andijan_kokand': [30000, 35000, 45000, 135],
      'kokand_namangan': [25000, 30000, 40000, 100],
      'qarshi_termez': [70000, 80000, 100000, 220],
      'qarshi_shakhrisabz': [20000, 25000, 35000, 80],
      'nukus_urgench': [35000, 45000, 60000, 150],
      'khiva_urgench': [10000, 15000, 25000, 35],
    };

    if (knownRoutes.containsKey(pairKey)) {
      final data = knownRoutes[pairKey]!;
      return RoutePriceRecommendation(
        economyPrice: data[0],
        recommendedPrice: data[1],
        comfortPrice: data[2],
        distanceKm: data[3],
        routeName: routeName,
      );
    }

    final lat1 = fromCity.latitude ?? 41.2995;
    final lon1 = fromCity.longitude ?? 69.2401;
    final lat2 = toCity.latitude ?? 39.6547;
    final lon2 = toCity.longitude ?? 66.9758;

    const p = 0.017453292519943295;
    final a = 0.5 -
        math.cos((lat2 - lat1) * p) / 2 +
        math.cos(lat1 * p) *
            math.cos(lat2 * p) *
            (1 - math.cos((lon2 - lon1) * p)) /
            2;
    final distKm = (12742 * math.asin(math.sqrt(a))).round();
    final roadDistKm = math.max((distKm * 1.18).round(), 20);

    final rawMarket = (roadDistKm * 290.0 / 5000).round() * 5000;
    final market = rawMarket.clamp(25000, 350000);
    final economy = ((market * 0.88) / 5000).round() * 5000;
    final comfort = ((market * 1.20) / 5000).round() * 5000;

    return RoutePriceRecommendation(
      economyPrice: economy,
      recommendedPrice: market,
      comfortPrice: comfort,
      distanceKm: roadDistKm,
      routeName: routeName,
    );
  }

  void _applySmartRecommendationIfDefault() {
    if (_isEditMode) return;
    final rec = _calculateRoutePricing(_fromCityId, _toCityId);
    _priceController.text = rec.recommendedPrice.toString();
  }

  void _swapCities() {
    HapticFeedback.selectionClick();
    setState(() {
      final temp = _fromCityId;
      _fromCityId = _toCityId;
      _toCityId = temp;
      _applySmartRecommendationIfDefault();
    });
  }

  Future<void> _selectDateTime() async {
    final now = DateTime.now();
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: _departureDateTime.isBefore(now) ? now : _departureDateTime,
      firstDate: now,
      lastDate: now.add(const Duration(days: 30)),
    );

    if (pickedDate != null && mounted) {
      final pickedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(_departureDateTime),
      );

      if (pickedTime != null) {
        setState(() {
          _departureDateTime = DateTime(
            pickedDate.year,
            pickedDate.month,
            pickedDate.day,
            pickedTime.hour,
            pickedTime.minute,
          );
        });
      }
    }
  }

  void _setQuickTime(Duration offset) {
    setState(() {
      _departureDateTime = DateTime.now().add(offset);
    });
  }

  void _showCitySearchSheet({
    required bool isFrom,
    required List<CityEntity> cities,
  }) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return _CitySelectionModal(
          title: isFrom ? 'Qayerdan (Jo\'nash shahri)' : 'Qayerga (Borish shahri)',
          cities: cities,
          selectedCityId: isFrom ? _fromCityId : _toCityId,
          onCitySelected: (city) {
            setState(() {
              if (isFrom) {
                _fromCityId = city.id;
              } else {
                _toCityId = city.id;
              }
              _applySmartRecommendationIfDefault();
            });
            Navigator.pop(ctx);
          },
        );
      },
    );
  }

  void _submit(AppLocalizations l10n) {
    final profile = context.read<ProfileBloc>().state.profile;
    if (profile != null &&
        profile.verificationStatus != 'approved' &&
        profile.verificationStatus != 'under_review') {
      AppSnackBar.showWarning(context, l10n.verificationRequiredMessage);
      context.push('/verification');
      return;
    }

    if (!_formKey.currentState!.validate()) return;

    if (_fromCityId.isEmpty || _toCityId.isEmpty) {
      AppSnackBar.showError(context, l10n.selectCitiesPrompt);
      return;
    }

    if (_fromCityId == _toCityId) {
      AppSnackBar.showError(context, l10n.citiesMustBeDifferentPrompt);
      return;
    }

    final cleanPriceText = _priceController.text.replaceAll(RegExp(r'\D'), '');
    final price = int.tryParse(cleanPriceText) ?? 80000;

    final pickupText = _pickupController.text.trim().isNotEmpty
        ? _pickupController.text.trim()
        : 'Shahar markazi';
    final dropoffText = _dropoffController.text.trim().isNotEmpty
        ? _dropoffController.text.trim()
        : 'Vokzal maydoni';

    final cities = _resolveCities(context.read<VerificationBloc>().state);
    final fromCity = _getCityById(_fromCityId, cities);
    final toCity = _getCityById(_toCityId, cities);

    final fromLat = fromCity.latitude ?? 41.2995;
    final fromLng = fromCity.longitude ?? 69.2401;
    final toLat = toCity.latitude ?? 39.6547;
    final toLng = toCity.longitude ?? 66.9758;

    final payload = {
      'from_city_id': _fromCityId,
      'to_city_id': _toCityId,
      'departure_city_id': _fromCityId,
      'destination_city_id': _toCityId,
      'from_city': fromCity.name,
      'to_city': toCity.name,
      'departure_city': {
        'id': _fromCityId,
        'name': fromCity.name,
        'region': fromCity.region,
        'latitude': fromLat,
        'longitude': fromLng,
      },
      'destination_city': {
        'id': _toCityId,
        'name': toCity.name,
        'region': toCity.region,
        'latitude': toLat,
        'longitude': toLng,
      },
      'departure_time': _departureDateTime.toUtc().toIso8601String(),
      'estimated_arrival': _departureDateTime
          .add(const Duration(hours: 4))
          .toUtc()
          .toIso8601String(),
      'estimated_arrival_time': _departureDateTime
          .add(const Duration(hours: 4))
          .toUtc()
          .toIso8601String(),
      'price_per_seat': price,
      'total_seats': _totalSeats,
      'available_seats': _totalSeats,
      'has_ac': _hasAc,
      'allow_luggage': _allowLuggage,
      'allow_smoking': false,
      'allow_pets': false,
      'women_only': _womenOnly,
      if (profile != null) ...{
        'driver_name': profile.fullName,
        'driver_phone': profile.phone,
        'driver_rating': profile.rating,
        'driver_trips': profile.totalTrips,
        if (profile.vehicle != null) ...{
          'vehicle_model': '${profile.vehicle!.make} ${profile.vehicle!.model}',
          'vehicle_color': profile.vehicle!.color,
          'plate_number': profile.vehicle!.licensePlate,
        },
      },
      'pickup_locations': [
        {'name': pickupText, 'lat': fromLat, 'lng': fromLng}
      ],
      'dropoff_locations': [
        {'name': dropoffText, 'lat': toLat, 'lng': toLng}
      ],
      if (_commentController.text.trim().isNotEmpty)
        'comment': _commentController.text.trim(),
    };

    if (_isEditMode) {
      context.read<IntercityRidesBloc>().add(
            UpdateRideEvent(
              rideId: widget.editRide!.id,
              rideData: payload,
            ),
          );
    } else {
      context.read<IntercityRidesBloc>().add(CreateRideEvent(payload));
    }

    _saveLastTrip(_fromCityId, _toCityId, price, _totalSeats);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context);
    final currentLocale = Localizations.localeOf(context).languageCode;

    return BlocListener<IntercityRidesBloc, IntercityRidesState>(
      listener: (context, state) {
        if (state is RideCreatedSuccessState) {
          AppSnackBar.showSuccess(context, l10n.tripCreatedSuccess);
          context
              .read<IntercityRidesBloc>()
              .add(const LoadRidesEvent(status: 'active'));
          context.pop(true);
        } else if (state is RideUpdatedSuccessState) {
          AppSnackBar.showSuccess(context, 'Qatnov muvaffaqiyatli tahrirlandi!');
          context
              .read<IntercityRidesBloc>()
              .add(const LoadRidesEvent(status: 'active'));
          context.pop(true);
        } else if (state is IntercityRidesError) {
          AppSnackBar.showError(context, state.message);
        }
      },
      child: Scaffold(
        backgroundColor:
            isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
        appBar: AppBar(
          backgroundColor:
              isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
          elevation: 0,
          leading: IconButton(
            icon: Icon(
              Icons.arrow_back_ios_new_rounded,
              size: 20,
              color: isDark ? Colors.white : AppColors.charcoalBlack,
            ),
            onPressed: () => context.pop(),
          ),
          title: Text(
            _isEditMode ? 'Qatnovni tahrirlash' : l10n.createTripTitle,
            style: AppTypography.titleMedium.copyWith(
              fontWeight: FontWeight.w800,
              fontSize: 18,
              color: isDark ? Colors.white : AppColors.charcoalBlack,
            ),
          ),
          centerTitle: true,
        ),
        body: BlocBuilder<VerificationBloc, VerificationState>(
          builder: (context, vState) {
            final cities = _resolveCities(vState);
            final fromCity = _getCityById(_fromCityId, cities);
            final toCity = _getCityById(_toCityId, cities);

            final hPadding = AppResponsive.horizontalPadding(context);

            return SafeArea(
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(
                    maxWidth: AppResponsive.maxContentWidth,
                  ),
                  child: Form(
                    key: _formKey,
                    child: ListView(
                      physics: const BouncingScrollPhysics(),
                      padding: EdgeInsets.fromLTRB(
                          hPadding, AppSpacing.md, hPadding, 120),
                      children: [
                        // Quick Repeat Last Trip Banner
                        if (!_isEditMode && _lastSavedTrip != null) ...[
                          _buildRepeatLastTripBanner(isDark, cities),
                          const SizedBox(height: 14),
                        ],

                        // 1. ROUTE CARD (From / To with Swap)
                        Container(
                          decoration: BoxDecoration(
                            color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: isDark ? 0.20 : 0.04),
                                blurRadius: 10,
                                offset: const Offset(0, 3),
                              ),
                            ],
                            border: Border.all(
                              color: isDark
                                  ? AppColors.borderDark
                                  : AppColors.borderLight,
                            ),
                          ),
                      child: Stack(
                        alignment: Alignment.centerRight,
                        children: [
                          Column(
                            children: [
                              // Origin Tile
                              InkWell(
                                onTap: () => _showCitySearchSheet(
                                    isFrom: true, cities: cities),
                                borderRadius: const BorderRadius.vertical(
                                    top: Radius.circular(20)),
                                child: Padding(
                                  padding: const EdgeInsets.fromLTRB(
                                      16, 16, 64, 14),
                                  child: Row(
                                    children: [
                                      Container(
                                        width: 36,
                                        height: 36,
                                        decoration: BoxDecoration(
                                          color: AppColors.success
                                              .withValues(alpha: 0.12),
                                          shape: BoxShape.circle,
                                        ),
                                        child: const Icon(
                                          Icons.trip_origin_rounded,
                                          color: AppColors.success,
                                          size: 18,
                                        ),
                                      ),
                                      const SizedBox(width: 14),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              'Qayerdan (Jo\'nash)',
                                              style: TextStyle(
                                                fontSize: 12,
                                                fontWeight: FontWeight.w500,
                                                color: isDark
                                                    ? Colors.grey[400]
                                                    : Colors.grey[600],
                                              ),
                                            ),
                                            const SizedBox(height: 2),
                                            Text(
                                              fromCity.name,
                                              style: TextStyle(
                                                fontSize: 17,
                                                fontWeight: FontWeight.w800,
                                                color: isDark
                                                    ? Colors.white
                                                    : AppColors.charcoalBlack,
                                              ),
                                            ),
                                            if (fromCity.region.isNotEmpty)
                                              Text(
                                                fromCity.region,
                                                style: TextStyle(
                                                  fontSize: 11,
                                                  color: isDark
                                                      ? Colors.grey[500]
                                                      : Colors.grey[500],
                                                ),
                                              ),
                                          ],
                                        ),
                                      ),
                                      const Icon(
                                        Icons.chevron_right_rounded,
                                        color: Colors.grey,
                                      ),
                                    ],
                                  ),
                                ),
                              ),

                              Divider(
                                height: 1,
                                thickness: 1,
                                indent: 56,
                                endIndent: 56,
                                color: isDark
                                    ? const Color(0xFF2E2E3C)
                                    : const Color(0xFFF0F1F5),
                              ),

                              // Destination Tile
                              InkWell(
                                onTap: () => _showCitySearchSheet(
                                    isFrom: false, cities: cities),
                                borderRadius: const BorderRadius.vertical(
                                    bottom: Radius.circular(20)),
                                child: Padding(
                                  padding: const EdgeInsets.fromLTRB(
                                      16, 14, 64, 16),
                                  child: Row(
                                    children: [
                                      Container(
                                        width: 36,
                                        height: 36,
                                        decoration: BoxDecoration(
                                          color: AppColors.error
                                              .withValues(alpha: 0.12),
                                          shape: BoxShape.circle,
                                        ),
                                        child: const Icon(
                                          Icons.location_on_rounded,
                                          color: AppColors.error,
                                          size: 20,
                                        ),
                                      ),
                                      const SizedBox(width: 14),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              'Qayerga (Yetib borish)',
                                              style: TextStyle(
                                                fontSize: 12,
                                                fontWeight: FontWeight.w500,
                                                color: isDark
                                                    ? Colors.grey[400]
                                                    : Colors.grey[600],
                                              ),
                                            ),
                                            const SizedBox(height: 2),
                                            Text(
                                              toCity.name,
                                              style: TextStyle(
                                                fontSize: 17,
                                                fontWeight: FontWeight.w800,
                                                color: isDark
                                                    ? Colors.white
                                                    : AppColors.charcoalBlack,
                                              ),
                                            ),
                                            if (toCity.region.isNotEmpty)
                                              Text(
                                                toCity.region,
                                                style: TextStyle(
                                                  fontSize: 11,
                                                  color: isDark
                                                      ? Colors.grey[500]
                                                      : Colors.grey[500],
                                                ),
                                              ),
                                          ],
                                        ),
                                      ),
                                      const Icon(
                                        Icons.chevron_right_rounded,
                                        color: Colors.grey,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),

                          // Floating Swap Button
                          Positioned(
                            right: 14,
                            child: Material(
                              color: AppColors.taxiYellow,
                              shape: const CircleBorder(),
                              elevation: 2,
                              child: InkWell(
                                onTap: _swapCities,
                                customBorder: const CircleBorder(),
                                child: const Padding(
                                  padding: EdgeInsets.all(10),
                                  child: Icon(
                                    Icons.swap_vert_rounded,
                                    color: Colors.black87,
                                    size: 22,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 12),

                    // Quick Route Chips
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      physics: const BouncingScrollPhysics(),
                      child: Row(
                        children: [
                          _buildRouteChip('Toshkent ➔ Samarqand', 'tashkent', 'samarkand', isDark),
                          _buildRouteChip('Toshkent ➔ Farg\'ona', 'tashkent', 'fergana', isDark),
                          _buildRouteChip('Toshkent ➔ Andijon', 'tashkent', 'andijan', isDark),
                          _buildRouteChip('Samarqand ➔ Buxoro', 'samarkand', 'bukhara', isDark),
                          _buildRouteChip('Toshkent ➔ Buxoro', 'tashkent', 'bukhara', isDark),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),

                    // 2. DEPARTURE DATE & TIME
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: isDark
                              ? AppColors.borderDark
                              : AppColors.borderLight,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: AppColors.taxiYellow.withValues(alpha: 0.18),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: const Icon(
                                  Icons.calendar_month_rounded,
                                  color: AppColors.taxiYellowDark,
                                  size: 20,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      l10n.departureDateLabel,
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: isDark
                                            ? Colors.grey[400]
                                            : Colors.grey[600],
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      AppDateFormatter.formatDateTime(
                                          _departureDateTime,
                                          locale: currentLocale),
                                      style: TextStyle(
                                        fontWeight: FontWeight.w800,
                                        fontSize: 16,
                                        color: isDark
                                            ? Colors.white
                                            : AppColors.charcoalBlack,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              OutlinedButton(
                                onPressed: _selectDateTime,
                                style: OutlinedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 14, vertical: 8),
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10)),
                                  side: BorderSide(
                                    color: isDark
                                        ? const Color(0xFF3E3E50)
                                        : const Color(0xFFD0D3D9),
                                  ),
                                ),
                                child: const Text(
                                  'O\'zgartirish',
                                  style: TextStyle(
                                    fontSize: 12.5,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Wrap(
                            spacing: 8,
                            runSpacing: 6,
                            children: [
                              _buildQuickTimeChip('+1 soat', const Duration(hours: 1), isDark),
                              _buildQuickTimeChip('+2 soat', const Duration(hours: 2), isDark),
                              _buildQuickTimeChip('+4 soat', const Duration(hours: 4), isDark),
                              _buildQuickTimeChip('Ertaga', const Duration(days: 1), isDark),
                            ],
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),

                    // 3. PRICE & SEATS
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Price Input
                        Expanded(
                          flex: 3,
                          child: Container(
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: isDark
                                  ? AppColors.surfaceDark
                                  : AppColors.surfaceLight,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: isDark
                                    ? AppColors.borderDark
                                    : AppColors.borderLight,
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Har bir o\'rin narxi',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: isDark
                                        ? Colors.grey[400]
                                        : Colors.grey[600],
                                  ),
                                ),
                                const SizedBox(height: 6),
                                TextFormField(
                                  controller: _priceController,
                                  keyboardType: TextInputType.number,
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w800,
                                    color: isDark
                                        ? Colors.white
                                        : AppColors.charcoalBlack,
                                  ),
                                  decoration: InputDecoration(
                                    suffixText: 'so\'m',
                                    suffixStyle: TextStyle(
                                      fontWeight: FontWeight.w700,
                                      color: isDark
                                          ? Colors.grey[400]
                                          : Colors.grey[600],
                                    ),
                                    isDense: true,
                                    contentPadding: const EdgeInsets.symmetric(
                                        vertical: 8),
                                    border: InputBorder.none,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Tavsiya etilgan narxlar pastda',
                                  style: TextStyle(
                                    fontSize: 10.5,
                                    fontWeight: FontWeight.w500,
                                    color: isDark
                                        ? Colors.grey[500]
                                        : Colors.grey[500],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                        const SizedBox(width: 12),

                        // Seats Stepper
                        Expanded(
                          flex: 2,
                          child: Container(
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: isDark
                                  ? AppColors.surfaceDark
                                  : AppColors.surfaceLight,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: isDark
                                    ? AppColors.borderDark
                                    : AppColors.borderLight,
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Bo\'sh o\'rinlar',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: isDark
                                        ? Colors.grey[400]
                                        : Colors.grey[600],
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    InkWell(
                                      onTap: _totalSeats > 1
                                          ? () => setState(
                                              () => _totalSeats--)
                                          : null,
                                      borderRadius:
                                          BorderRadius.circular(8),
                                      child: Container(
                                        padding: const EdgeInsets.all(6),
                                        decoration: BoxDecoration(
                                          color: isDark
                                              ? const Color(0xFF2C2C38)
                                              : const Color(0xFFF0F1F5),
                                          borderRadius:
                                              BorderRadius.circular(8),
                                        ),
                                        child: const Icon(Icons.remove,
                                            size: 18),
                                      ),
                                    ),
                                    Text(
                                      '$_totalSeats',
                                      style: TextStyle(
                                        fontSize: 19,
                                        fontWeight: FontWeight.w800,
                                        color: isDark
                                            ? Colors.white
                                            : AppColors.charcoalBlack,
                                      ),
                                    ),
                                    InkWell(
                                      onTap: _totalSeats < 8
                                          ? () => setState(
                                              () => _totalSeats++)
                                          : null,
                                      borderRadius:
                                          BorderRadius.circular(8),
                                      child: Container(
                                        padding: const EdgeInsets.all(6),
                                        decoration: BoxDecoration(
                                          color: AppColors.taxiYellow,
                                          borderRadius:
                                              BorderRadius.circular(8),
                                        ),
                                        child: const Icon(Icons.add,
                                            size: 18,
                                            color: Colors.black87),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 12),

                    // Smart Recommended Price Engine Pills
                    _buildSmartPriceEngine(isDark, cities),

                    const SizedBox(height: 20),

                    // 4. PICKUP & DROPOFF ADDRESSES
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: isDark
                              ? AppColors.borderDark
                              : AppColors.borderLight,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Bekatlar va uchrashuv nuqtalari',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: isDark
                                  ? Colors.white
                                  : AppColors.charcoalBlack,
                            ),
                          ),
                          const SizedBox(height: 12),
                          TextFormField(
                            controller: _pickupController,
                            decoration: InputDecoration(
                              labelText: 'Chiqish nuqtasi (Jo\'nash bekati)',
                              hintText: 'Masalan, Chilonzor metro, Janubiy vokzal',
                              prefixIcon: const Icon(Icons.trip_origin_rounded,
                                  color: AppColors.success, size: 20),
                              filled: true,
                              fillColor: isDark
                                  ? const Color(0xFF262632)
                                  : const Color(0xFFF7F8FA),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide.none,
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                          TextFormField(
                            controller: _dropoffController,
                            decoration: InputDecoration(
                              labelText: 'Tushish nuqtasi (Borish bekati)',
                              hintText: 'Masalan, Samarqand vokzal, Registon',
                              prefixIcon: const Icon(Icons.location_on_rounded,
                                  color: AppColors.error, size: 20),
                              filled: true,
                              fillColor: isDark
                                  ? const Color(0xFF262632)
                                  : const Color(0xFFF7F8FA),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide.none,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),

                    // 5. AMENITIES
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: isDark
                              ? AppColors.borderDark
                              : AppColors.borderLight,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            l10n.amenitiesSectionTitle,
                            style: TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 14,
                              color: isDark
                                  ? Colors.white
                                  : AppColors.charcoalBlack,
                            ),
                          ),
                          const SizedBox(height: 4),
                          SwitchListTile.adaptive(
                            value: _hasAc,
                            activeTrackColor: AppColors.taxiYellowDark,
                            contentPadding: EdgeInsets.zero,
                            secondary: const Icon(Icons.ac_unit_rounded,
                                color: Colors.blueAccent),
                            title: Text(l10n.hasAcLabel,
                                style: const TextStyle(
                                    fontSize: 14, fontWeight: FontWeight.w600)),
                            onChanged: (v) => setState(() => _hasAc = v),
                          ),
                          SwitchListTile.adaptive(
                            value: _allowLuggage,
                            activeTrackColor: AppColors.taxiYellowDark,
                            contentPadding: EdgeInsets.zero,
                            secondary: const Icon(Icons.luggage_rounded,
                                color: Colors.orangeAccent),
                            title: Text(l10n.allowLuggageLabel,
                                style: const TextStyle(
                                    fontSize: 14, fontWeight: FontWeight.w600)),
                            onChanged: (v) => setState(() => _allowLuggage = v),
                          ),
                          SwitchListTile.adaptive(
                            value: _womenOnly,
                            activeTrackColor: AppColors.taxiYellowDark,
                            contentPadding: EdgeInsets.zero,
                            secondary: const Icon(Icons.woman_rounded,
                                color: Colors.pinkAccent),
                            title: Text(l10n.womenOnlyLabel,
                                style: const TextStyle(
                                    fontSize: 14, fontWeight: FontWeight.w600)),
                            onChanged: (v) => setState(() => _womenOnly = v),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),

                    // 6. COMMENT
                    TextFormField(
                      controller: _commentController,
                      maxLines: 2,
                      decoration: InputDecoration(
                        labelText: l10n.additionalCommentLabel,
                        hintText: 'Yo\'lovchilar uchun qo\'shimcha ma\'lumot yoki eslatma',
                        filled: true,
                        fillColor:
                            isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide(
                            color: isDark
                                ? AppColors.borderDark
                                : AppColors.borderLight,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 32),

                    // 7. SUBMIT BUTTON
                    BlocBuilder<IntercityRidesBloc, IntercityRidesState>(
                      builder: (context, state) {
                        final isBusy =
                            state is CreatingRideState || state is UpdatingRideState;
                        return SizedBox(
                          width: double.infinity,
                          child: AppButton(
                            text: _isEditMode
                                ? 'O\'zgarishlarni saqlash'
                                : l10n.publishTripAction,
                            onPressed: isBusy ? null : () => _submit(l10n),
                            isLoading: isBusy,
                            variant: AppButtonVariant.taxi,
                            height: 54,
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    ),
  ),
);
  }

  Widget _buildRepeatLastTripBanner(bool isDark, List<CityEntity> cities) {
    final from = _getCityById(_lastSavedTrip!['from'] as String, cities);
    final to = _getCityById(_lastSavedTrip!['to'] as String, cities);
    final price = _lastSavedTrip!['price'] as int;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E212A) : const Color(0xFFFFFBEB),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.taxiYellowDark.withValues(alpha: 0.4),
          width: 1.2,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.taxiYellow.withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.replay_rounded,
              color: AppColors.taxiYellowDark,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Oxirgi qatnovni takrorlash',
                  style: TextStyle(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${from.name} ➔ ${to.name} • ${AppCurrencyFormatter.format(price)}',
                  style: TextStyle(
                    fontSize: 12,
                    color: isDark ? Colors.white70 : AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          ElevatedButton(
            onPressed: _applyLastTrip,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.taxiYellow,
              foregroundColor: Colors.black,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              minimumSize: Size.zero,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              elevation: 0,
            ),
            child: const Text(
              'Qo\'llash',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRouteChip(
      String title, String fromId, String toId, bool isDark) {
    final isSelected = _fromCityId == fromId && _toCityId == toId;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: FilterChip(
        label: Text(
          title,
          style: TextStyle(
            fontSize: 12,
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
            color: isSelected
                ? Colors.black87
                : (isDark ? Colors.grey[300] : AppColors.charcoalBlack),
          ),
        ),
        selected: isSelected,
        selectedColor: AppColors.taxiYellow,
        backgroundColor:
            isDark ? AppColors.surfaceDark : AppColors.surfaceSubtleLight,
        checkmarkColor: Colors.black87,
        onSelected: (_) {
          setState(() {
            _fromCityId = fromId;
            _toCityId = toId;
            _applySmartRecommendationIfDefault();
          });
        },
      ),
    );
  }

  Widget _buildQuickTimeChip(String label, Duration offset, bool isDark) {
    return InkWell(
      onTap: () => _setQuickTime(offset),
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF2A2A38) : const Color(0xFFF2F4F7),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: isDark ? Colors.grey[300] : AppColors.charcoalBlack,
          ),
        ),
      ),
    );
  }

  Widget _buildSmartPriceEngine(bool isDark, List<CityEntity> cities) {
    final rec = _calculateRoutePricing(_fromCityId, _toCityId, cities);
    final cleanPriceText = _priceController.text.replaceAll(RegExp(r'\D'), '');
    final currentPrice = int.tryParse(cleanPriceText) ?? 0;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E212B) : const Color(0xFFF9FAFC),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? const Color(0xFF2E3240) : const Color(0xFFE5E7EB),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: AppColors.taxiYellow.withValues(alpha: 0.16),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.auto_awesome_rounded,
                  color: AppColors.taxiYellowDark,
                  size: 16,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  '${rec.routeName} (${rec.distanceKm} km) bozor narxlari:',
                  style: TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w700,
                    color: isDark ? Colors.grey[300] : AppColors.charcoalBlack,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: _buildPriceTierCard(
                  title: 'Tejamkor',
                  subtitle: 'Tez to\'ladi',
                  price: rec.economyPrice,
                  isSelected: currentPrice == rec.economyPrice,
                  isRecommended: false,
                  isDark: isDark,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildPriceTierCard(
                  title: 'Bozor narxi',
                  subtitle: 'Optimal',
                  price: rec.recommendedPrice,
                  isSelected: currentPrice == rec.recommendedPrice,
                  isRecommended: true,
                  isDark: isDark,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildPriceTierCard(
                  title: 'Komfort',
                  subtitle: 'Qulaylik',
                  price: rec.comfortPrice,
                  isSelected: currentPrice == rec.comfortPrice,
                  isRecommended: false,
                  isDark: isDark,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPriceTierCard({
    required String title,
    required String subtitle,
    required int price,
    required bool isSelected,
    required bool isRecommended,
    required bool isDark,
  }) {
    final activeBg = isDark ? const Color(0xFF282B38) : Colors.white;

    return InkWell(
      onTap: () {
        HapticFeedback.lightImpact();
        setState(() {
          _priceController.text = price.toString();
        });
      },
      borderRadius: BorderRadius.circular(12),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? (isDark ? const Color(0xFF332B14) : const Color(0xFFFFFBEB))
              : activeBg,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? AppColors.taxiYellowDark
                : (isRecommended
                    ? AppColors.taxiYellow.withValues(alpha: 0.5)
                    : (isDark ? const Color(0xFF333748) : const Color(0xFFE2E4E9))),
            width: isSelected ? 1.8 : 1.0,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppColors.taxiYellow.withValues(alpha: 0.18),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  )
                ]
              : null,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            if (isRecommended)
              Container(
                margin: const EdgeInsets.only(bottom: 3),
                padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1.5),
                decoration: BoxDecoration(
                  color: AppColors.taxiYellow,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Text(
                  '⭐ TAVSIYA',
                  style: TextStyle(
                    fontSize: 8.5,
                    fontWeight: FontWeight.w900,
                    color: Colors.black87,
                  ),
                ),
              )
            else
              Padding(
                padding: const EdgeInsets.only(bottom: 3),
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 10.5,
                    fontWeight: FontWeight.w600,
                    color: isDark ? Colors.grey[400] : Colors.grey[600],
                  ),
                ),
              ),
            Text(
              AppCurrencyFormatter.format(price),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 12.5,
                fontWeight: FontWeight.w800,
                color: isSelected
                    ? (isDark ? AppColors.taxiYellow : AppColors.charcoalBlack)
                    : (isDark ? Colors.white : AppColors.charcoalBlack),
              ),
            ),
            const SizedBox(height: 2),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 9.5,
                color: isDark ? Colors.grey[500] : Colors.grey[500],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CitySelectionModal extends StatefulWidget {
  const _CitySelectionModal({
    required this.title,
    required this.cities,
    required this.selectedCityId,
    required this.onCitySelected,
  });

  final String title;
  final List<CityEntity> cities;
  final String selectedCityId;
  final ValueChanged<CityEntity> onCitySelected;

  @override
  State<_CitySelectionModal> createState() => _CitySelectionModalState();
}

class _CitySelectionModalState extends State<_CitySelectionModal> {
  final _searchController = TextEditingController();
  String _filter = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final filteredCities = widget.cities.where((c) {
      final query = _filter.toLowerCase().trim();
      if (query.isEmpty) return true;
      return c.name.toLowerCase().contains(query) ||
          c.region.toLowerCase().contains(query);
    }).toList();

    return Container(
      height: MediaQuery.of(context).size.height * 0.75,
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF191921) : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          const SizedBox(height: 12),
          // Drag handle
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: isDark ? Colors.grey[700] : Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    widget.title,
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w800,
                      color: isDark ? Colors.white : AppColors.charcoalBlack,
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close_rounded),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: TextField(
              controller: _searchController,
              onChanged: (val) => setState(() => _filter = val),
              decoration: InputDecoration(
                hintText: 'Shaharni qidirish...',
                prefixIcon: const Icon(Icons.search_rounded, size: 20),
                suffixIcon: _filter.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear_rounded, size: 18),
                        onPressed: () {
                          _searchController.clear();
                          setState(() => _filter = '');
                        },
                      )
                    : null,
                filled: true,
                fillColor:
                    isDark ? const Color(0xFF23232E) : const Color(0xFFF2F4F7),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 10),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: ListView.separated(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              itemCount: filteredCities.length,
              separatorBuilder: (_, __) => Divider(
                height: 1,
                color: isDark
                    ? const Color(0xFF262634)
                    : const Color(0xFFF0F1F5),
              ),
              itemBuilder: (ctx, idx) {
                final city = filteredCities[idx];
                final isSelected = city.id == widget.selectedCityId;

                return ListTile(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppColors.taxiYellow.withValues(alpha: 0.2)
                          : (isDark
                              ? const Color(0xFF262634)
                              : const Color(0xFFF5F6F9)),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.location_city_rounded,
                      size: 20,
                      color: isSelected
                          ? AppColors.taxiYellowDark
                          : (isDark ? Colors.grey[400] : Colors.grey[600]),
                    ),
                  ),
                  title: Text(
                    city.name,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight:
                          isSelected ? FontWeight.w800 : FontWeight.w600,
                      color: isDark ? Colors.white : AppColors.charcoalBlack,
                    ),
                  ),
                  subtitle: city.region.isNotEmpty
                      ? Text(
                          city.region,
                          style: TextStyle(
                            fontSize: 12,
                            color: isDark ? Colors.grey[400] : Colors.grey[600],
                          ),
                        )
                      : null,
                  trailing: isSelected
                      ? const Icon(Icons.check_circle_rounded,
                          color: AppColors.taxiYellowDark)
                      : null,
                  onTap: () => widget.onCitySelected(city),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
