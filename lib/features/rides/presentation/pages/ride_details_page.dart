import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/localization/app_localizations_helper.dart';
import '../../../../core/providers/core_providers.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_shadows.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/utils/date_time_formatter.dart';
import '../../../../core/utils/direct_contact_launcher.dart';
import '../../../../core/widgets/app_avatar_initials.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/uzbek_license_plate.dart';
import '../../../../core/widgets/vehicle_3d/seat_selection_bottom_sheet.dart';
import '../../../booking/presentation/providers/booking_flow_provider.dart';
import '../../domain/entities/ride_entity.dart';

class RideDetailsPage extends ConsumerWidget {
  const RideDetailsPage({
    super.key,
    required this.ride,
  });

  final RideEntity ride;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final l10n = context.l10n;
    final locale = ref.watch(localeNotifierProvider);
    final localeCode = locale.languageCode;
    final isRu = localeCode == 'ru';

    final depCityName = ride.departureCity.localizedName(localeCode);
    final destCityName = ride.destinationCity.localizedName(localeCode);
    final driverName = ride.driver.localizedName(localeCode);
    final vehicleTitle = ride.vehicle.localizedFullName(localeCode);
    final vehicleColor = ride.vehicle.localizedColor(localeCode);
    final vehiclePlate = ride.vehicle.localizedLicensePlate(localeCode);

    final pickupText = ride.pickupPoints.isNotEmpty
        ? ride.pickupPoints.first.localizedTitle(localeCode)
        : depCityName;
    final dropoffText = ride.dropoffPoints.isNotEmpty
        ? ride.dropoffPoints.first.localizedTitle(localeCode)
        : destCityName;

    return Scaffold(
      backgroundColor:
          isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
      appBar: AppBar(
        backgroundColor:
            isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
        elevation: 0,
        title: Text(
          isRu ? 'Детали поездки' : 'Qatnov tafsilotlari',
          style: AppTypography.titleLarge.copyWith(
            fontWeight: FontWeight.w800,
            color:
                isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.share_outlined),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    l10n.tripLinkCopied(
                        '$depCityName → $destCityName ($vehicleTitle, $driverName)'),
                  ),
                ),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.all(AppSpacing.md),
              children: [
                // 1. Route & Timeline Card
                Container(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  decoration: BoxDecoration(
                    color:
                        isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
                    borderRadius: AppRadius.borderXl,
                    border: Border.all(
                      color:
                          isDark ? AppColors.borderDark : AppColors.borderLight,
                    ),
                    boxShadow: isDark ? AppShadows.darkSm : AppShadows.sm,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Date Header Pill
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: AppColors.taxiYellow
                                  .withValues(alpha: isDark ? 0.2 : 0.15),
                              borderRadius: AppRadius.borderPill,
                              border: Border.all(
                                color: AppColors.taxiYellowDark
                                    .withValues(alpha: 0.4),
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  Icons.calendar_today_rounded,
                                  size: 13,
                                  color: AppColors.taxiYellowDark,
                                ),
                                const SizedBox(width: 5),
                                Text(
                                  AppDateTimeFormatter.formatDate(
                                      ride.departureTime),
                                  style: AppTypography.labelSmall.copyWith(
                                    color: isDark
                                        ? AppColors.taxiYellow
                                        : AppColors.charcoalBlack,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: AppColors.success
                                  .withValues(alpha: isDark ? 0.2 : 0.12),
                              borderRadius: AppRadius.borderPill,
                            ),
                            child: Text(
                              isRu
                                  ? '${ride.availableSeats} места свободно'
                                  : '${ride.availableSeats} ta bo\'sh joy',
                              style: AppTypography.labelSmall.copyWith(
                                color: AppColors.success,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: AppSpacing.md),

                      // Departure & Arrival Timeline
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Column(
                            children: [
                              const SizedBox(height: 4),
                              Container(
                                width: 12,
                                height: 12,
                                decoration: const BoxDecoration(
                                  color: AppColors.success,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              Container(
                                width: 2,
                                height: 50,
                                color: isDark
                                    ? AppColors.borderDark
                                    : AppColors.borderLight,
                              ),
                              Container(
                                width: 12,
                                height: 12,
                                decoration: const BoxDecoration(
                                  color: AppColors.error,
                                  shape: BoxShape.circle,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(width: AppSpacing.md),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Departure
                                Row(
                                  children: [
                                    Text(
                                      AppDateTimeFormatter.formatTime(
                                          ride.departureTime),
                                      style: AppTypography.titleLarge.copyWith(
                                        fontWeight: FontWeight.w900,
                                        fontSize: 18,
                                        color: isDark
                                            ? AppColors.textPrimaryDark
                                            : AppColors.textPrimaryLight,
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: Text(
                                        depCityName,
                                        textAlign: TextAlign.end,
                                        style:
                                            AppTypography.titleMedium.copyWith(
                                          fontWeight: FontWeight.w800,
                                          color: isDark
                                              ? AppColors.textPrimaryDark
                                              : AppColors.textPrimaryLight,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                                Text(
                                  pickupText,
                                  style: AppTypography.bodySmall.copyWith(
                                    color: isDark
                                        ? AppColors.textSecondaryDark
                                        : AppColors.textSecondaryLight,
                                  ),
                                ),

                                const SizedBox(height: 22),

                                // Arrival
                                Row(
                                  children: [
                                    Text(
                                      AppDateTimeFormatter.formatTime(
                                          ride.estimatedArrivalTime),
                                      style: AppTypography.titleLarge.copyWith(
                                        fontWeight: FontWeight.w900,
                                        fontSize: 18,
                                        color: isDark
                                            ? AppColors.textPrimaryDark
                                            : AppColors.textPrimaryLight,
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: Text(
                                        destCityName,
                                        textAlign: TextAlign.end,
                                        style:
                                            AppTypography.titleMedium.copyWith(
                                          fontWeight: FontWeight.w800,
                                          color: isDark
                                              ? AppColors.textPrimaryDark
                                              : AppColors.textPrimaryLight,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                                Text(
                                  dropoffText,
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
                    ],
                  ),
                ),

                const SizedBox(height: AppSpacing.md),

                // 2. Direct Driver Contact Quick Actions Card
                Container(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  decoration: BoxDecoration(
                    color:
                        isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
                    borderRadius: AppRadius.borderXl,
                    border: Border.all(
                      color:
                          isDark ? AppColors.borderDark : AppColors.borderLight,
                    ),
                    boxShadow: isDark ? AppShadows.darkSm : AppShadows.sm,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.contact_phone_rounded,
                            size: 18,
                            color: isDark ? Colors.white70 : Colors.black87,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              isRu
                                  ? 'Прямая связь с водителем'
                                  : 'Haydovchi bilan to\'g\'ridan-to\'g\'ri aloqa',
                              style: AppTypography.titleMedium.copyWith(
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        isRu
                            ? 'Свяжитесь напрямую для уточнения времени, адреса или посылки'
                            : 'Vaqt, manzil yoki posilka bo\'yicha haydovchi bilan to\'g\'ridan-to\'g\'ri gaplashing',
                        style: AppTypography.bodySmall.copyWith(
                          color: isDark
                              ? AppColors.textSecondaryDark
                              : AppColors.textSecondaryLight,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.md),

                      // Contact Buttons Row
                      Row(
                        children: [
                          // 1. Call Button
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: () {
                                DirectContactLauncher.makePhoneCall(
                                  context,
                                  ride.driver.phoneNumber,
                                );
                              },
                              icon: const Icon(Icons.phone_rounded, size: 18),
                              label: Text(
                                isRu ? 'Позвонить' : 'Qo\'ng\'iroq',
                                style: const TextStyle(
                                    fontWeight: FontWeight.w800),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primary,
                                foregroundColor: Colors.white,
                                padding:
                                    const EdgeInsets.symmetric(vertical: 12),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                            ),
                          ),

                          const SizedBox(width: 8),

                          // 2. Telegram Button
                          if (ride.driver.telegramHandle != null)
                            Expanded(
                              child: ElevatedButton.icon(
                                onPressed: () {
                                  DirectContactLauncher.openTelegram(
                                    context,
                                    ride.driver.telegramHandle!,
                                  );
                                },
                                icon: const Icon(Icons.send_rounded, size: 17),
                                label: const Text(
                                  'Telegram',
                                  style: TextStyle(fontWeight: FontWeight.w800),
                                ),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: isDark
                                      ? const Color(0xFF252A38)
                                      : const Color(0xFFE2E8F0),
                                  foregroundColor: isDark
                                      ? Colors.white
                                      : const Color(0xFF1E293B),
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 12),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                              ),
                            ),

                          const SizedBox(width: 8),

                          // 3. SMS Button
                          IconButton.filledTonal(
                            onPressed: () {
                              final body =
                                  'Assalomu alaykum, ${ride.driver.name}. Yo\'l-Yo\'lakay ilovasidan $depCityName-$destCityName qatnovi bo\'yicha yozmoqdaman.';
                              DirectContactLauncher.sendSms(
                                context,
                                ride.driver.phoneNumber,
                                body: body,
                              );
                            },
                            icon: const Icon(Icons.sms_rounded),
                            style: IconButton.styleFrom(
                              backgroundColor: isDark
                                  ? const Color(0xFF252A38)
                                  : const Color(0xFFE5E7EB),
                              foregroundColor: isDark
                                  ? Colors.white
                                  : const Color(0xFF1E293B),
                              padding: const EdgeInsets.all(12),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: AppSpacing.md),

                // 3. Complete Transparent Pricing Breakdown Card
                Container(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  decoration: BoxDecoration(
                    color:
                        isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
                    borderRadius: AppRadius.borderXl,
                    border: Border.all(
                      color:
                          isDark ? AppColors.borderDark : AppColors.borderLight,
                    ),
                    boxShadow: isDark ? AppShadows.darkSm : AppShadows.sm,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            isRu
                                ? 'Тарифы и прозрачные цены'
                                : 'Shaffof tariflar va narxlar',
                            style: AppTypography.titleMedium.copyWith(
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: isDark
                                  ? const Color(0xFF252A38)
                                  : const Color(0xFFE2E8F0),
                              borderRadius: AppRadius.borderPill,
                            ),
                            child: Text(
                              isRu ? '0% комиссия' : '0% komissiya',
                              style: TextStyle(
                                color: isDark
                                    ? Colors.white
                                    : AppColors.textPrimaryLight,
                                fontSize: 11,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.sm),

                      // Notice Banner: Direct payment to driver
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: isDark
                              ? const Color(0xFF1B2234)
                              : const Color(0xFFF1F5F9),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: isDark ? Colors.white12 : Colors.black12,
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.info_outline_rounded,
                              size: 18,
                              color: isDark ? Colors.white70 : Colors.black87,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                isRu
                                    ? 'Оплата производится напрямую водителю (наличными или картой) при посадке.'
                                    : 'To\'lov to\'g\'ridan-to\'g\'ri haydovchiga (naqd yoki karta) safar vaqtida amalga oshiriladi.',
                                style: TextStyle(
                                  fontSize: 11.5,
                                  color: isDark
                                      ? Colors.white70
                                      : AppColors.textPrimaryLight,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: AppSpacing.md),

                      // Price items: Per Seat, Full Salon, Parcel
                      _buildPriceRow(
                        title: isRu
                            ? '1 место (Пассажир)'
                            : '1 ta o\'rindiq (Yo\'lovchi)',
                        subtitle: isRu
                            ? 'Стоимость за одного человека'
                            : 'Bir yo\'lovchi uchun qatnov narxi',
                        price: AppCurrencyFormatter.format(ride.pricePerSeat,
                            locale: localeCode),
                        isPrimary: true,
                        isDark: isDark,
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      _buildPriceRow(
                        title: isRu
                            ? 'Весь салон (4 места)'
                            : 'Butun salon (4 ta joy)',
                        subtitle: isRu
                            ? 'Индивидуальная поездка без попутчиков'
                            : 'Boshqa hamrohlarsiz shaxsiy safar',
                        price: AppCurrencyFormatter.format(ride.fullSalonPrice,
                            locale: localeCode),
                        isPrimary: false,
                        isDark: isDark,
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      _buildPriceRow(
                        title: isRu
                            ? 'Передача посылки / почты'
                            : 'Pochta / Posilka yuborish',
                        subtitle: isRu
                            ? 'Доставка документов и вещей'
                            : 'Hujjat va buyumlarni yetkazib berish',
                        price: AppCurrencyFormatter.format(ride.parcelPrice,
                            locale: localeCode),
                        isPrimary: false,
                        isDark: isDark,
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: AppSpacing.md),

                // 4. Driver & Vehicle Profile Card
                Container(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  decoration: BoxDecoration(
                    color:
                        isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
                    borderRadius: AppRadius.borderXl,
                    border: Border.all(
                      color:
                          isDark ? AppColors.borderDark : AppColors.borderLight,
                    ),
                    boxShadow: isDark ? AppShadows.darkSm : AppShadows.sm,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        isRu
                            ? 'Водитель и автомобиль'
                            : 'Haydovchi va avtomobil',
                        style: AppTypography.titleMedium.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.md),

                      Row(
                        children: [
                          AppAvatarInitials(
                            name: driverName,
                            size: 50,
                            fontSize: 18,
                          ),
                          const SizedBox(width: AppSpacing.md),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Text(
                                      driverName,
                                      style: AppTypography.titleMedium.copyWith(
                                        fontWeight: FontWeight.w800,
                                      ),
                                    ),
                                    if (ride.driver.isVerified) ...[
                                      const SizedBox(width: 6),
                                      const Icon(
                                        Icons.verified_rounded,
                                        size: 16,
                                        color: AppColors.taxiYellowDark,
                                      ),
                                    ],
                                  ],
                                ),
                                const SizedBox(height: 2),
                                Wrap(
                                  crossAxisAlignment: WrapCrossAlignment.center,
                                  spacing: 4,
                                  runSpacing: 2,
                                  children: [
                                    const Icon(
                                      Icons.star_rounded,
                                      size: 16,
                                      color: AppColors.starGold,
                                    ),
                                    Text(
                                      '${ride.driver.rating}',
                                      style: AppTypography.labelMedium.copyWith(
                                        fontWeight: FontWeight.w800,
                                      ),
                                    ),
                                    Text(
                                      '• ${ride.driver.completedTrips} ${isRu ? 'поездок' : 'safar'}',
                                      style: AppTypography.bodySmall.copyWith(
                                        color: isDark
                                            ? AppColors.textSecondaryDark
                                            : AppColors.textSecondaryLight,
                                      ),
                                    ),
                                    Text(
                                      '• ${ride.driver.experienceYears} ${isRu ? 'лет стажа' : 'yil staj'}',
                                      style: AppTypography.bodySmall.copyWith(
                                        color: isDark
                                            ? AppColors.textSecondaryDark
                                            : AppColors.textSecondaryLight,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),

                      if (ride.driver.bio != null) ...[
                        const SizedBox(height: AppSpacing.sm),
                        Text(
                          ride.driver.bio!,
                          style: TextStyle(
                            fontSize: 12.5,
                            color: isDark ? Colors.white70 : Colors.black87,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ],

                      const SizedBox(height: AppSpacing.md),
                      Divider(
                          color: isDark
                              ? AppColors.borderDark
                              : AppColors.borderLight),
                      const SizedBox(height: AppSpacing.sm),

                      // Vehicle info row
                      Row(
                        children: [
                          Expanded(
                            child: Row(
                              children: [
                                Icon(
                                  Icons.directions_car_rounded,
                                  color:
                                      isDark ? Colors.white70 : Colors.black87,
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        vehicleTitle,
                                        style:
                                            AppTypography.titleSmall.copyWith(
                                          fontWeight: FontWeight.w800,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      Text(
                                        vehicleColor,
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
                          const SizedBox(width: 8),
                          UzbekLicensePlate(
                            plateNumber: vehiclePlate,
                            height: 26,
                          ),
                        ],
                      ),

                      const SizedBox(height: AppSpacing.md),

                      // Vehicle features badges
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          if (ride.vehicle.hasAc)
                            _buildFeatureChip(
                              icon: Icons.ac_unit_rounded,
                              label: isRu ? 'Кондиционер' : 'Konditsioner',
                              isDark: isDark,
                            ),
                          if (ride.vehicle.hasSpaciousTrunk)
                            _buildFeatureChip(
                              icon: Icons.luggage_rounded,
                              label: isRu
                                  ? 'Katta yukxona (Bagaj)'
                                  : 'Katta yukxona',
                              isDark: isDark,
                            ),
                          if (ride.vehicle.hasWifi)
                            _buildFeatureChip(
                              icon: Icons.wifi_rounded,
                              label: 'Wi-Fi',
                              isDark: isDark,
                            ),
                        ],
                      ),

                      const SizedBox(height: AppSpacing.md),

                      // 3D Cabin & Seat Layout Inspection Button
                      InkWell(
                        onTap: () async {
                          HapticFeedback.selectionClick();
                          await SeatSelectionBottomSheet.show(
                            context,
                            vehicleModel:
                                ride.vehicle.localizedFullName(localeCode),
                            vehicleColor:
                                ride.vehicle.localizedColor(localeCode),
                            pricePerSeat: ride.pricePerSeat,
                            initialSelectedSeatNumbers: const {1},
                            occupiedSeatNumbers: const {3},
                            isRu: isRu,
                          );
                        },
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 11),
                          decoration: BoxDecoration(
                            color: AppColors.taxiYellow
                                .withValues(alpha: isDark ? 0.15 : 0.12),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: AppColors.taxiYellowDark
                                  .withValues(alpha: 0.5),
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  const Icon(Icons.view_in_ar_rounded,
                                      size: 20,
                                      color: AppColors.taxiYellowDark),
                                  const SizedBox(width: 10),
                                  Text(
                                    isRu
                                        ? '3D Салон и расположение мест'
                                        : '3D Salon va joylar tartibi',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w800,
                                      fontSize: 13.5,
                                      color: AppColors.taxiYellowDark,
                                    ),
                                  ),
                                ],
                              ),
                              const Icon(Icons.arrow_forward_ios_rounded,
                                  size: 13, color: AppColors.taxiYellowDark),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Bottom Quick Reserve & Direct Connect CTA Bar
          Container(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.md,
              AppSpacing.sm,
              AppSpacing.md,
              AppSpacing.lg,
            ),
            decoration: BoxDecoration(
              color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
              border: Border(
                top: BorderSide(
                  color: isDark ? AppColors.borderDark : AppColors.borderLight,
                ),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.06),
                  blurRadius: 10,
                  offset: const Offset(0, -3),
                ),
              ],
            ),
            child: SafeArea(
              top: false,
              child: Row(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        isRu ? '1 место:' : '1 ta o\'rin:',
                        style: AppTypography.labelSmall.copyWith(
                          color: isDark
                              ? AppColors.textSecondaryDark
                              : AppColors.textSecondaryLight,
                        ),
                      ),
                      Text(
                        AppCurrencyFormatter.format(ride.pricePerSeat,
                            locale: localeCode),
                        style: const TextStyle(
                          fontWeight: FontWeight.w900,
                          color: AppColors.taxiYellowDark,
                          fontSize: 18,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: AppButton(
                      text: isRu ? 'Забронировать место' : 'Joy band qilish',
                      height: 48,
                      onPressed: () {
                        ref
                            .read(bookingFlowNotifierProvider.notifier)
                            .startBooking(ride);
                        context.push('/booking/${ride.id}');
                      },
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

  Widget _buildPriceRow({
    required String title,
    required String subtitle,
    required String price,
    required bool isPrimary,
    required bool isDark,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1B1F2A) : const Color(0xFFF3F4F6),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                ),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 11,
                    color: isDark ? Colors.white54 : Colors.black54,
                  ),
                ),
              ],
            ),
          ),
          Text(
            price,
            style: TextStyle(
              fontSize: 14.5,
              fontWeight: FontWeight.w900,
              color: isPrimary
                  ? AppColors.taxiYellowDark
                  : (isDark ? Colors.white : Colors.black87),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureChip({
    required IconData icon,
    required String label,
    required bool isDark,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF22222A) : const Color(0xFFF3F4F6),
        borderRadius: AppRadius.borderPill,
        border: Border.all(
          color: isDark ? AppColors.borderDark : AppColors.borderLight,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: AppColors.taxiYellowDark),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: isDark
                  ? AppColors.textPrimaryDark
                  : AppColors.textPrimaryLight,
            ),
          ),
        ],
      ),
    );
  }
}
