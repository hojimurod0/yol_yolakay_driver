import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/localization/app_localizations_helper.dart';
import '../../../../core/providers/core_providers.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/utils/date_time_formatter.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_card.dart';
import '../../domain/entities/booking_entity.dart';

class BookingSuccessPage extends ConsumerWidget {
  const BookingSuccessPage({
    super.key,
    required this.booking,
  });

  final BookingEntity booking;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final l10n = context.l10n;
    final locale = ref.watch(localeNotifierProvider);
    final localeCode = locale.languageCode;
    final isRu = localeCode == 'ru';
    final ride = booking.ride;

    final depCityName = ride.departureCity.localizedName(localeCode);
    final destCityName = ride.destinationCity.localizedName(localeCode);
    final driverName = ride.driver.localizedName(localeCode);
    final carTitle = ride.vehicle.localizedFullName(localeCode);

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.lg, vertical: AppSpacing.xl),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // 1. Success Animation / Icon
                Container(
                  width: 84,
                  height: 84,
                  decoration: BoxDecoration(
                    color: const Color(0xFF10B981).withValues(alpha: 0.12),
                    shape: BoxShape.circle,
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.check_circle_rounded,
                      size: 64,
                      color: Color(0xFF10B981),
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.md + 4),

                // 2. Title & Short Subtitle
                Text(
                  isRu
                      ? 'Успешно забронировано!'
                      : 'Muvaffaqiyatli band qilindi!',
                  style: AppTypography.headlineLarge.copyWith(
                    fontWeight: FontWeight.w900,
                    fontSize: 22,
                    color: isDark ? Colors.white : AppColors.textPrimaryLight,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  isRu
                      ? 'Ваша поездка подтверждена. Водитель свяжется с вами.'
                      : 'Joyingiz muvaffaqiyatli band qilindi.',
                  style: TextStyle(
                    fontSize: 14,
                    color: isDark
                        ? AppColors.textSecondaryDark
                        : AppColors.textSecondaryLight,
                    fontWeight: FontWeight.w500,
                  ),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: AppSpacing.xl),

                // 3. Compact & Simple Summary Card
                AppCard(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Column(
                      children: [
                        _buildRow(
                          label: isRu ? 'Маршрут' : 'Yo\'nalish',
                          value: '$depCityName → $destCityName',
                          isDark: isDark,
                        ),
                        const SizedBox(height: 12),
                        _buildRow(
                          label: isRu ? 'Водитель' : 'Haydovchi',
                          value: '$driverName ($carTitle)',
                          isDark: isDark,
                        ),
                        const SizedBox(height: 12),
                        _buildRow(
                          label: isRu ? 'Время' : 'Vaqti',
                          value:
                              '${AppDateTimeFormatter.formatDate(ride.departureTime, locale: localeCode)}, ${AppDateTimeFormatter.formatTime(ride.departureTime)}',
                          isDark: isDark,
                        ),
                        const SizedBox(height: 12),
                        _buildRow(
                          label: isRu ? 'Места' : 'Joylar soni',
                          value: isRu
                              ? '${booking.seatCount} места'
                              : '${booking.seatCount} ta joy',
                          isDark: isDark,
                        ),
                        const SizedBox(height: 12),
                        Divider(
                          color: isDark
                              ? AppColors.borderDark
                              : AppColors.borderLight,
                          height: 1,
                        ),
                        const SizedBox(height: 12),
                        _buildRow(
                          label: l10n.totalPrice,
                          value: AppCurrencyFormatter.format(booking.totalPrice,
                              locale: localeCode),
                          isHighlight: true,
                          isDark: isDark,
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: AppSpacing.xl + 8),

                // 4. Action Button - Back to Home
                AppButton(
                  text: isRu ? 'На главную' : 'Asosiy sahifaga qaytish',
                  onPressed: () => context.go('/home'),
                ),
                const SizedBox(height: AppSpacing.sm),
                TextButton(
                  onPressed: () => context.go('/trips'),
                  child: Text(
                    isRu ? 'Посмотреть в поездках' : 'Qatnovlarimda ko\'rish',
                    style: TextStyle(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w700,
                      color: isDark
                          ? AppColors.taxiYellow
                          : AppColors.taxiYellowDark,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRow({
    required String label,
    required String value,
    bool isHighlight = false,
    required bool isDark,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 13,
            color: isDark ? Colors.white60 : const Color(0xFF64748B),
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(width: 14),
        Flexible(
          child: Text(
            value,
            textAlign: TextAlign.end,
            style: TextStyle(
              fontSize: isHighlight ? 15 : 13.5,
              fontWeight: isHighlight ? FontWeight.w900 : FontWeight.w700,
              color: isHighlight
                  ? (isDark ? AppColors.taxiYellow : AppColors.taxiYellowDark)
                  : (isDark ? Colors.white : const Color(0xFF1E293B)),
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}
