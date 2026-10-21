import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../core/services/navigation_launcher_service.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_responsive.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/app_date_formatter.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/utils/status_localization_mapper.dart';
import '../../../../core/widgets/app_avatar_initials.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_snackbar.dart';
import '../../../../core/widgets/app_status_chip.dart';
import '../../../../core/widgets/shimmer_loading.dart';
import '../../../../l10n/generated/app_localizations.dart';
import '../../domain/entities/intercity_ride_entity.dart';
import '../bloc/intercity_rides_bloc.dart';
import '../bloc/intercity_rides_event.dart';
import '../bloc/intercity_rides_state.dart';

class DriverTripDetailsPage extends StatefulWidget {
  const DriverTripDetailsPage({
    super.key,
    required this.rideId,
    this.initialRide,
  });

  final String rideId;
  final IntercityRideEntity? initialRide;

  @override
  State<DriverTripDetailsPage> createState() => _DriverTripDetailsPageState();
}

class _DriverTripDetailsPageState extends State<DriverTripDetailsPage> {
  @override
  void initState() {
    super.initState();
    context.read<IntercityRidesBloc>().add(LoadRideDetailsEvent(widget.rideId));
  }

  Future<void> _callPhone(String phone) async {
    final uri = Uri.parse('tel:$phone');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context);
    final currentLocale = Localizations.localeOf(context).languageCode;

    return BlocConsumer<IntercityRidesBloc, IntercityRidesState>(
      listener: (context, state) {
        if (state is RideDeletedSuccessState) {
          AppSnackBar.showSuccess(
              context, 'Qatnov muvaffaqiyatli bekor qilindi / o\'chirildi!');
          context
              .read<IntercityRidesBloc>()
              .add(const LoadRidesEvent(status: 'active'));
          context.pop();
        } else if (state is IntercityRidesError) {
          AppSnackBar.showError(context, state.message);
        }
      },
      builder: (context, state) {
        IntercityRideEntity? ride = widget.initialRide;
        bool isOffline = false;
        if (state is IntercityRideDetailsLoaded) {
          ride = state.ride;
          isOffline = state.isOfflineCached;
        }

        final dateStr = ride != null
            ? AppDateFormatter.formatDateTime(ride.departureTime,
                locale: currentLocale)
            : '';

        return Scaffold(
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
              l10n.tripDetailsTitle,
              style: AppTypography.titleMedium.copyWith(
                fontWeight: FontWeight.w800,
                fontSize: 17,
                color: isDark ? Colors.white : AppColors.charcoalBlack,
              ),
            ),
            actions: [
              if (ride != null && ride.isActive) ...[
                IconButton(
                  icon: const Icon(Icons.edit_outlined),
                  tooltip: 'Tahrirlash',
                  onPressed: () async {
                    HapticFeedback.selectionClick();
                    final updated = await context
                        .push<bool>('/driver/create-trip', extra: ride);
                    if (updated == true && context.mounted) {
                      context
                          .read<IntercityRidesBloc>()
                          .add(LoadRideDetailsEvent(widget.rideId));
                    }
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.delete_outline_rounded,
                      color: AppColors.error),
                  tooltip: 'Bekor qilish / O\'chirish',
                  onPressed: () {
                    HapticFeedback.selectionClick();
                    _showCancelRideDialog(context, ride!.id, l10n);
                  },
                ),
              ],
            ],
          ),
          body: SafeArea(
            child: ride == null
                ? const DriverTripDetailsShimmer()
                : Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(
                        maxWidth: AppResponsive.maxContentWidth,
                      ),
                      child: ListView(
                        physics: const BouncingScrollPhysics(),
                        padding: EdgeInsets.symmetric(
                          horizontal: AppResponsive.horizontalPadding(context),
                          vertical: AppSpacing.lg,
                        ),
                        children: [
                          if (isOffline)
                            Container(
                              margin: const EdgeInsets.only(bottom: 14),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 14, vertical: 11),
                              decoration: BoxDecoration(
                                color: Colors.amber.shade800
                                    .withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                    color: Colors.amber.shade800
                                        .withValues(alpha: 0.35)),
                              ),
                              child: Row(
                                children: [
                                  Icon(Icons.cloud_off_rounded,
                                      size: 20, color: Colors.amber.shade800),
                                  const SizedBox(width: 10),
                                  const Expanded(
                                    child: Text(
                                      'Oflayn rejim — Ma\'lumotlar keshdan ko\'rsatilmoqda. Internet mavjud bo\'lmasa ham yo\'lovchilarga telefon qila olasiz.',
                                      style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w600),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          // Route Card
                    Container(
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: isDark ? AppColors.borderDark : AppColors.borderLight,
                          width: 1.0,
                        ),
                      ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "${ride.fromCity} ➔ ${ride.toCity}",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w900,
                              color: isDark
                                  ? Colors.white
                                  : AppColors.charcoalBlack,
                            ),
                          ),
                          AppStatusChip(
                            label: StatusLocalizationMapper.mapStatus(
                                ride.status,
                                locale: currentLocale),
                            variant: StatusLocalizationMapper.mapVariant(
                                ride.status),
                            compact: true,
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          const Icon(Icons.access_time_rounded,
                              size: 16, color: AppColors.taxiYellowDark),
                          const SizedBox(width: 8),
                          Text(dateStr,
                              style: const TextStyle(
                                  fontWeight: FontWeight.w600, fontSize: 13.5)),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          const Icon(Icons.event_seat_rounded,
                              size: 16, color: AppColors.taxiYellowDark),
                          const SizedBox(width: 8),
                          Text(
                            l10n.seatsDetail(ride.bookedSeats,
                                ride.availableSeats, ride.totalSeats),
                            style: const TextStyle(
                                fontWeight: FontWeight.w600, fontSize: 13.5),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          const Icon(Icons.payments_outlined,
                              size: 16, color: AppColors.taxiYellowDark),
                          const SizedBox(width: 8),
                          Text(
                            l10n.pricePerSeat(
                                AppCurrencyFormatter.format(ride.pricePerSeat)),
                            style: const TextStyle(
                                fontWeight: FontWeight.w700,
                                fontSize: 13.5,
                                color: AppColors.taxiYellowDark),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton.icon(
                          onPressed: () {
                            HapticFeedback.selectionClick();
                            final r = ride;
                            if (r == null) return;
                            NavigationLauncherService.instance
                                .showNavigationPickerModal(
                              context: context,
                              address: r.toCity,
                              title: '${r.fromCity} ➔ ${r.toCity} yo\'nalishi',
                            );
                          },
                          icon: const Icon(Icons.near_me_rounded,
                              size: 18, color: AppColors.taxiYellowDark),
                          label: Text(
                            'Navigatorda ochish (${ride.toCity})',
                            style: const TextStyle(
                                fontWeight: FontWeight.w700, fontSize: 13),
                          ),
                          style: OutlinedButton.styleFrom(
                            foregroundColor:
                                isDark ? Colors.white : AppColors.charcoalBlack,
                            side: BorderSide(
                                color: isDark
                                    ? AppColors.borderDark
                                    : AppColors.borderLight),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12)),
                            padding: const EdgeInsets.symmetric(
                                vertical: 11, horizontal: 14),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // Passengers Section Title
                Text(
                  l10n.passengersCount(ride.passengers.length),
                  style: AppTypography.titleMedium.copyWith(
                    fontWeight: FontWeight.w800,
                    fontSize: 16,
                    color: isDark ? Colors.white : AppColors.charcoalBlack,
                  ),
                ),
                const SizedBox(height: 12),

                if (ride.passengers.isEmpty)
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: isDark
                          ? AppColors.surfaceSubtleDark
                          : AppColors.surfaceSubtleLight,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isDark
                            ? AppColors.borderDark
                            : AppColors.borderLight,
                        width: 1.0,
                      ),
                    ),
                    child: Center(
                      child: Text(
                        l10n.noPassengersBooked,
                        style:
                            const TextStyle(color: Colors.grey, fontSize: 13),
                      ),
                    ),
                  )
                else
                  ...ride.passengers.map(
                      (p) => _buildPassengerCard(context, p, isDark, l10n)),

                const SizedBox(height: 28),

                // Trip Lifecycle Action Buttons
                if (ride.isActive) ...[
                  if (ride.status == 'active') ...[
                    AppButton(
                      text: l10n.markRideStartedAction,
                      onPressed: () {
                        context.read<IntercityRidesBloc>().add(
                              UpdateRideStatusEvent(
                                  rideId: ride!.id, status: 'started'),
                            );
                      },
                      variant: AppButtonVariant.taxi,
                      height: 52,
                      leadingIcon:
                          const Icon(Icons.play_arrow_rounded, size: 22),
                    ),
                    const SizedBox(height: 10),
                  ] else if (ride.status == 'started') ...[
                    AppButton(
                      text: l10n.completeRideAction,
                      onPressed: () {
                        context.read<IntercityRidesBloc>().add(
                              UpdateRideStatusEvent(
                                  rideId: ride!.id, status: 'completed'),
                            );
                      },
                      variant: AppButtonVariant.primary,
                      height: 52,
                      leadingIcon: const Icon(
                          Icons.check_circle_outline_rounded,
                          size: 20),
                    ),
                    const SizedBox(height: 10),
                  ],
                  OutlinedButton.icon(
                    onPressed: () async {
                      HapticFeedback.selectionClick();
                      final updated = await context.push<bool>(
                        '/driver/create-trip',
                        extra: ride,
                      );
                      if (updated == true && context.mounted) {
                        context.read<IntercityRidesBloc>().add(
                              LoadRideDetailsEvent(widget.rideId),
                            );
                      }
                    },
                    icon: const Icon(Icons.edit_outlined, size: 18),
                    label: const Text('Qatnovni tahrirlash',
                        style: TextStyle(fontWeight: FontWeight.w700)),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.taxiYellowDark,
                      side: const BorderSide(color: AppColors.taxiYellowDark),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14)),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                  ),
                  const SizedBox(height: 10),
                  OutlinedButton.icon(
                    onPressed: () {
                      HapticFeedback.selectionClick();
                      _showCancelRideDialog(context, ride!.id, l10n);
                    },
                    icon: const Icon(Icons.delete_outline_rounded,
                        size: 18, color: AppColors.error),
                    label: const Text('Qatnovni o\'chirish / bekor qilish',
                        style: TextStyle(
                            color: AppColors.error,
                            fontWeight: FontWeight.w700)),
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(
                          color: AppColors.error.withValues(alpha: 0.5)),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14)),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  },
);
}

  Widget _buildPassengerCard(BuildContext context, RidePassengerEntity p,
      bool isDark, AppLocalizations l10n) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? AppColors.borderDark : AppColors.borderLight,
          width: 1.0,
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              AppAvatarInitials(name: p.passengerName, size: 40, fontSize: 15),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      p.passengerName,
                      style: const TextStyle(
                          fontWeight: FontWeight.w800, fontSize: 14.5),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      l10n.passengerSeatsDetail(p.seatsCount,
                          AppCurrencyFormatter.format(p.totalPrice)),
                      style: const TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                          fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              ),
              if (p.passengerPhone.isNotEmpty)
                IconButton.filled(
                  onPressed: () => _callPhone(p.passengerPhone),
                  icon: const Icon(Icons.phone_rounded, size: 18),
                  style: IconButton.styleFrom(
                      backgroundColor: AppColors.success,
                      foregroundColor: Colors.white),
                ),
            ],
          ),
          if (p.status == 'pending') ...[
            const Divider(height: 18),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      context.read<IntercityRidesBloc>().add(
                            BookingActionEvent(
                              bookingId: p.bookingId,
                              action: 'reject',
                              rideId: widget.rideId,
                              rejectReason: 'O\'rinlar to\'ldi',
                            ),
                          );
                    },
                    child: Text(l10n.declineOrder,
                        style: const TextStyle(
                            color: AppColors.error,
                            fontWeight: FontWeight.w700)),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      context.read<IntercityRidesBloc>().add(
                            BookingActionEvent(
                              bookingId: p.bookingId,
                              action: 'accept',
                              rideId: widget.rideId,
                            ),
                          );
                    },
                    style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.taxiYellow,
                        foregroundColor: AppColors.charcoalBlack),
                    child: Text(l10n.confirm,
                        style: const TextStyle(fontWeight: FontWeight.w800)),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  void _showCancelRideDialog(
      BuildContext context, String rideId, AppLocalizations l10n) {
    String selectedReason = 'Rejalar o\'zgardi';
    final reasonController = TextEditingController();

    final reasons = [
      'Rejalar o\'zgardi',
      'Mashinada texnik nosozlik',
      'Yo\'lovchilar yetarli emas',
      'Boshqa sabab',
    ];

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModalState) {
          final isDark = Theme.of(ctx).brightness == Brightness.dark;
          return Container(
            padding: EdgeInsets.fromLTRB(
              20,
              16,
              20,
              MediaQuery.of(ctx).viewInsets.bottom + 24,
            ),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF191B24) : Colors.white,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: isDark ? Colors.white24 : Colors.black12,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.error.withValues(alpha: 0.12),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.delete_outline_rounded,
                          color: AppColors.error, size: 22),
                    ),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Text(
                        'Qatnovni bekor qilish / o\'chirish',
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  'Haqiqatan ham bu qatnovni bekor qilmoqchimisiz? Sababini tanlang:',
                  style: TextStyle(
                    fontSize: 13,
                    color: isDark ? Colors.grey[400] : Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 14),
                ...reasons.map((r) {
                  final isSelected = selectedReason == r;
                  return InkWell(
                    onTap: () {
                      HapticFeedback.selectionClick();
                      setModalState(() => selectedReason = r);
                    },
                    borderRadius: BorderRadius.circular(12),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          vertical: 8, horizontal: 4),
                      child: Row(
                        children: [
                          Icon(
                            isSelected
                                ? Icons.radio_button_checked_rounded
                                : Icons.radio_button_off_rounded,
                            color: isSelected
                                ? AppColors.taxiYellowDark
                                : (isDark ? Colors.white38 : Colors.black38),
                            size: 20,
                          ),
                          const SizedBox(width: 10),
                          Text(
                            r,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: isSelected
                                  ? FontWeight.w700
                                  : FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }),
                if (selectedReason == 'Boshqa sabab') ...[
                  const SizedBox(height: 10),
                  TextField(
                    controller: reasonController,
                    decoration: InputDecoration(
                      hintText: 'Sababni yozing...',
                      filled: true,
                      fillColor: isDark
                          ? const Color(0xFF222634)
                          : const Color(0xFFF3F4F6),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ],
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(ctx),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        child: Text(l10n.back),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          HapticFeedback.heavyImpact();
                          Navigator.pop(ctx);
                          final finalReason = selectedReason == 'Boshqa sabab' &&
                                  reasonController.text.trim().isNotEmpty
                              ? reasonController.text.trim()
                              : selectedReason;

                          context.read<IntercityRidesBloc>().add(
                                DeleteRideEvent(
                                  rideId: rideId,
                                  reason: finalReason,
                                ),
                              );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.error,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                          elevation: 0,
                        ),
                        child: const Text(
                          'O\'chirish',
                          style: TextStyle(
                            fontWeight: FontWeight.w800,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
