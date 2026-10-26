import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../core/config/pilot_route.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/localization/app_localizations_helper.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/widgets/app_menu_drawer.dart';
import '../../../../core/widgets/app_snackbar.dart';
import '../../../intercity_rides/domain/repositories/intercity_rides_repository.dart';

/// B2 — open today's pilot route with two choices: when and how much.
/// The car always has four seats.
class PilotOpenRoutePage extends StatefulWidget {
  const PilotOpenRoutePage({super.key, this.toCity, this.price});

  /// Preselected direction; defaults to "to the city" before noon.
  final bool? toCity;
  final int? price;

  @override
  State<PilotOpenRoutePage> createState() => _PilotOpenRoutePageState();
}

class _PilotOpenRoutePageState extends State<PilotOpenRoutePage> {
  static const _morning = ['06:30', '07:00', '07:30'];
  static const _evening = ['16:30', '17:00', '17:30'];

  late bool _toCity = widget.toCity ?? DateTime.now().hour < 12;
  late int _price = PilotRoute.seatPrices.contains(widget.price)
      ? widget.price!
      : PilotRoute.seatPrices[1];

  /// Index into the time chips; -1 = leave when the car is full.
  int _time = 1;
  bool _sending = false;

  List<String> get _times => _toCity ? _morning : _evening;

  DateTime _departure() {
    final now = DateTime.now();
    if (_time < 0) return now.add(const Duration(minutes: 30));
    final parts = _times[_time].split(':');
    var t = DateTime(now.year, now.month, now.day, int.parse(parts[0]),
        int.parse(parts[1]));
    if (t.isBefore(now)) t = now.add(const Duration(minutes: 15));
    return t;
  }

  Future<void> _open() async {
    HapticFeedback.mediumImpact();
    setState(() => _sending = true);
    final from = _toCity ? PilotRoute.districtCityId : PilotRoute.centerCityId;
    final to = _toCity ? PilotRoute.centerCityId : PilotRoute.districtCityId;
    try {
      final id = await sl<IntercityRidesRepository>().createRide({
        'from_city_id': from,
        'to_city_id': to,
        'departure_time': _departure().toUtc().toIso8601String(),
        'price_per_seat': _price,
        'total_seats': PilotRoute.seats,
        'allow_luggage': true,
      });
      try {
        final prefs = sl<SharedPreferences>();
        await prefs.setString('last_trip_from', from);
        await prefs.setString('last_trip_to', to);
        await prefs.setInt('last_trip_price', _price);
        await prefs.setInt('last_trip_seats', PilotRoute.seats);
      } catch (_) {}
      if (!mounted) return;
      context.pushReplacement('/pilot/ride/$id', extra: {'toCity': _toCity});
    } catch (_) {
      if (mounted) AppSnackBar.showError(context, context.l10n.dpActionFailed);
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final lang = Localizations.localeOf(context).languageCode;
    final from = _toCity ? PilotRoute.districtLatLng : PilotRoute.centerLatLng;
    final to = _toCity ? PilotRoute.centerLatLng : PilotRoute.districtLatLng;

    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: GoogleMap(
              initialCameraPosition: CameraPosition(
                target: LatLng((from.latitude + to.latitude) / 2,
                    (from.longitude + to.longitude) / 2),
                zoom: 10.4,
              ),
              style: isDark ? darkMapStyle : null,
              zoomControlsEnabled: false,
              mapToolbarEnabled: false,
              compassEnabled: false,
              padding: const EdgeInsets.only(bottom: 420),
              markers: {
                Marker(markerId: const MarkerId('from'), position: from),
                Marker(
                  markerId: const MarkerId('to'),
                  position: to,
                  icon: BitmapDescriptor.defaultMarkerWithHue(
                      BitmapDescriptor.hueOrange),
                ),
              },
              polylines: {
                Polyline(
                  polylineId: const PolylineId('route'),
                  points: [from, to],
                  color: AppColors.primaryHover,
                  width: 5,
                  patterns: [PatternItem.dash(18), PatternItem.gap(10)],
                ),
              },
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(14, 10, 14, 0),
              child: MapRoundButton(
                icon: Icons.arrow_back_rounded,
                tooltip: MaterialLocalizations.of(context).backButtonTooltip,
                onPressed: () => context.pop(),
              ),
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: PilotSheet(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  PilotSegmented(
                    left: l10n.dpToCity,
                    right: l10n.dpToHome,
                    leftSelected: _toCity,
                    onChanged: (v) => setState(() {
                      _toCity = v;
                      _time = 1;
                    }),
                  ),
                  const SizedBox(height: 14),
                  _Label(l10n.dpDepartureTime),
                  Row(
                    children: [
                      for (var i = 0; i < _times.length; i++) ...[
                        PilotChip(
                          label: _times[i],
                          selected: _time == i,
                          onTap: () => setState(() => _time = i),
                        ),
                        const SizedBox(width: 6),
                      ],
                      PilotChip(
                        label: l10n.dpWhenFull,
                        selected: _time < 0,
                        onTap: () => setState(() => _time = -1),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  _Label(l10n.dpPricePerSeat),
                  Row(
                    children: [
                      for (final p in PilotRoute.seatPrices) ...[
                        PilotChip(
                          label: AppCurrencyFormatter.formatShort(p,
                              locale: lang),
                          selected: _price == p,
                          onTap: () => setState(() => _price = p),
                        ),
                        if (p != PilotRoute.seatPrices.last)
                          const SizedBox(width: 6),
                      ],
                    ],
                  ),
                  const SizedBox(height: 14),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
                    decoration: BoxDecoration(
                      color: isDark
                          ? AppColors.surfaceSubtleDark
                          : AppColors.backgroundLight,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(l10n.dpFourSeats,
                              style: const TextStyle(fontSize: 13)),
                        ),
                        Text(
                          l10n.dpFullCarTotal(AppCurrencyFormatter.format(
                              _price * PilotRoute.seats,
                              locale: lang)),
                          style: const TextStyle(
                              fontSize: 13, fontWeight: FontWeight.w800),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),
                  PilotPrimaryButton(
                    label: l10n.dpOpen,
                    loading: _sending,
                    onPressed: _sending ? null : _open,
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

class _Label extends StatelessWidget {
  const _Label(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(text,
          style: const TextStyle(
              fontSize: 12.5,
              fontWeight: FontWeight.w700,
              color: AppColors.textSecondaryLight)),
    );
  }
}

/// White bottom panel over the map, shared by the pilot screens.
class PilotSheet extends StatelessWidget {
  const PilotSheet({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(26)),
        boxShadow: const [
          BoxShadow(
              color: Color(0x24000000), blurRadius: 24, offset: Offset(0, -6)),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
          child: AnimatedSize(
              duration: const Duration(milliseconds: 220), child: child),
        ),
      ),
    );
  }
}

class PilotChip extends StatelessWidget {
  const PilotChip({
    super.key,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Expanded(
      child: Semantics(
        button: true,
        selected: selected,
        child: GestureDetector(
          onTap: () {
            HapticFeedback.selectionClick();
            onTap();
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            height: 46,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: selected
                  ? AppColors.primaryLight
                  : (isDark
                      ? AppColors.surfaceSubtleDark
                      : AppColors.surfaceSubtleLight),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                  color: selected ? AppColors.primary : Colors.transparent,
                  width: 2),
            ),
            child: Text(label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w700,
                    color: selected ? AppColors.textPrimaryLight : null)),
          ),
        ),
      ),
    );
  }
}

class PilotSegmented extends StatelessWidget {
  const PilotSegmented({
    super.key,
    required this.left,
    required this.right,
    required this.leftSelected,
    required this.onChanged,
  });

  final String left;
  final String right;
  final bool leftSelected;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    Widget option(String text, bool selected, VoidCallback onTap) {
      return Expanded(
        child: Semantics(
          button: true,
          selected: selected,
          child: GestureDetector(
            onTap: onTap,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              padding: const EdgeInsets.symmetric(vertical: 11),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: selected
                    ? (isDark ? AppColors.surfaceDark : AppColors.surfaceLight)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(10),
                boxShadow: selected
                    ? const [
                        BoxShadow(
                            color: Color(0x1F000000),
                            blurRadius: 3,
                            offset: Offset(0, 1)),
                      ]
                    : null,
              ),
              child: Text(text,
                  style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: selected ? null : AppColors.textSecondaryLight)),
            ),
          ),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color:
            isDark ? AppColors.surfaceSubtleDark : AppColors.surfaceSubtleLight,
        borderRadius: BorderRadius.circular(13),
      ),
      child: Row(children: [
        option(left, leftSelected, () => onChanged(true)),
        const SizedBox(width: 4),
        option(right, !leftSelected, () => onChanged(false)),
      ]),
    );
  }
}

/// Yellow gradient call-to-action.
class PilotPrimaryButton extends StatelessWidget {
  const PilotPrimaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.loading = false,
    this.height = 56,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool loading;
  final double height;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
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
            onTap: onPressed,
            borderRadius: BorderRadius.circular(16),
            child: Center(
              child: loading
                  ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(
                          strokeWidth: 2.5, color: AppColors.textPrimaryLight))
                  : Text(label,
                      style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textPrimaryLight)),
            ),
          ),
        ),
      ),
    );
  }
}
