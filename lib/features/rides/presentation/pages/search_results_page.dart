import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:go_router/go_router.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../../../core/config/google_maps_config.dart';
import '../../../../core/localization/app_localizations_helper.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/app_empty_state.dart';
import '../../../../core/widgets/app_loading.dart';
import '../providers/ride_search_provider.dart';
import '../widgets/ride_card.dart';
import '../widgets/ride_filter_sheet.dart';

class SearchResultsPage extends ConsumerStatefulWidget {
  const SearchResultsPage({super.key});

  @override
  ConsumerState<SearchResultsPage> createState() => _SearchResultsPageState();
}

class _SearchResultsPageState extends ConsumerState<SearchResultsPage> {
  GoogleMapController? _mapController;
  bool _isMapExpanded = false;
  MapType _mapType = MapType.normal;
  List<LatLng> _routePoints = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchRoadRoute();
    });
  }

  @override
  void dispose() {
    _mapController?.dispose();
    super.dispose();
  }

  Future<void> _fetchRoadRoute() async {
    final searchState = ref.read(rideSearchNotifierProvider);
    final from = searchState.departureCity;
    final to = searchState.destinationCity;
    if (from == null || to == null) return;

    try {
      final dio = Dio();
      final url = 'https://router.project-osrm.org/route/v1/driving/'
          '${from.longitude},${from.latitude};'
          '${to.longitude},${to.latitude}'
          '?overview=full&geometries=geojson';

      final response = await dio.get(
        url,
        options: Options(
          receiveTimeout: const Duration(seconds: 6),
          sendTimeout: const Duration(seconds: 6),
        ),
      );

      if (response.statusCode == 200 && response.data['routes'] != null) {
        final List routes = response.data['routes'];
        if (routes.isNotEmpty) {
          final List coords = routes.first['geometry']['coordinates'];
          final List<LatLng> points = coords.map<LatLng>((c) {
            final lng = (c[0] as num).toDouble();
            final lat = (c[1] as num).toDouble();
            return LatLng(lat, lng);
          }).toList();

          if (mounted && points.isNotEmpty) {
            setState(() => _routePoints = points);
            return;
          }
        }
      }
    } catch (_) {}

    // Fallback: connect cities directly if routing service fails
    if (mounted && _routePoints.isEmpty) {
      setState(() {
        _routePoints = [
          LatLng(from.latitude, from.longitude),
          LatLng(to.latitude, to.longitude),
        ];
      });
    }
  }

  void _onMapCreated(GoogleMapController controller) {
    _mapController = controller;
    _fitBounds();
  }

  Future<void> _goToUserLocation() async {
    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('GPS joylashuv ruxsati berilmadi'),
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
        return;
      }

      Position? position = await Geolocator.getLastKnownPosition();
      try {
        position ??= await Geolocator.getCurrentPosition(
          locationSettings: const LocationSettings(
            accuracy: LocationAccuracy.high,
            timeLimit: Duration(seconds: 5),
          ),
        );
      } catch (_) {
        position ??= await Geolocator.getLastKnownPosition();
      }

      if (position != null && _mapController != null) {
        _mapController?.animateCamera(
          CameraUpdate.newLatLngZoom(
            LatLng(position.latitude, position.longitude),
            14.5,
          ),
        );
      }
    } catch (_) {}
  }

  void _fitBounds() {
    final searchState = ref.read(rideSearchNotifierProvider);
    final from = searchState.departureCity;
    final to = searchState.destinationCity;

    if (from != null && to != null && _mapController != null) {
      double minLat = from.latitude < to.latitude ? from.latitude : to.latitude;
      double maxLat = from.latitude > to.latitude ? from.latitude : to.latitude;
      double minLng =
          from.longitude < to.longitude ? from.longitude : to.longitude;
      double maxLng =
          from.longitude > to.longitude ? from.longitude : to.longitude;

      // Prevent crash if departure and destination coordinates are identical
      if ((maxLat - minLat).abs() < 0.001) {
        minLat -= 0.01;
        maxLat += 0.01;
      }
      if ((maxLng - minLng).abs() < 0.001) {
        minLng -= 0.01;
        maxLng += 0.01;
      }

      final bounds = LatLngBounds(
        southwest: LatLng(minLat, minLng),
        northeast: LatLng(maxLat, maxLng),
      );

      try {
        _mapController?.animateCamera(
          CameraUpdate.newLatLngBounds(bounds, 65),
        );
      } catch (_) {
        final centerLat = (minLat + maxLat) / 2;
        final centerLng = (minLng + maxLng) / 2;
        _mapController?.animateCamera(
          CameraUpdate.newLatLngZoom(LatLng(centerLat, centerLng), 10.0),
        );
      }
    } else if (from != null && _mapController != null) {
      _mapController?.animateCamera(
        CameraUpdate.newLatLngZoom(LatLng(from.latitude, from.longitude), 12.0),
      );
    }
  }

  Set<Marker> _buildMarkers(RideSearchState searchState) {
    final Set<Marker> markers = {};
    final from = searchState.departureCity;
    final to = searchState.destinationCity;

    if (from != null) {
      markers.add(
        Marker(
          markerId: const MarkerId('departure_city_marker'),
          position: LatLng(from.latitude, from.longitude),
          icon:
              BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
          infoWindow: InfoWindow(
            title: from.nameUz,
            snippet: 'Jo\'nash shahri',
          ),
        ),
      );
    }

    if (to != null) {
      markers.add(
        Marker(
          markerId: const MarkerId('destination_city_marker'),
          position: LatLng(to.latitude, to.longitude),
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
          infoWindow: InfoWindow(
            title: to.nameUz,
            snippet: 'Borish manzili',
          ),
        ),
      );
    }

    // Add pickup point markers from filtered rides
    for (var ride in searchState.filteredRides) {
      if (ride.pickupPoints.isNotEmpty) {
        final pt = ride.pickupPoints.first;
        markers.add(
          Marker(
            markerId: MarkerId('ride_${ride.id}_pickup'),
            position: LatLng(pt.latitude, pt.longitude),
            icon: BitmapDescriptor.defaultMarkerWithHue(
                BitmapDescriptor.hueAzure),
            infoWindow: InfoWindow(
              title: ride.driver.name,
              snippet: '${ride.vehicle.model} • ${ride.pricePerSeat} UZS',
            ),
          ),
        );
      }
    }

    return markers;
  }

  Set<Polyline> _buildPolylines(RideSearchState searchState) {
    final from = searchState.departureCity;
    final to = searchState.destinationCity;

    if (from == null || to == null) return {};

    final points = _routePoints.isNotEmpty
        ? _routePoints
        : [
            LatLng(from.latitude, from.longitude),
            LatLng(to.latitude, to.longitude),
          ];

    return {
      Polyline(
        polylineId: const PolylineId('intercity_route_polyline'),
        points: points,
        color: const Color(0xFF0066FF),
        width: 5,
        startCap: Cap.roundCap,
        endCap: Cap.roundCap,
        jointType: JointType.round,
      ),
    };
  }

  void _showFilterModal(BuildContext context) {
    final searchState = ref.read(rideSearchNotifierProvider);
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return RideFilterSheet(
          initialFilter: searchState.filter,
          onApply: (newFilter) {
            ref
                .read(rideSearchNotifierProvider.notifier)
                .applyFilter(newFilter);
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final l10n = context.l10n;
    final localeCode = Localizations.localeOf(context).languageCode;
    final searchState = ref.watch(rideSearchNotifierProvider);
    final rides = searchState.filteredRides;

    final defaultFrom = localeCode == 'ru' ? 'Ташкент' : 'Toshkent';
    final defaultTo = localeCode == 'ru' ? 'Самарканд' : 'Samarqand';
    final fromCityName =
        searchState.departureCity?.localizedName(localeCode) ?? defaultFrom;
    final toCityName =
        searchState.destinationCity?.localizedName(localeCode) ?? defaultTo;

    final fromLat =
        searchState.departureCity?.latitude ?? GoogleMapsConfig.defaultLat;
    final fromLng =
        searchState.departureCity?.longitude ?? GoogleMapsConfig.defaultLng;

    final initialCameraPosition = CameraPosition(
      target: LatLng(fromLat, fromLng),
      zoom: 11.5,
    );

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              '$fromCityName ➔ $toCityName',
              style: TextStyle(
                fontWeight: FontWeight.w800,
                fontSize: 14,
                color: isDark ? Colors.white : AppColors.textPrimaryLight,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
            ),
            const SizedBox(height: 2),
            Text(
              l10n.ridesFound(rides.length),
              style: TextStyle(
                color: isDark ? AppColors.taxiYellow : AppColors.taxiYellowDark,
                fontSize: 11.5,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.tune_rounded),
            onPressed: () => _showFilterModal(context),
          ),
        ],
      ),
      body: Column(
        children: [
          // 1. Embedded Interactive Google Maps Widget
          AnimatedContainer(
            duration: const Duration(milliseconds: 280),
            curve: Curves.easeInOutCubic,
            height: _isMapExpanded ? 460 : 265,
            width: double.infinity,
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: isDark
                      ? const Color(0xFF282832)
                      : const Color(0xFFE2E4E9),
                ),
              ),
            ),
            child: Stack(
              children: [
                GoogleMap(
                  initialCameraPosition: initialCameraPosition,
                  mapType: _mapType,
                  myLocationEnabled: true,
                  myLocationButtonEnabled: false,
                  zoomControlsEnabled: false,
                  compassEnabled: false,
                  markers: _buildMarkers(searchState),
                  polylines: _buildPolylines(searchState),
                  onMapCreated: _onMapCreated,
                ),

                // Floating Map Controls (GPS, Recenter, Satellite, Expand/Collapse)
                Positioned(
                  right: 12,
                  bottom: 12,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // GPS My Location button
                      Material(
                        color: isDark ? AppColors.yandexDarkCard : Colors.white,
                        borderRadius: BorderRadius.circular(10),
                        elevation: 3,
                        child: InkWell(
                          onTap: _goToUserLocation,
                          borderRadius: BorderRadius.circular(10),
                          child: const Padding(
                            padding: EdgeInsets.all(7),
                            child: Icon(Icons.my_location_rounded,
                                size: 18, color: Color(0xFF0066FF)),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),

                      // Re-center button (Fit entire route)
                      Material(
                        color: isDark ? AppColors.yandexDarkCard : Colors.white,
                        borderRadius: BorderRadius.circular(10),
                        elevation: 3,
                        child: InkWell(
                          onTap: _fitBounds,
                          borderRadius: BorderRadius.circular(10),
                          child: const Padding(
                            padding: EdgeInsets.all(7),
                            child: Icon(Icons.center_focus_strong_rounded,
                                size: 18),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),

                      // Satellite switch
                      Material(
                        color: isDark ? AppColors.yandexDarkCard : Colors.white,
                        borderRadius: BorderRadius.circular(10),
                        elevation: 3,
                        child: InkWell(
                          onTap: () {
                            setState(() {
                              _mapType = _mapType == MapType.normal
                                  ? MapType.satellite
                                  : MapType.normal;
                            });
                          },
                          borderRadius: BorderRadius.circular(10),
                          child: Padding(
                            padding: const EdgeInsets.all(7),
                            child: Icon(
                              _mapType == MapType.normal
                                  ? Icons.satellite_alt_rounded
                                  : Icons.map_rounded,
                              size: 18,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),

                      // Expand / Collapse map toggle
                      Material(
                        color: AppColors.yandexYellow,
                        borderRadius: BorderRadius.circular(10),
                        elevation: 3,
                        child: InkWell(
                          onTap: () {
                            setState(() => _isMapExpanded = !_isMapExpanded);
                            Future.delayed(
                                const Duration(milliseconds: 320), _fitBounds);
                          },
                          borderRadius: BorderRadius.circular(10),
                          child: Padding(
                            padding: const EdgeInsets.all(7),
                            child: Icon(
                              _isMapExpanded
                                  ? Icons.unfold_less_rounded
                                  : Icons.unfold_more_rounded,
                              size: 18,
                              color: AppColors.yandexBlack,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Top Left Route Info Chip
                Positioned(
                  left: 12,
                  top: 12,
                  right: 12,
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color:
                          (isDark ? AppColors.yandexDarkSurface : Colors.white)
                              .withValues(alpha: 0.95),
                      borderRadius: AppRadius.borderPill,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.15),
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.directions_car_filled_rounded,
                            size: 15, color: AppColors.primary),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            '$fromCityName ➔ $toCityName',
                            style: AppTypography.labelSmall.copyWith(
                              fontWeight: FontWeight.w800,
                              fontSize: 11.5,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          // 2. Rides List Content
          Expanded(
            child: searchState.isLoading
                ? ListView.builder(
                    physics: const NeverScrollableScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(
                      AppSpacing.md,
                      AppSpacing.md,
                      AppSpacing.md,
                      AppSpacing.xl,
                    ),
                    itemCount: 4,
                    itemBuilder: (_, __) => const AppSkeletonRideCard(),
                  )
                : rides.isEmpty
                    ? AppEmptyState(
                        icon: Icons.search_off_rounded,
                        title: l10n.noRidesFound,
                        description: l10n.noRidesDesc,
                        actionText: l10n.back,
                        onAction: () => context.pop(),
                      )
                    : ListView.builder(
                        physics: const BouncingScrollPhysics(),
                        padding: const EdgeInsets.fromLTRB(
                          AppSpacing.md,
                          AppSpacing.md,
                          AppSpacing.md,
                          AppSpacing.xl,
                        ),
                        itemCount: rides.length,
                        itemBuilder: (context, index) {
                          final ride = rides[index];
                          return RideCard(
                            ride: ride,
                            onTap: () =>
                                context.push('/ride/${ride.id}', extra: ride),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }
}
