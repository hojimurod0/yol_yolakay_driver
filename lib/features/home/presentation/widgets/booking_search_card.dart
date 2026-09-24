import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:go_router/go_router.dart';
import 'package:yol_yolakay_driver/core/localization/app_localizations_helper.dart';
import 'package:yol_yolakay_driver/core/providers/core_providers.dart';
import 'package:yol_yolakay_driver/core/theme/app_colors.dart';
import 'package:yol_yolakay_driver/core/theme/app_radius.dart';
import 'package:yol_yolakay_driver/core/theme/app_shadows.dart';
import 'package:yol_yolakay_driver/core/theme/app_spacing.dart';
import 'package:yol_yolakay_driver/core/theme/app_typography.dart';
import 'package:yol_yolakay_driver/core/utils/date_time_formatter.dart';
import 'package:yol_yolakay_driver/core/widgets/glass_container.dart';
import 'package:yol_yolakay_driver/features/home/domain/entities/city_entity.dart';
import 'package:yol_yolakay_driver/features/home/presentation/providers/city_picker_provider.dart';
import 'package:yol_yolakay_driver/features/rides/presentation/providers/ride_search_provider.dart';

enum RideBookingMode { passenger, parcel }

/// Highly interactive, transparent, animated booking search card for the Home Screen.
class BookingSearchCard extends ConsumerStatefulWidget {
  const BookingSearchCard({super.key});

  @override
  ConsumerState<BookingSearchCard> createState() => _BookingSearchCardState();
}

class _BookingSearchCardState extends ConsumerState<BookingSearchCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _swapAnimationController;
  RideBookingMode _bookingMode = RideBookingMode.passenger;

  Future<void> _autoDetectCurrentLocation() async {
    try {
      final currentFrom = ref.read(rideSearchNotifierProvider).departureCity;
      if (currentFrom != null) return;

      LocationPermission permission =
          await Geolocator.checkPermission().timeout(
        const Duration(seconds: 2),
        onTimeout: () => LocationPermission.denied,
      );
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission().timeout(
          const Duration(seconds: 3),
          onTimeout: () => LocationPermission.denied,
        );
      }
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        return;
      }

      Position? position = await Geolocator.getLastKnownPosition().timeout(
        const Duration(seconds: 1),
        onTimeout: () => null,
      );
      try {
        position ??= await Geolocator.getCurrentPosition(
          locationSettings: const LocationSettings(
            accuracy: LocationAccuracy.medium,
            timeLimit: Duration(seconds: 3),
          ),
        );
      } catch (_) {
        position ??= await Geolocator.getLastKnownPosition().timeout(
          const Duration(seconds: 1),
          onTimeout: () => null,
        );
      }

      if (position == null) return;

      final cityState = ref.read(cityPickerNotifierProvider);
      final allCities = cityState.allCities;

      if (allCities.isNotEmpty) {
        CityEntity closest = allCities.first;
        double minDistance = double.infinity;

        for (final city in allCities) {
          final distance = Geolocator.distanceBetween(
            position.latitude,
            position.longitude,
            city.latitude,
            city.longitude,
          );
          if (distance < minDistance) {
            minDistance = distance;
            closest = city;
          }
        }

        if (mounted &&
            ref.read(rideSearchNotifierProvider).departureCity == null) {
          ref
              .read(rideSearchNotifierProvider.notifier)
              .setDepartureCity(closest);
        }
      }
    } catch (_) {
      // Graceful silent fallback
    }
  }

  @override
  void initState() {
    super.initState();
    _swapAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    // Auto-detect current GPS location automatically on launch
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _autoDetectCurrentLocation();
    });
  }

  @override
  void dispose() {
    _swapAnimationController.dispose();
    super.dispose();
  }

  void _handleSwap() {
    HapticFeedback.lightImpact();
    if (_swapAnimationController.isCompleted) {
      _swapAnimationController.reverse();
    } else {
      _swapAnimationController.forward();
    }
    ref.read(rideSearchNotifierProvider.notifier).swapCities();
  }

  Future<void> _selectDepartureCity(BuildContext context) async {
    HapticFeedback.selectionClick();
    final l10n = context.l10n;
    final searchState = ref.read(rideSearchNotifierProvider);
    final result = await context.push<CityEntity>(
      '/city-picker',
      extra: {
        'title': l10n.selectDepartureCity,
        'excludedId': searchState.destinationCity?.id,
      },
    );
    if (result != null) {
      ref.read(rideSearchNotifierProvider.notifier).setDepartureCity(result);
      final dest = ref.read(rideSearchNotifierProvider).destinationCity;
      if (dest != null) {
        ref.read(rideSearchNotifierProvider.notifier).searchRides();
      }
    }
  }

  Future<void> _selectDestinationCity(BuildContext context) async {
    HapticFeedback.selectionClick();
    final l10n = context.l10n;
    final searchState = ref.read(rideSearchNotifierProvider);
    final result = await context.push<CityEntity>(
      '/city-picker',
      extra: {
        'title': l10n.selectDestinationCity,
        'excludedId': searchState.departureCity?.id,
      },
    );
    if (result != null) {
      ref.read(rideSearchNotifierProvider.notifier).setDestinationCity(result);
      final dep = ref.read(rideSearchNotifierProvider).departureCity;
      if (dep != null) {
        ref.read(rideSearchNotifierProvider.notifier).searchRides();
      }
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    HapticFeedback.selectionClick();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final searchState = ref.read(rideSearchNotifierProvider);
    final today = DateUtils.dateOnly(DateTime.now());
    DateTime initialDate = searchState.travelDate != null
        ? DateUtils.dateOnly(searchState.travelDate!)
        : today;
    if (initialDate.isBefore(today)) {
      initialDate = today;
    }

    final picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: today,
      lastDate: today.add(const Duration(days: 30)),
      builder: (context, child) {
        if (child == null) return const SizedBox.shrink();
        return Theme(
          data: isDark
              ? ThemeData.dark().copyWith(
                  colorScheme: const ColorScheme.dark(
                    primary: AppColors.taxiYellow,
                    onPrimary: AppColors.charcoalBlack,
                    surface: AppColors.surfaceDark,
                    onSurface: Colors.white,
                  ),
                )
              : ThemeData.light().copyWith(
                  colorScheme: const ColorScheme.light(
                    primary: AppColors.charcoalBlack,
                    onPrimary: Colors.white,
                    surface: Colors.white,
                    onSurface: AppColors.charcoalBlack,
                  ),
                ),
          child: child,
        );
      },
    );

    if (picked != null) {
      ref.read(rideSearchNotifierProvider.notifier).setTravelDate(picked);
    }
  }

  void _showPassengerModal(BuildContext context) {
    HapticFeedback.selectionClick();
    final currentCount = ref.read(rideSearchNotifierProvider).passengerCount;
    final l10n = context.l10n;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        int selected = currentCount;
        return StatefulBuilder(
          builder: (context, setModalState) {
            return GlassContainer(
              margin: const EdgeInsets.all(AppSpacing.md),
              borderRadius: AppRadius.borderXl,
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: SafeArea(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 36,
                      height: 4,
                      decoration: BoxDecoration(
                        color: isDark ? Colors.white24 : Colors.black12,
                        borderRadius: AppRadius.borderPill,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    Text(
                      _bookingMode == RideBookingMode.passenger
                          ? l10n.passengerCount
                          : (isDark ? 'Посылки (Места)' : 'Posilka hajmi'),
                      style: AppTypography.titleMedium.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: isDark
                            ? AppColors.surfaceSubtleDark
                            : AppColors.surfaceSubtleLight,
                        borderRadius: AppRadius.borderLg,
                        border: Border.all(
                          color: isDark
                              ? AppColors.borderDark
                              : AppColors.borderLight,
                        ),
                      ),
                      child: Row(
                        children: [1, 2, 3, 4].map((count) {
                          final isSelected = count == selected;
                          return Expanded(
                            child: InkWell(
                              onTap: () {
                                HapticFeedback.lightImpact();
                                setModalState(() => selected = count);
                                ref
                                    .read(rideSearchNotifierProvider.notifier)
                                    .setPassengerCount(count);
                                Navigator.pop(context);
                              },
                              borderRadius: AppRadius.borderMd,
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 180),
                                curve: Curves.easeOutCubic,
                                height: 44,
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? AppColors.taxiYellow
                                      : Colors.transparent,
                                  borderRadius: AppRadius.borderMd,
                                  boxShadow: isSelected
                                      ? [
                                          BoxShadow(
                                            color: AppColors.taxiYellow
                                                .withValues(alpha: 0.35),
                                            blurRadius: 8,
                                            offset: const Offset(0, 2),
                                          ),
                                        ]
                                      : null,
                                ),
                                alignment: Alignment.center,
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      _bookingMode == RideBookingMode.passenger
                                          ? Icons.person_rounded
                                          : Icons.inventory_2_rounded,
                                      size: 16,
                                      color: isSelected
                                          ? AppColors.charcoalBlack
                                          : (isDark
                                              ? AppColors.textSecondaryDark
                                              : AppColors.textSecondaryLight),
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      '$count',
                                      style: AppTypography.titleMedium.copyWith(
                                        color: isSelected
                                            ? AppColors.charcoalBlack
                                            : (isDark
                                                ? AppColors.textPrimaryDark
                                                : AppColors.textPrimaryLight),
                                        fontWeight: FontWeight.w800,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.md),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final l10n = context.l10n;
    final locale = ref.watch(localeNotifierProvider);
    final localeCode = locale.languageCode;
    final isRu = localeCode == 'ru';
    final searchState = ref.watch(rideSearchNotifierProvider);

    final fromCity = searchState.departureCity;
    final toCity = searchState.destinationCity;
    final travelDate = searchState.travelDate ?? DateTime.now();
    final passengerCount = searchState.passengerCount;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
        borderRadius: AppRadius.borderXl,
        border: Border.all(
          color: isDark ? AppColors.borderDark : AppColors.borderLight,
        ),
        boxShadow: isDark ? AppShadows.darkSm : AppShadows.sm,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // 1. Mode Switcher: Yo'lovchi vs Pochta / Posilka
          Container(
            padding: const EdgeInsets.all(3),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1E212B) : const Color(0xFFE5E7EB),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Expanded(
                  child: InkWell(
                    onTap: () {
                      HapticFeedback.selectionClick();
                      setState(() => _bookingMode = RideBookingMode.passenger);
                    },
                    borderRadius: BorderRadius.circular(10),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      decoration: BoxDecoration(
                        color: _bookingMode == RideBookingMode.passenger
                            ? (isDark ? const Color(0xFF2A2E3D) : Colors.white)
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(10),
                        boxShadow: _bookingMode == RideBookingMode.passenger
                            ? [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.08),
                                  blurRadius: 4,
                                  offset: const Offset(0, 2),
                                ),
                              ]
                            : null,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.person_rounded,
                            size: 16,
                            color: _bookingMode == RideBookingMode.passenger
                                ? (isDark ? Colors.white : Colors.black87)
                                : (isDark ? Colors.white54 : Colors.black45),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            isRu ? 'Пассажир' : 'Yo\'lovchi',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight:
                                  _bookingMode == RideBookingMode.passenger
                                      ? FontWeight.w800
                                      : FontWeight.w600,
                              color: _bookingMode == RideBookingMode.passenger
                                  ? (isDark ? Colors.white : Colors.black87)
                                  : (isDark ? Colors.white60 : Colors.black54),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: InkWell(
                    onTap: () {
                      HapticFeedback.selectionClick();
                      setState(() => _bookingMode = RideBookingMode.parcel);
                    },
                    borderRadius: BorderRadius.circular(10),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      decoration: BoxDecoration(
                        color: _bookingMode == RideBookingMode.parcel
                            ? (isDark ? const Color(0xFF2A2E3D) : Colors.white)
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(10),
                        boxShadow: _bookingMode == RideBookingMode.parcel
                            ? [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.08),
                                  blurRadius: 4,
                                  offset: const Offset(0, 2),
                                ),
                              ]
                            : null,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.inventory_2_rounded,
                            size: 16,
                            color: _bookingMode == RideBookingMode.parcel
                                ? (isDark ? Colors.white : Colors.black87)
                                : (isDark ? Colors.white54 : Colors.black45),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            isRu ? 'Почта' : 'Pochta',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: _bookingMode == RideBookingMode.parcel
                                  ? FontWeight.w800
                                  : FontWeight.w600,
                              color: _bookingMode == RideBookingMode.parcel
                                  ? (isDark ? Colors.white : Colors.black87)
                                  : (isDark ? Colors.white60 : Colors.black54),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: AppSpacing.sm + 2),

          // 2. Connected Route Selector: [ Qayerdan ] and [ Qayerga ]
          Container(
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF22222A) : const Color(0xFFF3F4F6),
              borderRadius: AppRadius.borderLg,
              border: Border.all(
                color: isDark ? AppColors.borderDark : AppColors.borderLight,
                width: 1,
              ),
            ),
            child: Stack(
              alignment: Alignment.centerRight,
              children: [
                Column(
                  children: [
                    // Qayerdan (From)
                    InkWell(
                      onTap: () => _selectDepartureCity(context),
                      borderRadius:
                          const BorderRadius.vertical(top: Radius.circular(12)),
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
                        child: Row(
                          children: [
                            Icon(
                              Icons.radio_button_checked_rounded,
                              size: 16,
                              color: isDark ? Colors.white70 : Colors.black87,
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: fromCity == null
                                  ? Text(
                                      l10n.from,
                                      style: AppTypography.titleSmall.copyWith(
                                        color: isDark
                                            ? AppColors.textSecondaryDark
                                            : AppColors.textSecondaryLight,
                                        fontWeight: FontWeight.w600,
                                        fontSize: 14,
                                      ),
                                    )
                                  : Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text(
                                          l10n.from,
                                          style:
                                              AppTypography.labelSmall.copyWith(
                                            color: isDark
                                                ? AppColors.textSecondaryDark
                                                : AppColors.textSecondaryLight,
                                            fontSize: 10,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                        const SizedBox(height: 1),
                                        Text(
                                          fromCity.localizedName(localeCode),
                                          style: AppTypography.titleMedium
                                              .copyWith(
                                            color: isDark
                                                ? AppColors.textPrimaryDark
                                                : AppColors.textPrimaryLight,
                                            fontWeight: FontWeight.w800,
                                            fontSize: 14.5,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ],
                                    ),
                            ),
                            // Clear Departure City Button
                            if (fromCity != null)
                              InkWell(
                                onTap: () {
                                  HapticFeedback.lightImpact();
                                  ref
                                      .read(rideSearchNotifierProvider.notifier)
                                      .clearDepartureCity();
                                },
                                borderRadius: BorderRadius.circular(14),
                                child: Padding(
                                  padding: const EdgeInsets.all(6),
                                  child: Container(
                                    padding: const EdgeInsets.all(3),
                                    decoration: BoxDecoration(
                                      color: isDark
                                          ? Colors.white.withValues(alpha: 0.1)
                                          : Colors.black
                                              .withValues(alpha: 0.06),
                                      shape: BoxShape.circle,
                                    ),
                                    child: Icon(
                                      Icons.close_rounded,
                                      size: 14,
                                      color: isDark
                                          ? Colors.white70
                                          : Colors.black54,
                                    ),
                                  ),
                                ),
                              ),
                            const SizedBox(
                                width: 38), // Spacing for swap button
                          ],
                        ),
                      ),
                    ),

                    Divider(
                      height: 1,
                      indent: 38,
                      endIndent: 52,
                      color:
                          isDark ? AppColors.borderDark : AppColors.borderLight,
                    ),

                    // Qayerga (To)
                    InkWell(
                      onTap: () => _selectDestinationCity(context),
                      borderRadius: const BorderRadius.vertical(
                          bottom: Radius.circular(12)),
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
                        child: Row(
                          children: [
                            Icon(
                              Icons.location_on_rounded,
                              size: 17,
                              color: isDark ? Colors.white70 : Colors.black87,
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: toCity == null
                                  ? Text(
                                      l10n.to,
                                      style: AppTypography.titleSmall.copyWith(
                                        color: isDark
                                            ? AppColors.textSecondaryDark
                                            : AppColors.textSecondaryLight,
                                        fontWeight: FontWeight.w600,
                                        fontSize: 14,
                                      ),
                                    )
                                  : Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text(
                                          l10n.to,
                                          style:
                                              AppTypography.labelSmall.copyWith(
                                            color: isDark
                                                ? AppColors.textSecondaryDark
                                                : AppColors.textSecondaryLight,
                                            fontSize: 10,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                        const SizedBox(height: 1),
                                        Text(
                                          toCity.localizedName(localeCode),
                                          style: AppTypography.titleMedium
                                              .copyWith(
                                            color: isDark
                                                ? AppColors.textPrimaryDark
                                                : AppColors.textPrimaryLight,
                                            fontWeight: FontWeight.w800,
                                            fontSize: 14.5,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ],
                                    ),
                            ),
                            // Clear Destination City Button
                            if (toCity != null)
                              InkWell(
                                onTap: () {
                                  HapticFeedback.lightImpact();
                                  ref
                                      .read(rideSearchNotifierProvider.notifier)
                                      .clearDestinationCity();
                                },
                                borderRadius: BorderRadius.circular(14),
                                child: Padding(
                                  padding: const EdgeInsets.all(6),
                                  child: Container(
                                    padding: const EdgeInsets.all(3),
                                    decoration: BoxDecoration(
                                      color: isDark
                                          ? Colors.white.withValues(alpha: 0.1)
                                          : Colors.black
                                              .withValues(alpha: 0.06),
                                      shape: BoxShape.circle,
                                    ),
                                    child: Icon(
                                      Icons.close_rounded,
                                      size: 14,
                                      color: isDark
                                          ? Colors.white70
                                          : Colors.black54,
                                    ),
                                  ),
                                ),
                              ),
                            const SizedBox(
                                width: 38), // Spacing for swap button
                          ],
                        ),
                      ),
                    ),
                  ],
                ),

                // Floating Swap Button positioned on the right
                Positioned(
                  right: 10,
                  child: InkWell(
                    onTap: _handleSwap,
                    borderRadius: BorderRadius.circular(18),
                    child: AnimatedBuilder(
                      animation: _swapAnimationController,
                      builder: (context, child) {
                        return Transform.rotate(
                          angle: _swapAnimationController.value * math.pi,
                          child: child,
                        );
                      },
                      child: Container(
                        width: 34,
                        height: 34,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: isDark
                              ? const Color(0xFF2E3446)
                              : const Color(0xFFE2E8F0),
                        ),
                        child: Icon(
                          Icons.swap_vert_rounded,
                          color: isDark ? Colors.white : Colors.black87,
                          size: 20,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: AppSpacing.sm + 2),

          Row(
            children: [
              Expanded(
                child: InkWell(
                  onTap: () => _selectDate(context),
                  borderRadius: AppRadius.borderMd,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 10),
                    decoration: BoxDecoration(
                      color: isDark
                          ? const Color(0xFF22222A)
                          : const Color(0xFFF3F4F6),
                      borderRadius: AppRadius.borderMd,
                      border: Border.all(
                        color: isDark
                            ? AppColors.borderDark
                            : AppColors.borderLight,
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.calendar_today_rounded,
                          size: 15,
                          color: isDark ? Colors.white70 : Colors.black54,
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            AppDateTimeFormatter.formatRelativeDate(
                                context, travelDate),
                            style: AppTypography.labelMedium.copyWith(
                              fontWeight: FontWeight.w700,
                              fontSize: 12.5,
                              color: isDark
                                  ? Colors.white
                                  : AppColors.textPrimaryLight,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.xs + 2),
              Expanded(
                child: InkWell(
                  onTap: () => _showPassengerModal(context),
                  borderRadius: AppRadius.borderMd,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 10),
                    decoration: BoxDecoration(
                      color: isDark
                          ? const Color(0xFF22222A)
                          : const Color(0xFFF3F4F6),
                      borderRadius: AppRadius.borderMd,
                      border: Border.all(
                        color: isDark
                            ? AppColors.borderDark
                            : AppColors.borderLight,
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          _bookingMode == RideBookingMode.passenger
                              ? Icons.airline_seat_recline_normal_rounded
                              : Icons.inventory_2_rounded,
                          size: 16,
                          color: isDark ? Colors.white70 : Colors.black54,
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            _bookingMode == RideBookingMode.passenger
                                ? l10n.passengers(passengerCount)
                                : (isRu
                                    ? '$passengerCount мест(а)'
                                    : '$passengerCount ta joy'),
                            style: AppTypography.labelMedium.copyWith(
                              fontWeight: FontWeight.w700,
                              fontSize: 12.5,
                              color: isDark
                                  ? Colors.white
                                  : AppColors.textPrimaryLight,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Icon(
                          Icons.keyboard_arrow_down_rounded,
                          size: 16,
                          color: isDark
                              ? AppColors.textPrimaryDark.withValues(alpha: 0.8)
                              : AppColors.textPrimaryLight
                                  .withValues(alpha: 0.75),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: AppSpacing.md),

          // 5. Search CTA Button ("Qayerga boramiz?")
          Container(
            width: double.infinity,
            height: 52,
            decoration: BoxDecoration(
              color: AppColors.taxiYellow,
              borderRadius: AppRadius.borderMd,
              boxShadow: [
                BoxShadow(
                  color: AppColors.taxiYellow.withValues(alpha: 0.35),
                  blurRadius: 10,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: ElevatedButton(
              onPressed: () {
                HapticFeedback.mediumImpact();
                if (fromCity == null) {
                  _selectDepartureCity(context);
                  return;
                }
                if (toCity == null) {
                  _selectDestinationCity(context);
                  return;
                }
                ref.read(rideSearchNotifierProvider.notifier).searchRides();
                context.push('/search-results');
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                shadowColor: Colors.transparent,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                shape: const RoundedRectangleBorder(
                    borderRadius: AppRadius.borderMd),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.search_rounded,
                      size: 20, color: AppColors.charcoalBlack),
                  const SizedBox(width: 8),
                  Flexible(
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        fromCity != null && toCity != null
                            ? (_bookingMode == RideBookingMode.passenger
                                ? (isRu
                                    ? 'Найти такси / поездки'
                                    : 'Taksi / Qatnov qidirish')
                                : (isRu
                                    ? 'Найти такси для посылки'
                                    : 'Pochta uchun taksi qidirish'))
                            : (_bookingMode == RideBookingMode.passenger
                                ? (isRu ? 'Куда поедем?' : 'Qayerga boramiz?')
                                : (isRu
                                    ? 'Найти такси для посылки'
                                    : 'Pochta uchun taksi qidirish')),
                        style: const TextStyle(
                          color: AppColors.charcoalBlack,
                          fontSize: 15.5,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.2,
                        ),
                        maxLines: 1,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
