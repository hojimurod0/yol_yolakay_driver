import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../core/config/pilot_route.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/localization/app_localizations_helper.dart';
import '../../../../core/services/audio_alert_service.dart';
import '../../../../core/services/location_service.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/widgets/app_menu_drawer.dart';
import '../../../../core/widgets/app_snackbar.dart';
import '../../../driver/presentation/pages/driver_main_shell_page.dart';
import '../../../intercity_rides/domain/repositories/intercity_rides_repository.dart';
import '../../../notifications/presentation/bloc/notifications_bloc.dart';
import '../../domain/entities/home_dashboard_entity.dart';
import '../bloc/home_bloc.dart';
import '../bloc/home_event.dart';
import '../bloc/home_state.dart';

/// Map-first driver home: today's earnings on top, the route to open in a
/// bottom panel. Loading the dashboard also starts GPS tracking when online.
class PilotDriverHomePage extends StatefulWidget {
  const PilotDriverHomePage({super.key});

  @override
  State<PilotDriverHomePage> createState() => _PilotDriverHomePageState();
}

class _LastTrip {
  const _LastTrip(this.from, this.to, this.price, this.seats);

  final String from;
  final String to;
  final int price;
  final int seats;
}

class _PilotDriverHomePageState extends State<PilotDriverHomePage> {
  GoogleMapController? _map;
  HomeDashboardEntity? _dashboard;
  _LastTrip? _lastTrip;
  bool _hasLocation = false;
  LatLng? _me;

  /// Open ride that has requests waiting for an answer.
  Timer? _requestPoll;
  String? _openRideId;
  int _pendingRequests = 0;

  @override
  void initState() {
    super.initState();
    context.read<HomeBloc>().add(const LoadHomeDashboardEvent());
    _readLastTrip();
    _locate();
    _checkRequests();
    _requestPoll =
        Timer.periodic(const Duration(seconds: 10), (_) => _checkRequests());
  }

  @override
  void dispose() {
    _requestPoll?.cancel();
    _map?.dispose();
    super.dispose();
  }

  /// New booking requests only show on the ride page, so the home screen
  /// checks the open ride and raises a banner (with sound) when one waits.
  Future<void> _checkRequests() async {
    try {
      final repo = sl<IntercityRidesRepository>();
      var id = _dashboard?.activeIntercityTripSummary?.tripId ?? '';
      if (id.isEmpty) {
        final open = await repo.getRides(status: 'active', limit: 3);
        id = open.items.isEmpty ? '' : open.items.first.id;
      }
      if (id.isEmpty) {
        if (mounted && _pendingRequests != 0) {
          setState(() => _pendingRequests = 0);
        }
        return;
      }
      final ride = await repo.getRideDetails(id);
      final pending = ride.passengers.where((p) => p.isPending).length;
      if (!mounted) return;
      if (pending > _pendingRequests) {
        AudioAlertService.instance.playNewOrderAlert();
      }
      setState(() {
        _openRideId = id;
        _pendingRequests = pending;
      });
    } catch (_) {
      // Keep the last known banner; the next tick retries.
    }
  }

  /// The create-trip page remembers the last route it opened.
  void _readLastTrip() {
    try {
      final prefs = sl<SharedPreferences>();
      final from = prefs.getString('last_trip_from');
      final to = prefs.getString('last_trip_to');
      if (from == null || to == null || from.isEmpty || to.isEmpty) return;
      _lastTrip = _LastTrip(
        from,
        to,
        prefs.getInt('last_trip_price') ?? 0,
        prefs.getInt('last_trip_seats') ?? 4,
      );
    } catch (_) {
      _lastTrip = null;
    }
  }

  Future<void> _locate() async {
    final pos = await sl<LocationService>().getCurrentPosition();
    if (!mounted || pos == null) return;
    setState(() {
      _hasLocation = true;
      _me = LatLng(pos.latitude, pos.longitude);
    });
    _map?.animateCamera(CameraUpdate.newLatLngZoom(_me!, 14));
  }

  Future<void> _openRoute({required bool repeat}) async {
    HapticFeedback.mediumImpact();
    final last = _lastTrip;
    await context.push('/pilot/open-route', extra: {
      if (repeat && last != null) ...{
        'toCity': last.from == PilotRoute.districtCityId,
        'price': last.price,
      },
    });
    if (mounted) setState(_readLastTrip);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final unread =
        context.select<NotificationsBloc, int>((b) => b.state.unreadCount);

    return BlocConsumer<HomeBloc, HomeState>(
      listener: (context, state) {
        if (state is HomeError && _dashboard != null) {
          AppSnackBar.showError(context, state.message);
        }
      },
      builder: (context, state) {
        if (state is HomeLoaded) _dashboard = state.dashboard;
        final dashboard = _dashboard;
        final toggling = state is ShiftTogglingState;

        return Scaffold(
          body: Stack(
            children: [
              Positioned.fill(
                child: GoogleMap(
                  initialCameraPosition: const CameraPosition(
                    target: PilotRoute.districtLatLng,
                    zoom: 13,
                  ),
                  onMapCreated: (c) {
                    _map = c;
                    if (_me != null) {
                      c.moveCamera(CameraUpdate.newLatLngZoom(_me!, 14));
                    }
                  },
                  style: isDark ? darkMapStyle : null,
                  myLocationEnabled: _hasLocation,
                  myLocationButtonEnabled: false,
                  zoomControlsEnabled: false,
                  mapToolbarEnabled: false,
                  compassEnabled: false,
                  padding: const EdgeInsets.only(bottom: 320),
                ),
              ),
              SafeArea(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(14, 10, 14, 0),
                  child: Row(
                    children: [
                      MapRoundButton(
                        icon: Icons.menu_rounded,
                        tooltip: l10n.menuTitle,
                        onPressed: () =>
                            driverShellScaffoldKey.currentState?.openDrawer(),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: dashboard == null
                              ? const SizedBox.shrink()
                              : _EarningsPill(
                                  amount: dashboard.dailyStats.todayEarnings,
                                ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      MapRoundButton(
                        icon: Icons.notifications_outlined,
                        tooltip: l10n.mapNotifications,
                        badge: unread,
                        onPressed: () => context.push('/driver/notifications'),
                      ),
                    ],
                  ),
                ),
              ),
              Align(
                alignment: Alignment.bottomCenter,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(right: 14, bottom: 10),
                      child: MapRoundButton(
                        icon: Icons.my_location_rounded,
                        tooltip: l10n.mapMyLocation,
                        onPressed: _locate,
                      ),
                    ),
                    _DriverPanel(
                      dashboard: dashboard,
                      lastTrip: _lastTrip,
                      pendingRequests: _pendingRequests,
                      onOpenRequests: _openRideId == null
                          ? null
                          : () => context.push('/pilot/ride/$_openRideId'),
                      toggling: toggling,
                      isDark: isDark,
                      onOpenRoute: _openRoute,
                      onToggleShift: (online) => context
                          .read<HomeBloc>()
                          .add(ToggleShiftEvent(online)),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _EarningsPill extends StatelessWidget {
  const _EarningsPill({required this.amount});

  final int amount;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Material(
      color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
      elevation: 3,
      shadowColor: Colors.black38,
      shape: const StadiumBorder(),
      child: InkWell(
        customBorder: const StadiumBorder(),
        onTap: () => context.go('/driver/wallet'),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          child: Text(
            context.l10n.driverTodayPill(AppCurrencyFormatter.format(amount)),
            style: TextStyle(
              fontSize: 13.5,
              fontWeight: FontWeight.w800,
              color: isDark
                  ? AppColors.textPrimaryDark
                  : AppColors.textPrimaryLight,
            ),
          ),
        ),
      ),
    );
  }
}

class _DriverPanel extends StatelessWidget {
  const _DriverPanel({
    required this.dashboard,
    required this.lastTrip,
    required this.pendingRequests,
    required this.onOpenRequests,
    required this.toggling,
    required this.isDark,
    required this.onOpenRoute,
    required this.onToggleShift,
  });

  final HomeDashboardEntity? dashboard;
  final _LastTrip? lastTrip;
  final int pendingRequests;
  final VoidCallback? onOpenRequests;
  final bool toggling;
  final bool isDark;
  final Future<void> Function({required bool repeat}) onOpenRoute;
  final ValueChanged<bool> onToggleShift;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final ink = isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight;
    final muted =
        isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight;
    final subtle =
        isDark ? AppColors.surfaceSubtleDark : AppColors.surfaceSubtleLight;
    final status = dashboard?.verificationStatus ?? 'approved';
    final docsPending = status != 'approved';
    final activeTrip = dashboard?.activeIntercityTrip != null;
    final trip = lastTrip;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(26)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x24000000),
            blurRadius: 24,
            offset: Offset(0, -6),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 10, 16, 14),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 5,
                  decoration: BoxDecoration(
                    color: isDark
                        ? AppColors.borderDarkHover
                        : AppColors.borderLightHover,
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              if (pendingRequests > 0 && onOpenRequests != null) ...[
                _RequestsBanner(count: pendingRequests, onTap: onOpenRequests!),
                const SizedBox(height: 10),
              ],
              if (docsPending) ...[
                _Notice(
                  icon: Icons.hourglass_top_rounded,
                  color: AppColors.warning,
                  text: l10n.driverDocsPending,
                  action: l10n.driverDocsAction,
                  onTap: () => context.push('/verification'),
                ),
                const SizedBox(height: 10),
              ],
              if (activeTrip) ...[
                _Notice(
                  icon: Icons.route_rounded,
                  color: AppColors.success,
                  text: l10n.driverActiveTrip,
                  action: '›',
                  onTap: () {
                    final id =
                        dashboard?.activeIntercityTripSummary?.tripId ?? '';
                    if (id.isEmpty) {
                      context.go('/driver/trips');
                    } else {
                      context.push('/pilot/ride/$id');
                    }
                  },
                ),
                const SizedBox(height: 10),
              ],
              if (trip != null) ...[
                Text(
                  l10n.driverLastRoute.toUpperCase(),
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.5,
                    color: Color(0xFFB45309),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${PilotRoute.cityName(trip.from)} → ${PilotRoute.cityName(trip.to)}',
                  style: TextStyle(
                    fontSize: 19,
                    fontWeight: FontWeight.w900,
                    color: ink,
                  ),
                ),
                const SizedBox(height: 10),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  decoration: BoxDecoration(
                    color: subtle,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          l10n.seatsCountPlural(trip.seats),
                          style: TextStyle(fontSize: 13.5, color: ink),
                        ),
                      ),
                      if (trip.price > 0)
                        Text(
                          AppCurrencyFormatter.format(trip.price),
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            color: ink,
                          ),
                        ),
                    ],
                  ),
                ),
              ] else
                Text(
                  l10n.driverNoRouteYet,
                  style: TextStyle(fontSize: 14, height: 1.4, color: muted),
                ),
              const SizedBox(height: 12),
              _PrimaryButton(
                label:
                    trip != null ? l10n.driverOpenAgain : l10n.driverOpenRoute,
                onTap: () => onOpenRoute(repeat: trip != null),
              ),
              if (trip != null)
                TextButton(
                  onPressed: () => onOpenRoute(repeat: false),
                  child: Text(
                    l10n.driverChangeTimePrice,
                    style: TextStyle(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w700,
                      color: muted,
                    ),
                  ),
                ),
              if (dashboard != null) ...[
                Divider(
                  height: 16,
                  color: isDark ? AppColors.borderDark : AppColors.borderLight,
                ),
                Row(
                  children: [
                    Container(
                      width: 10,
                      height: 10,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: dashboard!.isOnline
                            ? AppColors.success
                            : (isDark
                                ? AppColors.textTertiaryDark
                                : AppColors.textTertiaryLight),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        dashboard!.isOnline
                            ? l10n.driverOnline
                            : l10n.driverOffline,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: ink,
                        ),
                      ),
                    ),
                    toggling
                        ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(strokeWidth: 2.4),
                          )
                        : Switch.adaptive(
                            value: dashboard!.isOnline,
                            activeTrackColor: AppColors.primary,
                            onChanged: onToggleShift,
                          ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _Notice extends StatelessWidget {
  const _Notice({
    required this.icon,
    required this.color,
    required this.text,
    required this.action,
    required this.onTap,
  });

  final IconData icon;
  final Color color;
  final String text;
  final String action;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Material(
      color: color.withValues(alpha: isDark ? 0.16 : 0.10),
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          child: Row(
            children: [
              Icon(icon, size: 20, color: color),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  text,
                  style: TextStyle(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w600,
                    color: isDark
                        ? AppColors.textPrimaryDark
                        : AppColors.textPrimaryLight,
                  ),
                ),
              ),
              Text(
                action,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                  color: isDark
                      ? AppColors.textPrimaryDark
                      : AppColors.textPrimaryLight,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PrimaryButton extends StatelessWidget {
  const _PrimaryButton({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 58,
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: AppColors.primaryGradient,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: AppColors.primaryHover.withValues(alpha: 0.35),
              blurRadius: 14,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(16),
            child: Center(
              child: Text(
                label,
                style: const TextStyle(
                  fontSize: 16.5,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimaryLight,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Yellow banner: booking requests are waiting for the driver's answer.
class _RequestsBanner extends StatelessWidget {
  const _RequestsBanner({required this.count, required this.onTap});

  final int count;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Semantics(
      button: true,
      liveRegion: true,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Ink(
            padding: const EdgeInsets.fromLTRB(14, 12, 10, 12),
            decoration: BoxDecoration(
              gradient: AppColors.primaryGradient,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                const Icon(Icons.notifications_active_rounded,
                    color: AppColors.textPrimaryLight),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    l10n.dpPendingBanner(count),
                    style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimaryLight),
                  ),
                ),
                Text(l10n.dpPendingAction,
                    style: const TextStyle(
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimaryLight)),
                const Icon(Icons.chevron_right_rounded,
                    color: AppColors.textPrimaryLight),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
