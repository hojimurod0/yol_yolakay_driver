import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../../core/providers/core_providers.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../home/domain/entities/city_entity.dart';
import '../../../home/domain/entities/location_point_entity.dart';
import '../../../home/presentation/pages/city_picker_page.dart';
import '../../../rides/domain/entities/driver_entity.dart';
import '../../../rides/domain/entities/ride_entity.dart';
import '../providers/driver_provider.dart';

class CreateDriverTripPage extends ConsumerStatefulWidget {
  const CreateDriverTripPage({super.key});

  @override
  ConsumerState<CreateDriverTripPage> createState() =>
      _CreateDriverTripPageState();
}

class _CreateDriverTripPageState extends ConsumerState<CreateDriverTripPage> {
  CityEntity _departureCity = const CityEntity(
    id: 'tashkent',
    nameUz: 'Toshkent',
    nameRu: 'Ташкент',
    nameEn: 'Tashkent',
    region: 'Toshkent shahri',
    latitude: 41.2995,
    longitude: 69.2401,
    isPopular: true,
  );

  CityEntity _destinationCity = const CityEntity(
    id: 'samarkand',
    nameUz: 'Samarqand',
    nameRu: 'Самарканд',
    nameEn: 'Samarkand',
    region: 'Samarqand viloyati',
    latitude: 39.6270,
    longitude: 66.9750,
    isPopular: true,
  );

  DateTime _departureDateTime = DateTime.now().add(const Duration(hours: 2));
  int _availableSeats = 3;
  int _pricePerSeat = 90000;
  bool _isParcelAllowed = true;
  final int _parcelPrice = 40000;
  bool _isPickupFromDoor = true;

  final TextEditingController _pickupPointController =
      TextEditingController(text: 'Olmazor metro / Janubiy vokzal');
  final TextEditingController _dropoffPointController =
      TextEditingController(text: 'Samarqand vokzali / Registon');
  final TextEditingController _notesController = TextEditingController(
      text: 'Konditsioner bor, yukxona bo\'sh, qulay safar.');

  @override
  void dispose() {
    _pickupPointController.dispose();
    _dropoffPointController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _pickDepartureCity() async {
    final result = await context.push<CityEntity>(
      '/city-picker',
      extra: {
        'title': 'Qayerdan yo\'lga chiqasiz?',
        'excludedId': _destinationCity.id,
        'initialMode': CityPickerViewMode.list,
      },
    );
    if (result != null) {
      setState(() => _departureCity = result);
    }
  }

  Future<void> _pickDestinationCity() async {
    final result = await context.push<CityEntity>(
      '/city-picker',
      extra: {
        'title': 'Qaysi shaharga borasiz?',
        'excludedId': _departureCity.id,
        'initialMode': CityPickerViewMode.list,
      },
    );
    if (result != null) {
      setState(() => _destinationCity = result);
    }
  }

  void _swapCities() {
    HapticFeedback.selectionClick();
    setState(() {
      final temp = _departureCity;
      _departureCity = _destinationCity;
      _destinationCity = temp;
    });
  }

  Future<void> _selectDateTime() async {
    final today = DateUtils.dateOnly(DateTime.now());
    DateTime initialDate = DateUtils.dateOnly(_departureDateTime);
    if (initialDate.isBefore(today)) {
      initialDate = today;
    }
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: today,
      lastDate: today.add(const Duration(days: 30)),
    );
    if (pickedDate == null || !mounted) return;

    final pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_departureDateTime),
    );
    if (pickedTime == null || !mounted) return;

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

  void _publishRide() async {
    HapticFeedback.mediumImpact();
    final driverState = ref.read(driverNotifierProvider);
    final profile = driverState.profile;

    if (profile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Haydovchi profili topilmadi')),
      );
      return;
    }

    final newRide = RideEntity(
      id: 'ride_${DateTime.now().millisecondsSinceEpoch}',
      departureCity: _departureCity,
      destinationCity: _destinationCity,
      departureTime: _departureDateTime,
      estimatedArrivalTime: _departureDateTime.add(const Duration(hours: 4)),
      driver: DriverEntity(
        id: profile.id,
        name: profile.fullName,
        phoneNumber: profile.phoneNumber,
        telegramHandle: profile.telegramHandle,
        rating: profile.rating,
        completedTrips: profile.completedTripsCount,
        isVerified: true,
      ),
      vehicle: profile.vehicle,
      pricePerSeat: _pricePerSeat,
      totalSeats: 4,
      availableSeats: _availableSeats,
      isParcelAllowed: _isParcelAllowed,
      customParcelPrice: _parcelPrice,
      pickupPoints: [
        LocationPointEntity(
          id: 'p_custom',
          title: _pickupPointController.text.trim().isNotEmpty
              ? _pickupPointController.text.trim()
              : _departureCity.nameUz,
          description: _departureCity.nameUz,
          latitude: _departureCity.latitude,
          longitude: _departureCity.longitude,
        ),
      ],
      dropoffPoints: [
        LocationPointEntity(
          id: 'd_custom',
          title: _dropoffPointController.text.trim().isNotEmpty
              ? _dropoffPointController.text.trim()
              : _destinationCity.nameUz,
          description: _destinationCity.nameUz,
          latitude: _destinationCity.latitude,
          longitude: _destinationCity.longitude,
        ),
      ],
    );

    final success =
        await ref.read(driverNotifierProvider.notifier).publishRide(newRide);

    if (mounted && success) {
      _showSuccessDialog();
    }
  }

  void _showSuccessDialog() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final locale = ref.read(localeNotifierProvider);
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) {
        return AlertDialog(
          backgroundColor:
              isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.taxiYellow,
                ),
                child: const Icon(Icons.check_rounded,
                    color: AppColors.charcoalBlack, size: 34),
              ),
              const SizedBox(height: 16),
              Text(
                'Safar e\'lon qilindi!',
                style: AppTypography.titleLarge.copyWith(
                  fontWeight: FontWeight.w700,
                  fontSize: 18,
                  color: isDark ? Colors.white : AppColors.charcoalBlack,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                '${_departureCity.localizedName(locale.languageCode)} ➔ ${_destinationCity.localizedName(locale.languageCode)}\n${DateFormat('dd MMM, HH:mm').format(_departureDateTime)} • $_availableSeats ta o\'rin',
                style: TextStyle(
                    fontSize: 13,
                    color: isDark ? Colors.white60 : AppColors.textSecondary,
                    height: 1.35),
                textAlign: TextAlign.center,
              ),
              AppButton(
                text: 'Buyurtmalarni ko‘rish',
                variant: AppButtonVariant.taxi,
                onPressed: () {
                  Navigator.pop(ctx);
                  context.go('/driver/home');
                },
              ),
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                child: TextButton(
                  onPressed: () {
                    Navigator.pop(ctx);
                    context.go('/driver/trips');
                  },
                  child: Text(
                    'Qatnovlarimga o‘tish',
                    style: TextStyle(
                      color: isDark ? Colors.white70 : AppColors.textSecondary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final locale = ref.watch(localeNotifierProvider);
    final isRu = locale.languageCode == 'ru';
    final currencyFormat = NumberFormat('#,###', 'uz_UZ');

    return Scaffold(
      backgroundColor:
          isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
      appBar: AppBar(
        title: Text(
          isRu ? 'Создать поездку' : 'Yangi safar joylash',
          style: AppTypography.titleMedium.copyWith(
            fontWeight: FontWeight.w700,
            fontSize: 17,
            color: isDark ? Colors.white : AppColors.charcoalBlack,
          ),
        ),
        backgroundColor:
            isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(
              color: isDark ? AppColors.cardBorderDark : AppColors.cardBorder,
              height: 1),
        ),
      ),
      body: SafeArea(
        child: ListView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(
              AppSpacing.md, AppSpacing.md, AppSpacing.md, 90),
          children: [
            // 1. Route Selector Box (From / To with Swap)
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color:
                      isDark ? AppColors.cardBorderDark : AppColors.cardBorder,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.03),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                children: [
                  // From City
                  InkWell(
                    onTap: _pickDepartureCity,
                    borderRadius: BorderRadius.circular(10),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          vertical: 6, horizontal: 4),
                      child: Row(
                        children: [
                          Container(
                            width: 32,
                            height: 32,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: AppColors.success.withValues(alpha: 0.15),
                            ),
                            child: const Icon(Icons.trip_origin_rounded,
                                color: AppColors.success, size: 18),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  isRu ? 'Откуда' : 'Qayerdan (Jo\'nash)',
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w500,
                                    color: isDark
                                        ? Colors.white54
                                        : AppColors.textSecondary,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  _departureCity
                                      .localizedName(locale.languageCode),
                                  style: TextStyle(
                                    fontSize: 15.5,
                                    fontWeight: FontWeight.w700,
                                    color: isDark
                                        ? Colors.white
                                        : AppColors.charcoalBlack,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const Icon(Icons.arrow_forward_ios_rounded,
                              size: 13, color: AppColors.gray400),
                        ],
                      ),
                    ),
                  ),

                  // Divider with Swap button
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      Divider(
                          height: 20,
                          color: isDark
                              ? AppColors.cardBorderDark
                              : AppColors.cardBorder),
                      InkWell(
                        onTap: _swapCities,
                        borderRadius: BorderRadius.circular(20),
                        child: Container(
                          padding: const EdgeInsets.all(5),
                          decoration: BoxDecoration(
                            color:
                                isDark ? AppColors.gray800 : AppColors.gray100,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: isDark
                                  ? AppColors.cardBorderDark
                                  : AppColors.cardBorder,
                            ),
                          ),
                          child: Icon(Icons.swap_vert_rounded,
                              size: 18,
                              color: isDark
                                  ? Colors.white70
                                  : AppColors.charcoalBlack),
                        ),
                      ),
                    ],
                  ),

                  // To City
                  InkWell(
                    onTap: _pickDestinationCity,
                    borderRadius: BorderRadius.circular(10),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          vertical: 6, horizontal: 4),
                      child: Row(
                        children: [
                          Container(
                            width: 32,
                            height: 32,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color:
                                  AppColors.taxiYellow.withValues(alpha: 0.2),
                            ),
                            child: const Icon(Icons.location_on_rounded,
                                color: AppColors.taxiYellowDark, size: 18),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  isRu ? 'Куда' : 'Qayerga (Yetib borish)',
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w500,
                                    color: isDark
                                        ? Colors.white54
                                        : AppColors.textSecondary,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  _destinationCity
                                      .localizedName(locale.languageCode),
                                  style: TextStyle(
                                    fontSize: 15.5,
                                    fontWeight: FontWeight.w700,
                                    color: isDark
                                        ? Colors.white
                                        : AppColors.charcoalBlack,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const Icon(Icons.arrow_forward_ios_rounded,
                              size: 13, color: AppColors.gray400),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 14),

            // 2. Date & Time Selection Card
            InkWell(
              onTap: _selectDateTime,
              borderRadius: BorderRadius.circular(16),
              child: Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color:
                      isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                      color: isDark
                          ? AppColors.cardBorderDark
                          : AppColors.cardBorder),
                  boxShadow: [
                    BoxShadow(
                      color:
                          Colors.black.withValues(alpha: isDark ? 0.2 : 0.03),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: isDark ? AppColors.gray800 : AppColors.gray100,
                      ),
                      child: Icon(Icons.access_time_filled_rounded,
                          color:
                              isDark ? Colors.white70 : AppColors.charcoalBlack,
                          size: 20),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            isRu ? 'Дата и время выезда' : 'Jo\'nash vaqti',
                            style: TextStyle(
                              fontSize: 11,
                              color: isDark
                                  ? Colors.white54
                                  : AppColors.textSecondary,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            DateFormat(
                                    'EEEE, dd MMMM • HH:mm', isRu ? 'ru' : 'uz')
                                .format(_departureDateTime),
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: isDark
                                  ? Colors.white
                                  : AppColors.charcoalBlack,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Icon(Icons.edit_calendar_rounded,
                        color: AppColors.taxiYellowDark, size: 18),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 14),

            // 3. Seats & Pricing
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                    color: isDark
                        ? AppColors.cardBorderDark
                        : AppColors.cardBorder),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.03),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Seats Count Stepper
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            isRu ? 'Количество мест' : 'Bo\'sh o\'rinlar soni',
                            style: const TextStyle(
                                fontWeight: FontWeight.w700, fontSize: 13.5),
                          ),
                          Text(
                            isRu
                                ? 'Сколько пассажиров возьмете'
                                : 'Mashinada qancha joy bor',
                            style: TextStyle(
                                fontSize: 11,
                                color: isDark
                                    ? Colors.white54
                                    : AppColors.textSecondary),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          IconButton.filledTonal(
                            onPressed: _availableSeats > 1
                                ? () => setState(() => _availableSeats--)
                                : null,
                            icon: const Icon(Icons.remove_rounded, size: 16),
                            style: IconButton.styleFrom(
                              backgroundColor: isDark
                                  ? AppColors.gray800
                                  : AppColors.gray100,
                              minimumSize: const Size(34, 34),
                              padding: EdgeInsets.zero,
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 10),
                            child: Text(
                              '$_availableSeats',
                              style: const TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.w800),
                            ),
                          ),
                          IconButton.filledTonal(
                            onPressed: _availableSeats < 4
                                ? () => setState(() => _availableSeats++)
                                : null,
                            icon: const Icon(Icons.add_rounded, size: 16),
                            style: IconButton.styleFrom(
                              backgroundColor: AppColors.taxiYellow,
                              foregroundColor: AppColors.charcoalBlack,
                              minimumSize: const Size(34, 34),
                              padding: EdgeInsets.zero,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),

                  Divider(
                      height: 20,
                      color: isDark
                          ? AppColors.cardBorderDark
                          : AppColors.cardBorder),

                  // Price per seat
                  Text(
                    isRu ? 'Цена за 1 место' : '1 o\'rindiq narxi',
                    style: const TextStyle(
                        fontWeight: FontWeight.w700, fontSize: 13.5),
                  ),
                  const SizedBox(height: 6),

                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 10),
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.gray800 : AppColors.gray100,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                          color: isDark
                              ? AppColors.cardBorderDark
                              : AppColors.cardBorder),
                    ),
                    child: Text(
                      '${currencyFormat.format(_pricePerSeat)} UZS',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: isDark
                            ? AppColors.taxiYellow
                            : AppColors.charcoalBlack,
                      ),
                    ),
                  ),

                  const SizedBox(height: 8),

                  // Quick price chips
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: [60000, 80000, 90000, 100000, 120000, 150000]
                        .map((price) {
                      final isSelected = _pricePerSeat == price;
                      return ActionChip(
                        label: Text('${currencyFormat.format(price)} so\'m'),
                        backgroundColor: isSelected
                            ? AppColors.taxiYellow
                            : (isDark ? AppColors.gray800 : AppColors.gray100),
                        labelStyle: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: isSelected
                              ? AppColors.charcoalBlack
                              : (isDark
                                  ? Colors.white70
                                  : AppColors.charcoalBlack),
                        ),
                        side: BorderSide(
                          color: isSelected
                              ? AppColors.taxiYellowDark
                              : (isDark
                                  ? AppColors.cardBorderDark
                                  : AppColors.cardBorder),
                        ),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 4, vertical: 2),
                        onPressed: () => setState(() => _pricePerSeat = price),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 14),

            // 4. Parcel & Doorstep Options
            Container(
              decoration: BoxDecoration(
                color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                    color: isDark
                        ? AppColors.cardBorderDark
                        : AppColors.cardBorder),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.03),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                children: [
                  SwitchListTile(
                    title: Text(
                      isRu
                          ? 'Беру посылки и почту'
                          : 'Pochta va posilka olaman',
                      style: const TextStyle(
                          fontWeight: FontWeight.w700, fontSize: 13.5),
                    ),
                    subtitle: Text(
                      isRu
                          ? 'Стоимость: ${currencyFormat.format(_parcelPrice)} UZS'
                          : 'Narxi: ${currencyFormat.format(_parcelPrice)} so\'m',
                      style: TextStyle(
                          fontSize: 11,
                          color: isDark
                              ? Colors.white54
                              : AppColors.textSecondary),
                    ),
                    value: _isParcelAllowed,
                    activeThumbColor: AppColors.charcoalBlack,
                    activeTrackColor: AppColors.taxiYellow,
                    onChanged: (val) => setState(() => _isParcelAllowed = val),
                  ),
                  Divider(
                      height: 1,
                      color: isDark
                          ? AppColors.cardBorderDark
                          : AppColors.cardBorder),
                  SwitchListTile(
                    title: Text(
                      isRu
                          ? 'Заберу от дома / адреса'
                          : 'Manzildan olib ketaman',
                      style: const TextStyle(
                          fontWeight: FontWeight.w700, fontSize: 13.5),
                    ),
                    subtitle: Text(
                      isRu
                          ? 'По согласованию'
                          : 'Yo\'lovchi bilan kelishilgan holda',
                      style: TextStyle(
                          fontSize: 11,
                          color: isDark
                              ? Colors.white54
                              : AppColors.textSecondary),
                    ),
                    value: _isPickupFromDoor,
                    activeThumbColor: AppColors.charcoalBlack,
                    activeTrackColor: AppColors.taxiYellow,
                    onChanged: (val) => setState(() => _isPickupFromDoor = val),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 22),

            // Publish Button
            AppButton(
              text: isRu ? 'Опубликовать поездку' : 'Safarni e\'lon qilish',
              onPressed: _publishRide,
            ),
          ],
        ),
      ),
    );
  }
}
