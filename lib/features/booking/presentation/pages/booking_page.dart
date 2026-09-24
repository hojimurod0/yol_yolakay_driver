import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/localization/app_localizations_helper.dart';
import '../../../../core/providers/core_providers.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/utils/date_time_formatter.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../rides/domain/entities/ride_entity.dart';
import '../../domain/entities/booking_entity.dart';
import '../providers/booking_flow_provider.dart';
import '../../../../core/widgets/vehicle_3d/seat_selection_bottom_sheet.dart';

class BookingPage extends ConsumerStatefulWidget {
  const BookingPage({
    super.key,
    required this.rideId,
    this.initialRide,
  });

  final String rideId;
  final RideEntity? initialRide;

  @override
  ConsumerState<BookingPage> createState() => _BookingPageState();
}

class _BookingPageState extends ConsumerState<BookingPage> {
  late final TextEditingController _nameController;
  late final TextEditingController _phoneController;

  @override
  void initState() {
    super.initState();
    final user = ref.read(authNotifierProvider).user;
    final locale = ref.read(localeNotifierProvider).languageCode;
    _nameController = TextEditingController(
      text: user?.localizedFullName(locale) ??
          (locale == 'ru' ? 'Ризо Каримов' : 'Rizo Karimov'),
    );
    _phoneController = TextEditingController(
      text: user?.phoneNumber ?? '+998 90 123 45 67',
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _handleConfirm() async {
    final booking =
        await ref.read(bookingFlowNotifierProvider.notifier).confirmBooking();
    if (booking != null && mounted) {
      context.go('/booking-success', extra: booking);
    } else if (mounted) {
      final error = ref.read(bookingFlowNotifierProvider).errorMessage;
      if (error != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(error),
            backgroundColor: AppColors.error,
            duration: const Duration(seconds: 3),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final l10n = context.l10n;
    final locale = ref.watch(localeNotifierProvider);
    final localeCode = locale.languageCode;
    final isRu = localeCode == 'ru';
    final bookingState = ref.watch(bookingFlowNotifierProvider);
    final ride = bookingState.selectedRide ?? widget.initialRide;

    if (ride == null) {
      return Scaffold(
        appBar: AppBar(title: Text(l10n.bookingTitle)),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    final pickupPoints = ride.pickupPoints;
    final depCityName = ride.departureCity.localizedName(localeCode);
    final destCityName = ride.destinationCity.localizedName(localeCode);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          l10n.bookingTitle,
          style: AppTypography.titleLarge.copyWith(fontWeight: FontWeight.w800),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(AppSpacing.lg),
              children: [
                // 1. Ride Summary Card
                AppCard(
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(AppSpacing.sm),
                        decoration: BoxDecoration(
                          color: isDark
                              ? AppColors.surfaceSubtleDark
                              : AppColors.primaryLight,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.route_rounded,
                          color: AppColors.primary,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: AppSpacing.md),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '$depCityName → $destCityName',
                              style: AppTypography.titleMedium.copyWith(
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            Text(
                              '${AppDateTimeFormatter.formatDate(ride.departureTime, locale: localeCode)} • ${AppDateTimeFormatter.formatTime(ride.departureTime)}',
                              style: AppTypography.bodySmall.copyWith(
                                color: isDark
                                    ? AppColors.textSecondaryDark
                                    : AppColors.textSecondaryLight,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: AppSpacing.lg),

                // 2. Select Seats & 3D Cabin Inspection
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: _buildSectionHeader(
                        stepNumber: '1',
                        title: isRu
                            ? 'Выбор места в авто'
                            : 'Avtomobilda joy tanlash',
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    // 3D Salon Button
                    InkWell(
                      onTap: () async {
                        HapticFeedback.selectionClick();
                        final selected = await SeatSelectionBottomSheet.show(
                          context,
                          vehicleModel:
                              ride.vehicle.localizedFullName(localeCode),
                          vehicleColor: ride.vehicle.localizedColor(localeCode),
                          pricePerSeat: ride.pricePerSeat,
                          initialSelectedSeatNumbers:
                              bookingState.selectedSeatNumbers,
                          occupiedSeatNumbers: bookingState.occupiedSeatNumbers,
                          isRu: isRu,
                        );
                        if (selected != null) {
                          ref
                              .read(bookingFlowNotifierProvider.notifier)
                              .setSeatNumbers(selected);
                        }
                      },
                      borderRadius: BorderRadius.circular(10),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 9, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.taxiYellow
                              .withValues(alpha: isDark ? 0.2 : 0.15),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: AppColors.taxiYellow.withValues(alpha: 0.4),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.view_in_ar_rounded,
                                size: 14, color: AppColors.taxiYellowDark),
                            const SizedBox(width: 4),
                            Text(
                              isRu ? '3D Салон' : '3D Ko\'rinish',
                              style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w800,
                                color: AppColors.taxiYellowDark,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.sm),

                // Interactive 4-Seat Selection Grid
                Row(
                  children: [1, 2, 3, 4].map((seatNum) {
                    final isOccupied =
                        bookingState.occupiedSeatNumbers.contains(seatNum);
                    final isSelected =
                        bookingState.selectedSeatNumbers.contains(seatNum);

                    Color bg;
                    Color fg;
                    Color border;
                    String statusText;

                    if (isOccupied) {
                      bg = isDark
                          ? const Color(0xFF16161A)
                          : const Color(0xFF1F1F24);
                      fg = Colors.white38;
                      border = isDark
                          ? const Color(0xFF282830)
                          : const Color(0xFF374151);
                      statusText = isRu ? 'Занято' : 'Band';
                    } else if (isSelected) {
                      bg = AppColors.taxiYellow;
                      fg = AppColors.charcoalBlack;
                      border = AppColors.taxiYellowDark;
                      statusText = isRu ? 'Выбрано' : 'Tanlandi';
                    } else {
                      bg = isDark ? const Color(0xFF24242C) : Colors.white;
                      fg = isDark ? Colors.white : AppColors.charcoalBlack;
                      border = isDark
                          ? const Color(0xFF33333E)
                          : const Color(0xFFE5E7EB);
                      statusText = isRu ? 'Свободно' : 'Bo‘sh';
                    }

                    return Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 2.5),
                        child: InkWell(
                          onTap: isOccupied
                              ? () {
                                  HapticFeedback.heavyImpact();
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(isRu
                                          ? 'Место № $seatNum уже занято'
                                          : '№ $seatNum joy allaqachon band qilingan'),
                                      duration: const Duration(seconds: 1),
                                    ),
                                  );
                                }
                              : () {
                                  HapticFeedback.selectionClick();
                                  ref
                                      .read(
                                          bookingFlowNotifierProvider.notifier)
                                      .toggleSeatNumber(seatNum);
                                },
                          borderRadius: BorderRadius.circular(12),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            decoration: BoxDecoration(
                              color: bg,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                  color: border, width: isSelected ? 2.0 : 1.0),
                              boxShadow: isSelected
                                  ? [
                                      BoxShadow(
                                        color: AppColors.taxiYellow
                                            .withValues(alpha: 0.35),
                                        blurRadius: 6,
                                        offset: const Offset(0, 2),
                                      ),
                                    ]
                                  : null,
                            ),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  isSelected
                                      ? Icons.check_circle_rounded
                                      : (isOccupied
                                          ? Icons.lock_outline_rounded
                                          : Icons
                                              .airline_seat_recline_normal_rounded),
                                  size: 18,
                                  color: fg,
                                ),
                                const SizedBox(height: 3),
                                Text(
                                  "№ $seatNum",
                                  style: TextStyle(
                                    fontSize: 11.5,
                                    fontWeight: FontWeight.w900,
                                    color: fg,
                                  ),
                                ),
                                Text(
                                  statusText,
                                  style: TextStyle(
                                    fontSize: 9,
                                    fontWeight: FontWeight.w700,
                                    color: fg.withValues(alpha: 0.8),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),

                const SizedBox(height: AppSpacing.lg),

                // 3. Select Pickup Point
                _buildSectionHeader(
                  stepNumber: '2',
                  title: l10n.pickupLocation,
                ),
                const SizedBox(height: AppSpacing.sm),
                Column(
                  children: pickupPoints.map((point) {
                    final isSelected =
                        bookingState.selectedPickupPoint?.id == point.id;
                    return Container(
                      margin: const EdgeInsets.only(bottom: AppSpacing.xs),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? (isDark
                                ? AppColors.surfaceSubtleDark
                                : AppColors.primaryLight.withValues(alpha: 0.6))
                            : Colors.transparent,
                        borderRadius: AppRadius.borderMd,
                        border: Border.all(
                          color: isSelected
                              ? AppColors.primary
                              : (isDark
                                  ? AppColors.borderDark
                                  : AppColors.borderLight),
                          width: isSelected ? 1.5 : 1,
                        ),
                      ),
                      child: ListTile(
                        onTap: () => ref
                            .read(bookingFlowNotifierProvider.notifier)
                            .setPickupPoint(point),
                        leading: Icon(
                          isSelected
                              ? Icons.radio_button_checked_rounded
                              : Icons.radio_button_off_rounded,
                          color: isSelected
                              ? AppColors.primary
                              : AppColors.textTertiaryLight,
                        ),
                        title: Text(
                          point.localizedTitle(localeCode),
                          style: AppTypography.titleSmall.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        subtitle: Text(
                          point.localizedDescription(localeCode),
                          style: AppTypography.bodySmall.copyWith(
                            color: isDark
                                ? AppColors.textSecondaryDark
                                : AppColors.textSecondaryLight,
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),

                const SizedBox(height: AppSpacing.lg),

                // 4. Passenger Information
                _buildSectionHeader(
                  stepNumber: '3',
                  title: l10n.personalInfo,
                ),
                const SizedBox(height: AppSpacing.sm),
                AppTextField(
                  controller: _nameController,
                  label: '${l10n.firstName} / ${l10n.lastName}',
                  prefixIcon: const Icon(Icons.person_outline_rounded),
                ),
                const SizedBox(height: AppSpacing.md),
                AppTextField(
                  controller: _phoneController,
                  label: l10n.phoneLabel,
                  prefixIcon: const Icon(Icons.phone_outlined),
                ),

                const SizedBox(height: AppSpacing.lg),

                // 5. Payment Method
                _buildSectionHeader(
                  stepNumber: '4',
                  title: l10n.paymentMethod,
                ),
                const SizedBox(height: AppSpacing.sm),
                _buildPaymentOption(
                  PaymentType.cash,
                  l10n.paymentCash,
                  Icons.payments_outlined,
                  bookingState.paymentType,
                  isDark,
                ),
                _buildPaymentOption(
                  PaymentType.click,
                  l10n.paymentClick,
                  Icons.account_balance_wallet_outlined,
                  bookingState.paymentType,
                  isDark,
                ),
                _buildPaymentOption(
                  PaymentType.payme,
                  l10n.paymentPayme,
                  Icons.credit_card_rounded,
                  bookingState.paymentType,
                  isDark,
                ),

                const SizedBox(height: AppSpacing.xl),
              ],
            ),
          ),

          // Bottom Confirmation Bar
          Container(
            padding: const EdgeInsets.all(AppSpacing.lg),
            decoration: BoxDecoration(
              color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
              border: Border(
                top: BorderSide(
                  color: isDark ? AppColors.borderDark : AppColors.borderLight,
                ),
              ),
            ),
            child: SafeArea(
              top: false,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        l10n.totalPrice,
                        style: AppTypography.titleMedium.copyWith(
                          color: isDark
                              ? AppColors.textSecondaryDark
                              : AppColors.textSecondaryLight,
                        ),
                      ),
                      Text(
                        AppCurrencyFormatter.format(bookingState.totalPrice,
                            locale: localeCode),
                        style: AppTypography.headlineMedium.copyWith(
                          fontWeight: FontWeight.w800,
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.md),
                  AppButton(
                    text: l10n.confirmBooking,
                    isLoading: bookingState.isBooking,
                    onPressed: _handleConfirm,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader({
    required String stepNumber,
    required String title,
  }) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.15),
            borderRadius: AppRadius.borderPill,
          ),
          child: Text(
            stepNumber,
            style: AppTypography.labelSmall.copyWith(
              color: AppColors.primary,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: Text(
            title,
            style: AppTypography.titleMedium.copyWith(
              fontWeight: FontWeight.w800,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildPaymentOption(
    PaymentType type,
    String label,
    IconData icon,
    PaymentType current,
    bool isDark,
  ) {
    final isSelected = type == current;
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.xs),
      decoration: BoxDecoration(
        color: isSelected
            ? (isDark
                ? AppColors.surfaceSubtleDark
                : AppColors.primaryLight.withValues(alpha: 0.6))
            : Colors.transparent,
        borderRadius: AppRadius.borderMd,
        border: Border.all(
          color: isSelected
              ? AppColors.primary
              : (isDark ? AppColors.borderDark : AppColors.borderLight),
          width: isSelected ? 1.5 : 1,
        ),
      ),
      child: ListTile(
        onTap: () =>
            ref.read(bookingFlowNotifierProvider.notifier).setPaymentType(type),
        leading: Icon(icon, color: AppColors.primary),
        title: Text(
          label,
          style: AppTypography.titleSmall.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
        trailing: isSelected
            ? const Icon(
                Icons.check_circle_rounded,
                color: AppColors.primary,
              )
            : null,
      ),
    );
  }
}
