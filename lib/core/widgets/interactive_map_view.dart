import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../localization/app_localizations_helper.dart';
import '../providers/core_providers.dart';
import '../theme/app_colors.dart';
import '../theme/app_radius.dart';
import '../theme/app_shadows.dart';
import '../theme/app_spacing.dart';
import '../theme/app_typography.dart';
import '../../features/home/domain/entities/city_entity.dart';

/// High-fidelity, interactive Google & Satellite Map view for all of Uzbekistan.
class InteractiveMapView extends ConsumerStatefulWidget {
  const InteractiveMapView({
    super.key,
    required this.cities,
    this.selectedCity,
    this.departureCity,
    this.destinationCity,
    this.onCitySelected,
    this.onLocationPicked,
    this.isSelectionMode = true,
    this.height,
  });

  final List<CityEntity> cities;
  final CityEntity? selectedCity;
  final CityEntity? departureCity;
  final CityEntity? destinationCity;
  final ValueChanged<CityEntity>? onCitySelected;
  final ValueChanged<CityEntity>? onLocationPicked;
  final bool isSelectionMode;
  final double? height;

  @override
  ConsumerState<InteractiveMapView> createState() => _InteractiveMapViewState();
}

class _InteractiveMapViewState extends ConsumerState<InteractiveMapView>
    with SingleTickerProviderStateMixin {
  late TransformationController _transformController;
  late AnimationController _pulseController;

  CityEntity? _activeSelectedCity;
  double _zoomLevel = 1.0;
  bool _isSatelliteMode =
      true; // Default to Satellite mode as requested by user

  // Geographic bounds for the entirety of Uzbekistan
  // Lat: ~37.0 (Termez) to 44.5 (Karakalpakstan)
  // Lng: ~56.0 (Ustyurt/Khorezm) to 73.5 (Khanabad/Andijan)
  static const double minLat = 37.0;
  static const double maxLat = 44.5;
  static const double minLng = 56.0;
  static const double maxLng = 73.5;

  @override
  void initState() {
    super.initState();
    _transformController = TransformationController();
    _activeSelectedCity = widget.selectedCity ?? widget.departureCity;

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat(reverse: true);
  }

  @override
  void didUpdateWidget(covariant InteractiveMapView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.selectedCity != oldWidget.selectedCity) {
      setState(() {
        _activeSelectedCity = widget.selectedCity;
      });
    }
  }

  @override
  void dispose() {
    _transformController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  Offset _geoToMapOffset(double lat, double lng, Size mapSize) {
    final double normX = ((lng - minLng) / (maxLng - minLng)).clamp(0.0, 1.0);
    // Invert Y because latitude increases North, whereas screen Y increases Downward
    final double normY =
        (1.0 - ((lat - minLat) / (maxLat - minLat))).clamp(0.0, 1.0);

    return Offset(
      normX * mapSize.width,
      normY * mapSize.height,
    );
  }

  void _zoomIn() {
    setState(() {
      _zoomLevel = (_zoomLevel * 1.3).clamp(0.7, 4.0);
      _transformController.value =
          Matrix4.diagonal3Values(_zoomLevel, _zoomLevel, 1.0);
    });
  }

  void _zoomOut() {
    setState(() {
      _zoomLevel = (_zoomLevel / 1.3).clamp(0.7, 4.0);
      _transformController.value =
          Matrix4.diagonal3Values(_zoomLevel, _zoomLevel, 1.0);
    });
  }

  void _focusRegion(double lat, double lng, Size mapSize) {
    final target = _geoToMapOffset(lat, lng, mapSize);
    setState(() {
      _zoomLevel = 2.2;
      final Matrix4 m = Matrix4.identity()
        ..scaleByDouble(_zoomLevel, _zoomLevel, 1.0, 1.0)
        ..translateByDouble(
          -target.dx + (mapSize.width / (2 * _zoomLevel)),
          -target.dy + (mapSize.height / (2 * _zoomLevel)),
          0.0,
          1.0,
        );
      _transformController.value = m;
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final l10n = context.l10n;
    final locale = ref.watch(localeNotifierProvider);

    return LayoutBuilder(
      builder: (context, constraints) {
        final double width = constraints.maxWidth;
        final double height = widget.height ?? constraints.maxHeight;
        // Large canvas allowing seamless panning and zooming across Uzbekistan
        final mapSize = Size(width * 1.8, height * 1.8);

        return ClipRRect(
          borderRadius: AppRadius.borderLg,
          child: Container(
            width: width,
            height: height,
            color: _isSatelliteMode
                ? const Color(0xFF0D131F)
                : (isDark ? const Color(0xFF1B222C) : const Color(0xFFE8EEF5)),
            child: Stack(
              children: [
                // Interactive Zoom/Pan Canvas
                InteractiveViewer(
                  transformationController: _transformController,
                  boundaryMargin: const EdgeInsets.all(350),
                  minScale: 0.7,
                  maxScale: 4.0,
                  child: SizedBox(
                    width: mapSize.width,
                    height: mapSize.height,
                    child: Stack(
                      children: [
                        // Stylized Map Background & Highway Network (Cached on GPU)
                        RepaintBoundary(
                          child: CustomPaint(
                            size: mapSize,
                            isComplex: true,
                            willChange: false,
                            painter: _UzbekistanMapPainter(
                              isDark: isDark,
                              isSatellite: _isSatelliteMode,
                              cities: widget.cities,
                              departureCity: widget.departureCity,
                              destinationCity: widget.destinationCity,
                              toOffset: (lat, lng) =>
                                  _geoToMapOffset(lat, lng, mapSize),
                            ),
                          ),
                        ),

                        // City Pins & Markers Layer (Isolated)
                        RepaintBoundary(
                          child: Stack(
                            children: widget.cities.map((city) {
                              final pos = _geoToMapOffset(
                                  city.latitude, city.longitude, mapSize);
                              final isSelected =
                                  _activeSelectedCity?.id == city.id;
                              final isDeparture =
                                  widget.departureCity?.id == city.id;
                              final isDestination =
                                  widget.destinationCity?.id == city.id;

                              return Positioned(
                                left: pos.dx - 24,
                                top: pos.dy - 36,
                                child: GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      _activeSelectedCity = city;
                                    });
                                    widget.onCitySelected?.call(city);
                                  },
                                  child: _CityPinMarker(
                                    city: city,
                                    localeCode: locale.languageCode,
                                    isSelected: isSelected ||
                                        isDeparture ||
                                        isDestination,
                                    isDeparture: isDeparture,
                                    isDestination: isDestination,
                                    isSatellite: _isSatelliteMode,
                                    pulseAnimation: _pulseController,
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Top Map HUD Controls: Satellite Toggle & Compass
                Positioned(
                  top: AppSpacing.sm,
                  left: AppSpacing.sm,
                  right: AppSpacing.sm,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Satellite / Standard Toggle Button
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 4, vertical: 4),
                        decoration: BoxDecoration(
                          color: (_isSatelliteMode || isDark
                                  ? const Color(0xFF1E293B)
                                  : Colors.white)
                              .withValues(alpha: 0.92),
                          borderRadius: AppRadius.borderPill,
                          border: Border.all(
                            color: isDark
                                ? AppColors.borderDark
                                : AppColors.borderLight,
                          ),
                          boxShadow: isDark ? AppShadows.darkMd : AppShadows.sm,
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            _buildModeButton(
                              icon: Icons.satellite_alt_rounded,
                              label: l10n.satelliteMode,
                              isActive: _isSatelliteMode,
                              onTap: () =>
                                  setState(() => _isSatelliteMode = true),
                            ),
                            _buildModeButton(
                              icon: Icons.map_outlined,
                              label: l10n.standardMode,
                              isActive: !_isSatelliteMode,
                              onTap: () =>
                                  setState(() => _isSatelliteMode = false),
                            ),
                          ],
                        ),
                      ),

                      // My Location GPS Focus Button
                      Container(
                        decoration: BoxDecoration(
                          color:
                              (isDark ? const Color(0xFF1E293B) : Colors.white)
                                  .withValues(alpha: 0.92),
                          shape: BoxShape.circle,
                          boxShadow: isDark ? AppShadows.darkMd : AppShadows.sm,
                        ),
                        child: IconButton(
                          icon: const Icon(Icons.my_location_rounded, size: 18),
                          color: AppColors.primary,
                          tooltip: 'Joriy GPS joylashuv (Andijon / Farg\'ona)',
                          onPressed: () =>
                              _focusRegion(40.7821, 72.3442, mapSize),
                        ),
                      ),
                    ],
                  ),
                ),

                // Fast Regional Quick-Jump Chips (Toshkent, Farg'ona, Samarqand, Buxoro, Xorazm, Termiz)
                Positioned(
                  top: 54,
                  left: AppSpacing.sm,
                  right: AppSpacing.sm,
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        _buildRegionJumpChip(
                          label: '📍 Andijon (Markaz)',
                          onTap: () => _focusRegion(40.7821, 72.3442, mapSize),
                        ),
                        const SizedBox(width: 6),
                        _buildRegionJumpChip(
                          label: '📍 Qo\'qon shahri',
                          onTap: () => _focusRegion(40.5286, 70.9425, mapSize),
                        ),
                        const SizedBox(width: 6),
                        _buildRegionJumpChip(
                          label: '📍 Farg\'ona (Markaz)',
                          onTap: () => _focusRegion(40.3864, 71.7864, mapSize),
                        ),
                        const SizedBox(width: 6),
                        _buildRegionJumpChip(
                          label: '📍 Jalaquduq',
                          onTap: () => _focusRegion(40.7167, 72.6333, mapSize),
                        ),
                        const SizedBox(width: 6),
                        _buildRegionJumpChip(
                          label: '📍 Asaka',
                          onTap: () => _focusRegion(40.6417, 72.2389, mapSize),
                        ),
                        const SizedBox(width: 6),
                        _buildRegionJumpChip(
                          label: '📍 Marg\'ilon',
                          onTap: () => _focusRegion(40.4722, 71.7139, mapSize),
                        ),
                        const SizedBox(width: 6),
                        _buildRegionJumpChip(
                          label: '📍 Shahrixon',
                          onTap: () => _focusRegion(40.7111, 72.0556, mapSize),
                        ),
                        const SizedBox(width: 6),
                        _buildRegionJumpChip(
                          label: '📍 Namangan',
                          onTap: () => _focusRegion(40.9983, 71.6726, mapSize),
                        ),
                      ],
                    ),
                  ),
                ),

                // Zoom In / Out Floating Controls on the right
                Positioned(
                  right: AppSpacing.sm,
                  bottom: _activeSelectedCity != null ? 140 : AppSpacing.sm,
                  child: Container(
                    decoration: BoxDecoration(
                      color: (isDark ? const Color(0xFF1E293B) : Colors.white)
                          .withValues(alpha: 0.92),
                      borderRadius: AppRadius.borderMd,
                      border: Border.all(
                        color: isDark
                            ? AppColors.borderDark
                            : AppColors.borderLight,
                      ),
                      boxShadow: isDark ? AppShadows.darkMd : AppShadows.sm,
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.add_rounded, size: 20),
                          color: AppColors.primary,
                          onPressed: _zoomIn,
                        ),
                        Divider(
                          height: 1,
                          color: isDark
                              ? AppColors.borderDark
                              : AppColors.borderLight,
                        ),
                        IconButton(
                          icon: const Icon(Icons.remove_rounded, size: 20),
                          color: AppColors.primary,
                          onPressed: _zoomOut,
                        ),
                      ],
                    ),
                  ),
                ),

                // Bottom Floating Selected Location Card
                if (_activeSelectedCity != null)
                  Positioned(
                    left: AppSpacing.md,
                    right: AppSpacing.md,
                    bottom: AppSpacing.md,
                    child: Container(
                      padding: const EdgeInsets.all(AppSpacing.md),
                      decoration: BoxDecoration(
                        color: (isDark ? const Color(0xFF1A2230) : Colors.white)
                            .withValues(alpha: 0.96),
                        borderRadius: AppRadius.borderLg,
                        border: Border.all(
                          color: AppColors.primary.withValues(alpha: 0.4),
                          width: 1.5,
                        ),
                        boxShadow: isDark ? AppShadows.darkMd : AppShadows.md,
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: const BoxDecoration(
                              gradient: AppColors.primaryGradient,
                              borderRadius: AppRadius.borderMd,
                            ),
                            child: const Icon(
                              Icons.location_on_rounded,
                              color: Colors.white,
                              size: 22,
                            ),
                          ),
                          const SizedBox(width: AppSpacing.md),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  _activeSelectedCity!
                                      .localizedName(locale.languageCode),
                                  style: AppTypography.titleMedium.copyWith(
                                    fontWeight: FontWeight.w800,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  '${_activeSelectedCity!.region} • GPS ${_activeSelectedCity!.latitude.toStringAsFixed(3)}, ${_activeSelectedCity!.longitude.toStringAsFixed(3)}',
                                  style: AppTypography.bodySmall.copyWith(
                                    color: isDark
                                        ? AppColors.textSecondaryDark
                                        : AppColors.textSecondaryLight,
                                    fontSize: 11,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: AppSpacing.sm),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(
                                horizontal: AppSpacing.md,
                                vertical: 10,
                              ),
                              shape: const RoundedRectangleBorder(
                                borderRadius: AppRadius.borderMd,
                              ),
                            ),
                            onPressed: () {
                              widget.onLocationPicked
                                  ?.call(_activeSelectedCity!);
                            },
                            child: Text(
                              l10n.confirm,
                              style:
                                  const TextStyle(fontWeight: FontWeight.w700),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildModeButton({
    required IconData icon,
    required String label,
    required bool isActive,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: AppRadius.borderPill,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: isActive ? AppColors.primary : Colors.transparent,
          borderRadius: AppRadius.borderPill,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 14,
              color: isActive ? Colors.white : AppColors.primary,
            ),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: isActive ? Colors.white : AppColors.textSecondaryLight,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRegionJumpChip({
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: AppRadius.borderPill,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: const Color(0xFF0F172A).withValues(alpha: 0.85),
          borderRadius: AppRadius.borderPill,
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.15),
          ),
        ),
        child: Text(
          label,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 11,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}

/// Custom Pin Marker with Glowing Animated Halo & Region Localized Label
class _CityPinMarker extends StatelessWidget {
  const _CityPinMarker({
    required this.city,
    required this.localeCode,
    required this.isSelected,
    required this.isDeparture,
    required this.isDestination,
    required this.isSatellite,
    required this.pulseAnimation,
  });

  final CityEntity city;
  final String localeCode;
  final bool isSelected;
  final bool isDeparture;
  final bool isDestination;
  final bool isSatellite;
  final Animation<double> pulseAnimation;

  @override
  Widget build(BuildContext context) {
    Color mainColor = AppColors.primary;
    if (isDeparture) {
      mainColor = AppColors.success;
    } else if (isDestination) {
      mainColor = AppColors.accentRose;
    } else if (city.isPopular) {
      mainColor = const Color(0xFF3B82F6);
    } else {
      mainColor = const Color(0xFF64748B);
    }

    final displayName = city.localizedName(localeCode).split('-').first.trim();

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Label pill
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
          decoration: BoxDecoration(
            color: isSelected
                ? mainColor
                : (isSatellite
                    ? const Color(0xDD0F172A)
                    : const Color(0xDD1E293B)),
            borderRadius: BorderRadius.circular(4),
            border: Border.all(
              color: isSelected ? Colors.white : Colors.white24,
              width: 1,
            ),
            boxShadow: const [
              BoxShadow(
                color: Colors.black45,
                blurRadius: 4,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: Text(
            displayName,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 10,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        const SizedBox(height: 2),

        // Pin icon with animated pulse halo
        AnimatedBuilder(
          animation: pulseAnimation,
          builder: (context, child) {
            return Stack(
              alignment: Alignment.center,
              children: [
                if (isSelected)
                  Container(
                    width: 28 + (pulseAnimation.value * 10),
                    height: 28 + (pulseAnimation.value * 10),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: mainColor.withValues(
                          alpha: 0.4 - (pulseAnimation.value * 0.2)),
                    ),
                  ),
                Container(
                  width: isSelected ? 24 : 18,
                  height: isSelected ? 24 : 18,
                  decoration: BoxDecoration(
                    color: mainColor,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.black45,
                        blurRadius: 4,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Icon(
                    isDeparture
                        ? Icons.trip_origin_rounded
                        : (isDestination ? Icons.flag_rounded : Icons.circle),
                    size: isSelected ? 12 : 8,
                    color: Colors.white,
                  ),
                ),
              ],
            );
          },
        ),
      ],
    );
  }
}

/// Canvas Painter rendering Satellite / Vector roads across the whole of Uzbekistan
class _UzbekistanMapPainter extends CustomPainter {
  _UzbekistanMapPainter({
    required this.isDark,
    required this.isSatellite,
    required this.cities,
    this.departureCity,
    this.destinationCity,
    required this.toOffset,
  });

  final bool isDark;
  final bool isSatellite;
  final List<CityEntity> cities;
  final CityEntity? departureCity;
  final CityEntity? destinationCity;
  final Offset Function(double lat, double lng) toOffset;

  @override
  void paint(Canvas canvas, Size size) {
    // 1. Satellite Cosmic / Earth Terrain Grid
    if (isSatellite) {
      final terrainPaint = Paint()
        ..color = const Color(0xFF1E293B).withValues(alpha: 0.12)
        ..strokeWidth = 1.0;

      const double gridStep = 45.0;
      for (double x = 0; x < size.width; x += gridStep) {
        canvas.drawLine(Offset(x, 0), Offset(x, size.height), terrainPaint);
      }
      for (double y = 0; y < size.height; y += gridStep) {
        canvas.drawLine(Offset(0, y), Offset(size.width, y), terrainPaint);
      }

      // Draw stylized Amudaryo & Sirdaryo Rivers
      final riverPaint = Paint()
        ..color = const Color(0xFF0284C7).withValues(alpha: 0.25)
        ..strokeWidth = 4.0
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round;

      _drawHighway(
          canvas, 'surxondaryo_termez', 'qashqadaryo_qarshi', riverPaint);
      _drawHighway(canvas, 'xorazm_urganch', 'qoraqalpoq_nukus', riverPaint);
      _drawHighway(canvas, 'qoraqalpoq_nukus', 'qoraqalpoq_moynoq', riverPaint);
    } else {
      final gridPaint = Paint()
        ..color = isDark
            ? Colors.white.withValues(alpha: 0.04)
            : Colors.black.withValues(alpha: 0.04)
        ..strokeWidth = 1.0;

      const double step = 60.0;
      for (double x = 0; x < size.width; x += step) {
        canvas.drawLine(Offset(x, 0), Offset(x, size.height), gridPaint);
      }
      for (double y = 0; y < size.height; y += step) {
        canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
      }
    }

    // 2. Arterial Intercity Highway Network across Uzbekistan
    final highwayPaint = Paint()
      ..color = isSatellite
          ? const Color(0xFF38BDF8).withValues(alpha: 0.4)
          : (isDark ? const Color(0xFF334155) : const Color(0xFFCBD5E1))
      ..strokeWidth = isSatellite ? 3.0 : 3.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final secondaryRoadPaint = Paint()
      ..color = isSatellite
          ? const Color(0xFF94A3B8).withValues(alpha: 0.25)
          : (isDark ? const Color(0xFF475569) : const Color(0xFF94A3B8))
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke;

    // Major M39 & A373 Arteries:
    // Tashkent <-> Fergana Valley (Kamchik pass)
    _drawHighway(canvas, 'tashkent_markaz', 'tashkent_angren', highwayPaint);
    _drawHighway(canvas, 'tashkent_angren', 'namangan_pop', highwayPaint);
    _drawHighway(canvas, 'namangan_pop', 'fergana_qoqon', highwayPaint);
    _drawHighway(canvas, 'fergana_qoqon', 'fergana_margilon', highwayPaint);
    _drawHighway(canvas, 'fergana_margilon', 'fergana_markaz', highwayPaint);
    _drawHighway(canvas, 'fergana_markaz', 'andijan_shahrixon', highwayPaint);
    _drawHighway(canvas, 'andijan_shahrixon', 'andijan_markaz', highwayPaint);
    _drawHighway(canvas, 'andijan_markaz', 'andijan_asaka', highwayPaint);
    _drawHighway(
        canvas, 'andijan_markaz', 'andijan_xonobod', secondaryRoadPaint);
    _drawHighway(canvas, 'namangan_pop', 'namangan_markaz', secondaryRoadPaint);
    _drawHighway(
        canvas, 'namangan_markaz', 'andijan_markaz', secondaryRoadPaint);

    // Tashkent <-> Syrdarya <-> Jizzakh <-> Samarkand
    _drawHighway(canvas, 'tashkent_markaz', 'sirdaryo_guliston', highwayPaint);
    _drawHighway(canvas, 'sirdaryo_guliston', 'jizzax_markaz', highwayPaint);
    _drawHighway(canvas, 'jizzax_markaz', 'samarkand_markaz', highwayPaint);
    _drawHighway(canvas, 'jizzax_markaz', 'jizzax_zomin', secondaryRoadPaint);

    // Samarkand <-> Navoi <-> Bukhara
    _drawHighway(canvas, 'samarkand_markaz', 'navoiy_markaz', highwayPaint);
    _drawHighway(canvas, 'navoiy_markaz', 'bukhara_markaz', highwayPaint);
    _drawHighway(
        canvas, 'samarkand_markaz', 'samarkand_urgut', secondaryRoadPaint);
    _drawHighway(
        canvas, 'bukhara_markaz', 'bukhara_gijduvon', secondaryRoadPaint);

    // Samarkand <-> Shahrisabz <-> Karshi <-> Termez
    _drawHighway(
        canvas, 'samarkand_markaz', 'qashqadaryo_shahrisabz', highwayPaint);
    _drawHighway(
        canvas, 'qashqadaryo_shahrisabz', 'qashqadaryo_qarshi', highwayPaint);
    _drawHighway(
        canvas, 'qashqadaryo_qarshi', 'surxondaryo_termez', highwayPaint);
    _drawHighway(
        canvas, 'surxondaryo_termez', 'surxondaryo_denov', secondaryRoadPaint);

    // Bukhara <-> Khorezm (Urgench, Khiva) <-> Karakalpakstan (Nukus, Moynaq)
    _drawHighway(canvas, 'bukhara_markaz', 'xorazm_urganch', highwayPaint);
    _drawHighway(canvas, 'xorazm_urganch', 'xorazm_xiva', secondaryRoadPaint);
    _drawHighway(canvas, 'xorazm_urganch', 'qoraqalpoq_nukus', highwayPaint);
    _drawHighway(
        canvas, 'qoraqalpoq_nukus', 'qoraqalpoq_moynoq', secondaryRoadPaint);

    // 3. Highlight Selected Route Polyline if both Departure and Destination exist
    if (departureCity != null &&
        destinationCity != null &&
        departureCity!.id != destinationCity!.id) {
      final start = toOffset(departureCity!.latitude, departureCity!.longitude);
      final end =
          toOffset(destinationCity!.latitude, destinationCity!.longitude);

      // Route Glow Outline
      final glowPaint = Paint()
        ..color = AppColors.primary.withValues(alpha: 0.4)
        ..strokeWidth = 9.0
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round;

      // Active Route Line
      final routePaint = Paint()
        ..color = AppColors.primary
        ..strokeWidth = 4.5
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round;

      final path = Path();
      path.moveTo(start.dx, start.dy);

      final double midX = (start.dx + end.dx) / 2;
      final double midY = (start.dy + end.dy) / 2 - 15;
      path.quadraticBezierTo(midX, midY, end.dx, end.dy);

      canvas.drawPath(path, glowPaint);
      canvas.drawPath(path, routePaint);
    }
  }

  void _drawHighway(
      Canvas canvas, String cityId1, String cityId2, Paint paint) {
    final c1 = cities.where((c) => c.id == cityId1).firstOrNull;
    final c2 = cities.where((c) => c.id == cityId2).firstOrNull;

    if (c1 != null && c2 != null) {
      final p1 = toOffset(c1.latitude, c1.longitude);
      final p2 = toOffset(c2.latitude, c2.longitude);
      canvas.drawLine(p1, p2, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _UzbekistanMapPainter oldDelegate) {
    return oldDelegate.isDark != isDark ||
        oldDelegate.isSatellite != isSatellite ||
        oldDelegate.departureCity != departureCity ||
        oldDelegate.destinationCity != destinationCity;
  }
}
