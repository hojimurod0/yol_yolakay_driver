import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../../../core/config/pilot_route.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/localization/app_localizations_helper.dart';
import '../../../../core/services/audio_alert_service.dart';
import '../../../../core/services/location_service.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/utils/direct_contact_launcher.dart';
import '../../../../core/utils/distance_calculator.dart';
import '../../../../core/utils/external_navigation_launcher.dart';
import '../../../../core/widgets/app_menu_drawer.dart';
import '../../../../core/widgets/app_snackbar.dart';
import '../../../../core/widgets/slide_to_confirm.dart';
import '../../../intercity_rides/domain/entities/intercity_ride_entity.dart';
import '../../../intercity_rides/domain/repositories/intercity_rides_repository.dart';
import 'pilot_open_route_page.dart';

/// B3–B6 for an open pilot ride: new requests one at a time, door-to-door
/// pickups in nearest-first order, the drive, and the return-trip offer.
class PilotActiveRidePage extends StatefulWidget {
  const PilotActiveRidePage({super.key, required this.rideId, this.toCity});

  final String rideId;
  final bool? toCity;

  /// Shortest time a request stays on screen, even when the phone's clock
  /// is ahead of the server's and the deadline looks already past.
  static const minOfferTime = Duration(seconds: 15);

  /// When a request leaves the screen: the server's deadline, kept within
  /// [minOfferTime]..[PilotRoute.answerWindow] of when it was first shown.
  /// The passenger app withdraws the request a little after this, so the
  /// driver cannot accept one that is about to be cancelled.
  static DateTime offerDeadline(RidePassengerEntity p, DateTime seenAt) {
    final earliest = seenAt.add(minOfferTime);
    final latest = seenAt.add(PilotRoute.answerWindow);
    final server = p.answerBy ?? latest;
    if (server.isBefore(earliest)) return earliest;
    if (server.isAfter(latest)) return latest;
    return server;
  }

  @override
  State<PilotActiveRidePage> createState() => _PilotActiveRidePageState();
}

class _PilotActiveRidePageState extends State<PilotActiveRidePage> {
  IntercityRideEntity? _ride;
  LatLng? _me;
  Timer? _poll;
  Timer? _tick;
  bool _busy = false;
  bool _finished = false;
  int _earned = 0;

  /// When each pending request was first shown, for the countdown.
  final Map<String, DateTime> _seenAt = {};

  IntercityRidesRepository get _repo => sl<IntercityRidesRepository>();

  bool get _toCity {
    if (widget.toCity != null) return widget.toCity!;
    final from = _ride?.fromCity.toLowerCase() ?? '';
    return from.contains('jala') || from.contains('жала');
  }

  LatLng get _destination =>
      _toCity ? PilotRoute.centerLatLng : PilotRoute.districtLatLng;

  @override
  void initState() {
    super.initState();
    _refresh();
    _poll = Timer.periodic(const Duration(seconds: 5), (_) => _refresh());
    _tick = Timer.periodic(const Duration(seconds: 1), (_) {
      // Any pending request, so an offer leaves the screen at its deadline.
      if (mounted && (_ride?.passengers.any((p) => p.isPending) ?? false)) {
        setState(() {});
      }
    });
  }

  @override
  void dispose() {
    _poll?.cancel();
    _tick?.cancel();
    super.dispose();
  }

  Future<void> _refresh() async {
    if (_finished) return;
    try {
      final pos = await sl<LocationService>().getCurrentPosition();
      final ride = await _repo.getRideDetails(widget.rideId);
      if (!mounted) return;
      final hadOffer = _pendingOffer;
      setState(() {
        if (pos != null) _me = LatLng(pos.latitude, pos.longitude);
        _ride = ride;
        for (final p in ride.passengers.where((p) => p.isPending)) {
          _seenAt.putIfAbsent(p.bookingId, DateTime.now);
        }
      });
      final offer = _pendingOffer;
      if (offer != null && offer.bookingId != hadOffer?.bookingId) {
        AudioAlertService.instance.playNewOrderAlert();
      }
      if (ride.status == 'completed' && !_finished) _markFinished(ride);
    } catch (_) {
      // Keep the last known state; the next tick retries.
    }
  }

  DateTime _deadline(RidePassengerEntity p) =>
      PilotActiveRidePage.offerDeadline(
          p, _seenAt[p.bookingId] ?? DateTime.now());

  /// The oldest request still open; ones past their deadline are left for
  /// the server (or the passenger app) to expire.
  RidePassengerEntity? get _pendingOffer {
    final now = DateTime.now();
    final pending = _ride?.passengers
            .where((p) => p.isPending && _deadline(p).isAfter(now))
            .toList() ??
        [];
    if (pending.isEmpty) return null;
    pending.sort((a, b) => _deadline(a).compareTo(_deadline(b)));
    return pending.first;
  }

  Duration _offerLeft(RidePassengerEntity p) {
    final left = _deadline(p).difference(DateTime.now());
    return left.isNegative ? Duration.zero : left;
  }

  double? _kmTo(RidePassengerEntity p) {
    if (_me == null || p.pickupLat == null || p.pickupLng == null) return null;
    return DistanceCalculator.calculateDistanceKm(
        lat1: _me!.latitude,
        lon1: _me!.longitude,
        lat2: p.pickupLat!,
        lon2: p.pickupLng!);
  }

  /// Confirmed passengers: already picked up first, then the rest in
  /// nearest-neighbour order from the driver's position.
  List<RidePassengerEntity> get _pickupOrder {
    final all = _ride?.passengers
            .where((p) => !p.isPending && !p.isRejectedOrCancelled)
            .toList() ??
        [];
    final done = all.where((p) => p.isPickedUp).toList();
    final todo = all.where((p) => !p.isPickedUp).toList();
    final ordered = <RidePassengerEntity>[];
    var from = _me;
    while (todo.isNotEmpty) {
      todo.sort((a, b) {
        double d(RidePassengerEntity p) =>
            from == null || p.pickupLat == null || p.pickupLng == null
                ? double.infinity
                : DistanceCalculator.calculateDistanceKm(
                    lat1: from.latitude,
                    lon1: from.longitude,
                    lat2: p.pickupLat!,
                    lon2: p.pickupLng!);
        return d(a).compareTo(d(b));
      });
      final next = todo.removeAt(0);
      ordered.add(next);
      if (next.pickupLat != null && next.pickupLng != null) {
        from = LatLng(next.pickupLat!, next.pickupLng!);
      }
    }
    return [...done, ...ordered];
  }

  int get _seatsTaken => (_ride?.passengers ?? const <RidePassengerEntity>[])
      .where((p) => !p.isPending && !p.isRejectedOrCancelled)
      .fold(0, (sum, p) => sum + p.seatsCount);

  Future<void> _run(Future<void> Function() action) async {
    setState(() => _busy = true);
    try {
      await action();
      await _refresh();
    } catch (_) {
      if (mounted) AppSnackBar.showError(context, context.l10n.dpActionFailed);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  void _markFinished(IntercityRideEntity ride) {
    _poll?.cancel();
    setState(() {
      _finished = true;
      _earned = ride.passengers
          .where((p) => !p.isPending && !p.isRejectedOrCancelled)
          .fold(0, (sum, p) => sum + p.totalPrice);
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final ride = _ride;
    final offer = _finished ? null : _pendingOffer;
    final order = _pickupOrder;

    final markers = <Marker>{
      if (offer?.pickupLat != null)
        Marker(
          markerId: const MarkerId('offer'),
          position: LatLng(offer!.pickupLat!, offer.pickupLng!),
          icon:
              BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure),
        ),
      if (offer == null)
        for (var i = 0; i < order.length; i++)
          if (order[i].pickupLat != null)
            Marker(
              markerId: MarkerId(order[i].bookingId),
              position: LatLng(order[i].pickupLat!, order[i].pickupLng!),
              infoWindow:
                  InfoWindow(title: '${i + 1}. ${order[i].passengerName}'),
              icon: BitmapDescriptor.defaultMarkerWithHue(order[i].isPickedUp
                  ? BitmapDescriptor.hueGreen
                  : BitmapDescriptor.hueYellow),
            ),
      if (ride?.status == 'started')
        Marker(
          markerId: const MarkerId('destination'),
          position: _destination,
          icon:
              BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueOrange),
        ),
    };

    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: GoogleMap(
              initialCameraPosition: CameraPosition(
                  target: _me ??
                      (_toCity
                          ? PilotRoute.districtLatLng
                          : PilotRoute.centerLatLng),
                  zoom: 14),
              style: isDark ? darkMapStyle : null,
              myLocationEnabled: _me != null,
              myLocationButtonEnabled: false,
              zoomControlsEnabled: false,
              mapToolbarEnabled: false,
              compassEnabled: false,
              padding: const EdgeInsets.only(bottom: 380),
              markers: markers,
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(14, 10, 14, 0),
              child: MapRoundButton(
                icon: Icons.arrow_back_rounded,
                tooltip: MaterialLocalizations.of(context).backButtonTooltip,
                onPressed: () => context.go('/driver/home'),
              ),
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: ride == null
                ? const PilotSheet(
                    child: Padding(
                      padding: EdgeInsets.symmetric(vertical: 40),
                      child: Center(child: CircularProgressIndicator()),
                    ),
                  )
                : offer != null
                    ? _OfferCard(
                        passenger: offer,
                        left: _offerLeft(offer),
                        km: _kmTo(offer),
                        seatsTaken: _seatsTaken,
                        totalSeats: ride.totalSeats,
                        busy: _busy,
                        onAccept: () => _run(() => _repo.handleBookingAction(
                            bookingId: offer.bookingId, action: 'accept')),
                        onSkip: () => _run(() => _repo.handleBookingAction(
                            bookingId: offer.bookingId,
                            action: 'reject',
                            rejectReason: 'driver_busy')),
                      )
                    : PilotSheet(child: _body(ride, order)),
          ),
        ],
      ),
    );
  }

  Widget _body(IntercityRideEntity ride, List<RidePassengerEntity> order) {
    final l10n = context.l10n;
    final lang = Localizations.localeOf(context).languageCode;

    if (_finished) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Icon(Icons.check_circle_rounded,
              size: 46, color: AppColors.success),
          const SizedBox(height: 8),
          Text(l10n.dpTripDone,
              textAlign: TextAlign.center,
              style:
                  const TextStyle(fontSize: 20, fontWeight: FontWeight.w900)),
          Text(
              l10n.dpEarned(AppCurrencyFormatter.format(_earned, locale: lang)),
              textAlign: TextAlign.center,
              style: const TextStyle(
                  fontSize: 14, color: AppColors.textSecondaryLight)),
          const SizedBox(height: 16),
          Text(l10n.dpReturnTitle,
              style:
                  const TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
          const SizedBox(height: 10),
          PilotPrimaryButton(
            label: l10n.dpOpenReturn,
            onPressed: () => context.pushReplacement('/pilot/open-route',
                extra: {'toCity': !_toCity, 'price': ride.pricePerSeat}),
          ),
          TextButton(
            onPressed: () => context.go('/driver/home'),
            child: Text(l10n.dpNotToday),
          ),
        ],
      );
    }

    if (ride.status == 'started') {
      final collected = order.fold<int>(0, (s, p) => s + p.totalPrice);
      return Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(l10n.dpOnTheWay.toUpperCase(),
                        style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFFB45309))),
                    Text(ride.toCity,
                        style: const TextStyle(
                            fontSize: 19, fontWeight: FontWeight.w900)),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(l10n.dpCollected,
                      style: const TextStyle(
                          fontSize: 12, color: AppColors.textSecondaryLight)),
                  Text(AppCurrencyFormatter.format(collected, locale: lang),
                      style: const TextStyle(
                          fontSize: 17, fontWeight: FontWeight.w900)),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          OutlinedButton.icon(
            onPressed: () => ExternalNavigationLauncher.showNavigationChooser(
                context,
                lat: _destination.latitude,
                lng: _destination.longitude,
                destinationTitle: ride.toCity),
            icon: const Icon(Icons.navigation_outlined),
            label: Text(l10n.dpOpenNavigator),
            style: OutlinedButton.styleFrom(
                minimumSize: const Size.fromHeight(48),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14))),
          ),
          const SizedBox(height: 12),
          SlideToConfirm(
            label: l10n.dpSlideArrived,
            enabled: !_busy,
            onConfirmed: () => _run(() async {
              await _repo.completeRide(ride.id);
              if (mounted) _markFinished(ride);
            }),
          ),
        ],
      );
    }

    // Before departure: pickups.
    final next = order.where((p) => !p.isPickedUp).firstOrNull;
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(l10n.dpPickupTitle,
                  style: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.w900)),
            ),
            Text(l10n.dpSeatsTaken(_seatsTaken, ride.totalSeats),
                style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFFB45309))),
          ],
        ),
        const SizedBox(height: 10),
        if (order.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 14),
            child: Text(l10n.dpNoPassengersYet,
                textAlign: TextAlign.center,
                style: const TextStyle(color: AppColors.textSecondaryLight)),
          )
        else
          ConstrainedBox(
            constraints: const BoxConstraints(maxHeight: 220),
            child: ListView(
              shrinkWrap: true,
              children: [
                for (var i = 0; i < order.length; i++)
                  _StopRow(
                    index: i + 1,
                    passenger: order[i],
                    isNext: identical(order[i], next),
                    km: _kmTo(order[i]),
                  ),
              ],
            ),
          ),
        const SizedBox(height: 12),
        if (next != null)
          SlideToConfirm(
            label: l10n.dpSlidePickedUp(next.passengerName),
            enabled: !_busy,
            onConfirmed: () => _run(() => _repo.markPickedUp(next.bookingId)),
          )
        else
          PilotPrimaryButton(
            label: l10n.dpDepart,
            loading: _busy,
            onPressed: order.isEmpty || _busy
                ? null
                : () {
                    HapticFeedback.mediumImpact();
                    _run(() => _repo.startRide(ride.id));
                  },
          ),
      ],
    );
  }
}

class _StopRow extends StatelessWidget {
  const _StopRow({
    required this.index,
    required this.passenger,
    required this.isNext,
    required this.km,
  });

  final int index;
  final RidePassengerEntity passenger;
  final bool isNext;
  final double? km;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final done = passenger.isPickedUp;
    final where = [
      if ((passenger.pickupAddress ?? '').isNotEmpty) passenger.pickupAddress!,
      if (done)
        l10n.dpPickedUp
      else if (km != null)
        km! < 1 ? '${(km! * 1000).round()} m' : '${km!.toStringAsFixed(1)} km',
    ].join(' · ');

    return Opacity(
      opacity: done ? 0.55 : 1,
      child: Container(
        margin: const EdgeInsets.only(bottom: 6),
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: isNext ? AppColors.primaryLight : Colors.transparent,
          borderRadius: BorderRadius.circular(14),
          border: isNext ? Border.all(color: AppColors.primary) : null,
        ),
        child: Row(
          children: [
            Container(
              width: 28,
              height: 28,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: done
                    ? AppColors.success
                    : isNext
                        ? AppColors.primary
                        : AppColors.surfaceSubtleLight,
              ),
              child: Text(done ? '✓' : '$index',
                  style: TextStyle(
                      fontWeight: FontWeight.w900,
                      fontSize: 12,
                      color: done ? Colors.white : AppColors.textPrimaryLight)),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${passenger.passengerName} · ${l10n.dpPeople(passenger.seatsCount)}',
                    style: const TextStyle(
                        fontSize: 14.5, fontWeight: FontWeight.w700),
                  ),
                  if (where.isNotEmpty)
                    Text(where,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                            fontSize: 12, color: AppColors.textSecondaryLight)),
                ],
              ),
            ),
            if (!done && passenger.passengerPhone.isNotEmpty)
              IconButton(
                tooltip: l10n.dpCall,
                onPressed: () => DirectContactLauncher.makePhoneCall(
                    context, passenger.passengerPhone),
                icon: const Icon(Icons.call_outlined),
              ),
          ],
        ),
      ),
    );
  }
}

/// B3 — one request at a time, Rizo GO style. The accept button doubles as
/// the countdown: its yellow fill shrinks as time runs out.
class _OfferCard extends StatelessWidget {
  const _OfferCard({
    required this.passenger,
    required this.left,
    required this.km,
    required this.seatsTaken,
    required this.totalSeats,
    required this.busy,
    required this.onAccept,
    required this.onSkip,
  });

  final RidePassengerEntity passenger;
  final Duration left;
  final double? km;
  final int seatsTaken;
  final int totalSeats;
  final bool busy;
  final VoidCallback onAccept;
  final VoidCallback onSkip;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final lang = Localizations.localeOf(context).languageCode;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final fraction =
        (left.inSeconds / PilotRoute.answerWindow.inSeconds).clamp(0.0, 1.0);
    final timer =
        '${left.inMinutes}:${(left.inSeconds % 60).toString().padLeft(2, '0')}';

    return SafeArea(
      top: false,
      child: Container(
        margin: const EdgeInsets.all(10),
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
        decoration: BoxDecoration(
          color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
          borderRadius: BorderRadius.circular(28),
          border: Border.all(color: AppColors.primary, width: 2),
          boxShadow: const [
            BoxShadow(
                color: Color(0x38000000),
                blurRadius: 30,
                offset: Offset(0, 10)),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: AppColors.primaryLight,
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(l10n.dpNewRequest,
                      style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w900,
                          color: Color(0xFF92400E))),
                ),
                const Spacer(),
                Text(timer,
                    style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w900,
                        color: Color(0xFFB45309))),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Expanded(
                  child: Text(
                    AppCurrencyFormatter.format(passenger.totalPrice,
                        locale: lang),
                    style: const TextStyle(
                        fontSize: 34,
                        fontWeight: FontWeight.w900,
                        height: 1,
                        letterSpacing: -0.8),
                  ),
                ),
                Text(l10n.dpPeople(passenger.seatsCount),
                    style: const TextStyle(
                        fontSize: 13, fontWeight: FontWeight.w700)),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                if (km != null)
                  Expanded(
                    child: _Fact(
                      value: km! < 1
                          ? '${(km! * 1000).round()} m'
                          : '${km!.toStringAsFixed(1)} km',
                      label: l10n.dpToPassenger,
                    ),
                  ),
                if (km != null) const SizedBox(width: 8),
                Expanded(
                  child: _Fact(
                    value: '${seatsTaken + passenger.seatsCount}/$totalSeats',
                    label: l10n.dpSeatsTaken(
                        seatsTaken + passenger.seatsCount, totalSeats),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                const Icon(Icons.person_pin_circle_outlined,
                    color: Color(0xFF2563EB)),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    [
                      passenger.passengerName,
                      if ((passenger.pickupAddress ?? '').isNotEmpty)
                        passenger.pickupAddress!,
                    ].join(' · '),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                        fontSize: 14.5, fontWeight: FontWeight.w700),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Semantics(
              button: true,
              label: l10n.dpAccept,
              child: GestureDetector(
                onTap: busy ? null : onAccept,
                child: Container(
                  height: 62,
                  clipBehavior: Clip.antiAlias,
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFE9A8),
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Stack(
                    children: [
                      FractionallySizedBox(
                        widthFactor: fraction.clamp(0.0, 1.0),
                        child: Container(
                            decoration: const BoxDecoration(
                                gradient: AppColors.primaryGradient)),
                      ),
                      Center(
                        child: busy
                            ? const SizedBox(
                                width: 22,
                                height: 22,
                                child: CircularProgressIndicator(
                                    strokeWidth: 2.5,
                                    color: AppColors.textPrimaryLight))
                            : Text(l10n.dpAccept,
                                style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w900,
                                    color: AppColors.textPrimaryLight)),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            TextButton(
              onPressed: busy ? null : onSkip,
              child: Text(l10n.dpSkip,
                  style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      color: AppColors.textSecondaryLight)),
            ),
          ],
        ),
      ),
    );
  }
}

class _Fact extends StatelessWidget {
  const _Fact({required this.value, required this.label});

  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceSubtleDark : AppColors.backgroundLight,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(value,
              style:
                  const TextStyle(fontSize: 18, fontWeight: FontWeight.w900)),
          Text(label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                  fontSize: 12, color: AppColors.textSecondaryLight)),
        ],
      ),
    );
  }
}
