import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/utils/external_navigation_launcher.dart';
import '../../../../core/utils/status_localization_mapper.dart';
import '../../../../core/widgets/app_avatar_initials.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_status_chip.dart';
import '../../../../core/widgets/empty_state_widget.dart';
import '../../../../core/widgets/shimmer_loading.dart';
import '../../../../l10n/generated/app_localizations.dart';
import '../../domain/entities/taxi_order_entity.dart';
import '../bloc/taxi_radar_bloc.dart';
import '../bloc/taxi_radar_event.dart';
import '../bloc/taxi_radar_state.dart';

class DriverRadarPage extends StatefulWidget {
  const DriverRadarPage({super.key});

  @override
  State<DriverRadarPage> createState() => _DriverRadarPageState();
}

class _DriverRadarPageState extends State<DriverRadarPage> {
  @override
  void initState() {
    super.initState();
    context.read<TaxiRadarBloc>().add(const CheckActiveTaxiOrderEvent());
  }

  Future<void> _callPassenger(String phone) async {
    final uri = Uri.parse('tel:$phone');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      backgroundColor:
          isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
      appBar: AppBar(
        backgroundColor:
            isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.taxiYellow.withOpacity(0.2),
              ),
              child: const Icon(Icons.radar_rounded,
                  size: 20, color: AppColors.taxiYellowDark),
            ),
            const SizedBox(width: 10),
            Text(
              l10n.radarOrdersTitle,
              style: AppTypography.titleMedium.copyWith(
                fontWeight: FontWeight.w800,
                fontSize: 17,
                color: isDark ? Colors.white : AppColors.charcoalBlack,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            onPressed: () {
              HapticFeedback.selectionClick();
              context.read<TaxiRadarBloc>().add(const FetchRadarOrdersEvent());
            },
            icon: const Icon(Icons.refresh_rounded),
            tooltip: l10n.refresh,
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(
            color: isDark ? const Color(0xFF2C2C38) : const Color(0xFFE5E7EB),
            height: 1,
          ),
        ),
      ),
      body: SafeArea(
        child: BlocConsumer<TaxiRadarBloc, TaxiRadarState>(
          listener: (context, state) {
            if (state is OrderCompletedState) {
              _showCompletedDialog(context, state.result, l10n);
            } else if (state is TaxiRadarErrorState) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message),
                  backgroundColor: AppColors.error,
                  behavior: SnackBarBehavior.floating,
                ),
              );
            }
          },
          builder: (context, state) {
            if (state is ActiveOrderLoadedState) {
              return _buildActiveOrderView(
                  context, state.activeOrder, isDark, l10n);
            }

            if (state is TaxiRadarLoading) {
              return ListView.builder(
                padding: const EdgeInsets.all(AppSpacing.lg),
                itemCount: 3,
                itemBuilder: (_, __) => const RadarOrderCardShimmer(),
              );
            }

            if (state is RadarOrdersLoadedState) {
              if (state.activeOrder != null) {
                return _buildActiveOrderView(
                    context, state.activeOrder!, isDark, l10n);
              }

              final offers = state.offers;
              if (offers.isEmpty) {
                return RefreshIndicator(
                  color: AppColors.taxiYellowDark,
                  onRefresh: () async {
                    context
                        .read<TaxiRadarBloc>()
                        .add(const FetchRadarOrdersEvent());
                  },
                  child: ListView(
                    physics: const AlwaysScrollableScrollPhysics(
                        parent: BouncingScrollPhysics()),
                    children: [
                      const SizedBox(height: 60),
                      EmptyStateWidget(
                        title: l10n.noRadarOrdersTitle,
                        description: l10n.noRadarOrdersDesc,
                        icon: Icons.radar_rounded,
                      ),
                    ],
                  ),
                );
              }

              return RefreshIndicator(
                color: AppColors.taxiYellowDark,
                onRefresh: () async {
                  context
                      .read<TaxiRadarBloc>()
                      .add(const FetchRadarOrdersEvent());
                },
                child: ListView.builder(
                  physics: const AlwaysScrollableScrollPhysics(
                      parent: BouncingScrollPhysics()),
                  padding: const EdgeInsets.fromLTRB(
                      AppSpacing.lg, AppSpacing.lg, AppSpacing.lg, 120),
                  itemCount: offers.length,
                  itemBuilder: (ctx, index) {
                    final offer = offers[index];
                    return _RadarOfferCard(
                      key: ValueKey(offer.orderId),
                      offer: offer,
                      onAccept: () {
                        context
                            .read<TaxiRadarBloc>()
                            .add(AcceptOrderEvent(offer.orderId));
                      },
                      onDecline: () {
                        context
                            .read<TaxiRadarBloc>()
                            .add(DeclineOrderEvent(offer.orderId));
                      },
                    );
                  },
                ),
              );
            }

            return const Center(
                child:
                    CircularProgressIndicator(color: AppColors.taxiYellowDark));
          },
        ),
      ),
    );
  }

  Widget _buildActiveOrderView(
    BuildContext context,
    ActiveTaxiOrderEntity order,
    bool isDark,
    AppLocalizations l10n,
  ) {
    final currentLocale = Localizations.localeOf(context).languageCode;
    return ListView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.all(AppSpacing.lg),
      children: [
        // Accessible Status Badge
        Center(
          child: AppStatusChip(
            label: StatusLocalizationMapper.mapStatus(order.status,
                locale: currentLocale),
            variant: StatusLocalizationMapper.mapVariant(order.status),
          ),
        ),
        const SizedBox(height: 18),

        // Passenger Details Card
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1E1E26) : Colors.white,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: isDark ? const Color(0xFF2E2E3C) : const Color(0xFFE2E4E8),
            ),
          ),
          child: Column(
            children: [
              Row(
                children: [
                  AppAvatarInitials(
                      name: order.passenger.name, size: 48, fontSize: 18),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          order.passenger.name,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            color:
                                isDark ? Colors.white : AppColors.charcoalBlack,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Row(
                          children: [
                            const Icon(Icons.star_rounded,
                                size: 16, color: AppColors.starGold),
                            const SizedBox(width: 4),
                            Text(
                              order.passenger.rating.toStringAsFixed(1),
                              style: const TextStyle(
                                  fontWeight: FontWeight.w700, fontSize: 12),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  IconButton.filled(
                    onPressed: () {
                      final isToDestination = order.isInProgress;
                      final targetLat = isToDestination
                          ? order.destination.lat
                          : order.pickup.lat;
                      final targetLng = isToDestination
                          ? order.destination.lng
                          : order.pickup.lng;
                      final targetTitle = isToDestination
                          ? order.destination.address
                          : order.pickup.address;
                      ExternalNavigationLauncher.showNavigationChooser(
                        context,
                        lat: targetLat,
                        lng: targetLng,
                        destinationTitle: targetTitle,
                      );
                    },
                    icon: const Icon(Icons.navigation_rounded),
                    style: IconButton.styleFrom(
                      backgroundColor: const Color(0xFFFC3F1D),
                      foregroundColor: Colors.white,
                    ),
                    tooltip: 'Navigatsiya',
                  ),
                  const SizedBox(width: 8),
                  IconButton.filled(
                    onPressed: () => _callPassenger(order.passenger.phone),
                    icon: const Icon(Icons.phone_rounded),
                    style: IconButton.styleFrom(
                      backgroundColor: AppColors.success,
                      foregroundColor: Colors.white,
                    ),
                    tooltip: 'Qo\'ng\'iroq qilish',
                  ),
                ],
              ),
              const Divider(height: 24),

              // Route details
              _buildRouteRow(
                  order.pickup.address, order.destination.address, isDark),
              const SizedBox(height: 12),
              OutlinedButton.icon(
                onPressed: () {
                  final isToDestination = order.isInProgress;
                  final targetLat = isToDestination
                      ? order.destination.lat
                      : order.pickup.lat;
                  final targetLng = isToDestination
                      ? order.destination.lng
                      : order.pickup.lng;
                  final targetTitle = isToDestination
                      ? 'Yetkazish: ${order.destination.address}'
                      : 'Olish manzili: ${order.pickup.address}';
                  ExternalNavigationLauncher.showNavigationChooser(
                    context,
                    lat: targetLat,
                    lng: targetLng,
                    destinationTitle: targetTitle,
                  );
                },
                icon: const Icon(Icons.near_me_rounded, size: 18),
                label: Text(
                  order.isInProgress
                      ? 'Yetkazish manziliga navigatsiya'
                      : 'Mijoz oldiga navigatsiya',
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size.fromHeight(42),
                  foregroundColor:
                      isDark ? AppColors.taxiYellow : AppColors.charcoalBlack,
                  side: BorderSide(
                    color: isDark
                        ? AppColors.taxiYellow.withOpacity(0.5)
                        : const Color(0xFFD1D5DB),
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const Divider(height: 24),

              // Fare
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(l10n.tripPrice,
                      style: const TextStyle(fontWeight: FontWeight.w600)),
                  Text(
                    AppCurrencyFormatter.format(order.price),
                    style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                        color: AppColors.taxiYellowDark),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),

        // Action Stepper Buttons
        if (order.isAssigned)
          AppButton(
            text: l10n.arrivedAtPickupAction,
            onPressed: () {
              context.read<TaxiRadarBloc>().add(
                    UpdateOrderStatusEvent(
                        orderId: order.orderId, status: 'arrived'),
                  );
            },
            variant: AppButtonVariant.taxi,
            height: 52,
            leadingIcon: const Icon(Icons.place_rounded, size: 20),
          )
        else if (order.isArrived)
          AppButton(
            text: l10n.startRideAction,
            onPressed: () {
              context.read<TaxiRadarBloc>().add(
                    UpdateOrderStatusEvent(
                        orderId: order.orderId, status: 'in_progress'),
                  );
            },
            variant: AppButtonVariant.taxi,
            height: 52,
            leadingIcon: const Icon(Icons.play_arrow_rounded, size: 22),
          )
        else if (order.isInProgress)
          AppButton(
            text: l10n.completeRideAction,
            onPressed: () {
              _showCompletePriceDialog(context, order, l10n);
            },
            variant: AppButtonVariant.primary,
            height: 52,
            leadingIcon:
                const Icon(Icons.check_circle_outline_rounded, size: 20),
          ),

        const SizedBox(height: 12),

        // Cancel order button
        OutlinedButton.icon(
          onPressed: () => _showCancelDialog(context, order.orderId, l10n),
          icon: const Icon(Icons.cancel_outlined,
              size: 18, color: AppColors.error),
          label: Text(l10n.cancelOrderAction,
              style: const TextStyle(
                  color: AppColors.error, fontWeight: FontWeight.w700)),
          style: OutlinedButton.styleFrom(
            side: BorderSide(color: AppColors.error.withOpacity(0.5)),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            padding: const EdgeInsets.symmetric(vertical: 14),
          ),
        ),
      ],
    );
  }

  Widget _buildRouteRow(String pickup, String destination, bool isDark) {
    return Column(
      children: [
        Row(
          children: [
            const Icon(Icons.circle, color: AppColors.success, size: 12),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                pickup,
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 13.5,
                  color: isDark ? Colors.white : AppColors.charcoalBlack,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            const Icon(Icons.location_on_rounded,
                color: AppColors.error, size: 14),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                destination,
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 13.5,
                  color: isDark ? Colors.white : AppColors.charcoalBlack,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  void _showCompletePriceDialog(BuildContext context,
      ActiveTaxiOrderEntity order, AppLocalizations l10n) {
    final controller = TextEditingController(text: order.price.toString());

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(l10n.completeRideModalTitle,
            style: const TextStyle(fontWeight: FontWeight.w800)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l10n.finalPaymentAmountLabel,
                style: const TextStyle(fontSize: 13)),
            const SizedBox(height: 8),
            TextField(
              controller: controller,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(border: OutlineInputBorder()),
            ),
          ],
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx), child: Text(l10n.cancel)),
          ElevatedButton(
            onPressed: () {
              final finalPrice =
                  int.tryParse(controller.text.trim()) ?? order.price;
              Navigator.pop(ctx);
              context.read<TaxiRadarBloc>().add(
                    CompleteOrderEvent(
                      orderId: order.orderId,
                      finalPrice: finalPrice,
                      paymentReceived: true,
                    ),
                  );
            },
            style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.success,
                foregroundColor: Colors.white),
            child: Text(l10n.completeAction),
          ),
        ],
      ),
    );
  }

  void _showCancelDialog(
      BuildContext context, String orderId, AppLocalizations l10n) {
    String selectedReason = l10n.cancelReasonPassengerNoShow;
    final reasons = [
      l10n.cancelReasonPassengerNoShow,
      l10n.cancelReasonPassengerTookAnother,
      l10n.cancelReasonCarIssue,
      l10n.cancelReasonOther,
    ];

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setModalState) => AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Text(l10n.cancelOrderAction,
              style:
                  const TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: reasons.map((r) {
              return RadioListTile<String>(
                title: Text(r, style: const TextStyle(fontSize: 13)),
                value: r,
                groupValue: selectedReason,
                activeColor: AppColors.error,
                onChanged: (val) {
                  if (val != null) setModalState(() => selectedReason = val);
                },
              );
            }).toList(),
          ),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(ctx), child: Text(l10n.back)),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(ctx);
                context.read<TaxiRadarBloc>().add(
                    CancelOrderEvent(orderId: orderId, reason: selectedReason));
              },
              style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.error,
                  foregroundColor: Colors.white),
              child: Text(l10n.cancel),
            ),
          ],
        ),
      ),
    );
  }

  void _showCompletedDialog(BuildContext context,
      TaxiCompletionResultEntity result, AppLocalizations l10n) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(14),
              decoration: const BoxDecoration(
                  color: AppColors.success, shape: BoxShape.circle),
              child: const Icon(Icons.check_rounded,
                  color: Colors.white, size: 36),
            ),
            const SizedBox(height: 14),
            Text(result.message,
                style:
                    const TextStyle(fontWeight: FontWeight.w900, fontSize: 17),
                textAlign: TextAlign.center),
            const SizedBox(height: 12),
            Text(
                l10n.netEarningsLabel(
                    AppCurrencyFormatter.format(result.earnings)),
                style: const TextStyle(
                    fontWeight: FontWeight.w700, color: AppColors.success)),
            Text(
                l10n.commissionDeductedLabel(
                    AppCurrencyFormatter.format(result.commissionDeducted)),
                style: const TextStyle(
                    fontSize: 12, color: AppColors.textSecondary)),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: AppButton(
                text: l10n.backToRadarAction,
                onPressed: () {
                  Navigator.pop(ctx);
                  context
                      .read<TaxiRadarBloc>()
                      .add(const FetchRadarOrdersEvent());
                },
                variant: AppButtonVariant.taxi,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Interactive Radar Offer Card with timeout countdown bar.
class _RadarOfferCard extends StatefulWidget {
  const _RadarOfferCard({
    super.key,
    required this.offer,
    required this.onAccept,
    required this.onDecline,
  });

  final TaxiOrderOfferEntity offer;
  final VoidCallback onAccept;
  final VoidCallback onDecline;

  @override
  State<_RadarOfferCard> createState() => _RadarOfferCardState();
}

class _RadarOfferCardState extends State<_RadarOfferCard> {
  late int _secondsLeft;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _secondsLeft = widget.offer.timeoutSeconds;
    _startTimer();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (_secondsLeft > 1) {
        setState(() => _secondsLeft--);
      } else {
        t.cancel();
        widget.onDecline();
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context);
    final offer = widget.offer;
    final progress =
        _secondsLeft / (offer.timeoutSeconds > 0 ? offer.timeoutSeconds : 25);

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E26) : Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isDark ? const Color(0xFF2E2E3C) : const Color(0xFFE2E4E8),
          width: 1.4,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.3 : 0.05),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: [
          // Timeout progress bar
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(18)),
            child: LinearProgressIndicator(
              value: progress.clamp(0.0, 1.0),
              backgroundColor: isDark ? Colors.white10 : Colors.black12,
              valueColor: AlwaysStoppedAnimation<Color>(
                progress > 0.3 ? AppColors.taxiYellowDark : AppColors.error,
              ),
              minHeight: 4,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header row: Tier, distance, fare
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppColors.taxiYellow.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            offer.tier.toUpperCase(),
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w900,
                              color: AppColors.charcoalBlack,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          "~${offer.distanceToPickupKm} km",
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: isDark
                                ? Colors.white60
                                : AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                    Text(
                      AppCurrencyFormatter.format(offer.estimatedPrice),
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w900,
                        color: AppColors.taxiYellowDark,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),

                // Pickup address
                Row(
                  children: [
                    const Icon(Icons.circle,
                        color: AppColors.success, size: 10),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        offer.pickup.address,
                        style: TextStyle(
                          fontSize: 13.5,
                          fontWeight: FontWeight.w700,
                          color:
                              isDark ? Colors.white : AppColors.charcoalBlack,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),

                // Destination address
                Row(
                  children: [
                    const Icon(Icons.location_on_rounded,
                        color: AppColors.error, size: 12),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        offer.destination.address,
                        style: TextStyle(
                          fontSize: 13.5,
                          fontWeight: FontWeight.w700,
                          color:
                              isDark ? Colors.white : AppColors.charcoalBlack,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Action buttons: Decline & Accept
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () {
                          HapticFeedback.selectionClick();
                          widget.onDecline();
                        },
                        style: OutlinedButton.styleFrom(
                          foregroundColor:
                              isDark ? Colors.white60 : AppColors.charcoalBlack,
                          side: BorderSide(
                              color: isDark
                                  ? Colors.white24
                                  : AppColors.borderLight),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        child: Text(l10n.declineOrder,
                            style:
                                const TextStyle(fontWeight: FontWeight.w700)),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      flex: 2,
                      child: ElevatedButton.icon(
                        onPressed: () {
                          HapticFeedback.mediumImpact();
                          widget.onAccept();
                        },
                        icon: const Icon(Icons.check_rounded, size: 20),
                        label: Text(l10n.acceptWithTimer(_secondsLeft),
                            style:
                                const TextStyle(fontWeight: FontWeight.w800)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.taxiYellow,
                          foregroundColor: AppColors.charcoalBlack,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
