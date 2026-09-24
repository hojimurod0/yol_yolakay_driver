import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/app_date_formatter.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/utils/status_localization_mapper.dart';
import '../../../../core/widgets/app_avatar_initials.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_status_chip.dart';
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

    return Scaffold(
      backgroundColor:
          isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
      appBar: AppBar(
        backgroundColor:
            isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
        elevation: 0,
        title: Text(
          l10n.tripDetailsTitle,
          style: AppTypography.titleMedium.copyWith(
            fontWeight: FontWeight.w800,
            fontSize: 17,
            color: isDark ? Colors.white : AppColors.charcoalBlack,
          ),
        ),
      ),
      body: SafeArea(
        child: BlocBuilder<IntercityRidesBloc, IntercityRidesState>(
          builder: (context, state) {
            IntercityRideEntity? ride = widget.initialRide;
            if (state is IntercityRideDetailsLoaded) {
              ride = state.ride;
            }

            if (ride == null) {
              return const Center(
                child:
                    CircularProgressIndicator(color: AppColors.taxiYellowDark),
              );
            }

            final dateStr = AppDateFormatter.formatDateTime(ride.departureTime,
                locale: currentLocale);

            return ListView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.all(AppSpacing.lg),
              children: [
                // Route Card
                Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF1E1E26) : Colors.white,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(
                      color: isDark
                          ? const Color(0xFF2E2E3C)
                          : const Color(0xFFE2E4E8),
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
                          ? const Color(0xFF181820)
                          : const Color(0xFFF9FAFB),
                      borderRadius: BorderRadius.circular(16),
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
                    leadingIcon: const Icon(Icons.play_arrow_rounded, size: 22),
                  ),
                  const SizedBox(height: 10),
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
                    leadingIcon: const Icon(Icons.check_circle_outline_rounded,
                        size: 20),
                  ),
                  const SizedBox(height: 10),
                  OutlinedButton.icon(
                    onPressed: () =>
                        _showCancelRideDialog(context, ride!.id, l10n),
                    icon: const Icon(Icons.cancel_outlined,
                        size: 18, color: AppColors.error),
                    label: Text(l10n.cancelTripAction,
                        style: const TextStyle(
                            color: AppColors.error,
                            fontWeight: FontWeight.w700)),
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: AppColors.error.withOpacity(0.5)),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                  ),
                ],
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildPassengerCard(BuildContext context, RidePassengerEntity p,
      bool isDark, AppLocalizations l10n) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E26) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? const Color(0xFF2E2E3C) : const Color(0xFFE2E4E8),
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
    final reasonController =
        TextEditingController(text: l10n.defaultCancelTripReason);

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(l10n.cancelTripAction,
            style: const TextStyle(fontWeight: FontWeight.w800)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l10n.cancelTripReasonPrompt,
                style: const TextStyle(fontSize: 13)),
            const SizedBox(height: 8),
            TextField(
              controller: reasonController,
              decoration: const InputDecoration(border: OutlineInputBorder()),
            ),
          ],
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx), child: Text(l10n.back)),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              context.read<IntercityRidesBloc>().add(
                    UpdateRideStatusEvent(
                      rideId: rideId,
                      status: 'cancelled',
                      cancelReason: reasonController.text.trim(),
                    ),
                  );
            },
            style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.error,
                foregroundColor: Colors.white),
            child: Text(l10n.cancel),
          ),
        ],
      ),
    );
  }
}
