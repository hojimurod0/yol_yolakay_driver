import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';
import 'package:go_router/go_router.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/localization/locale_cubit.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_snackbar.dart';
import '../../data/repositories/mock_city_repository.dart';
import '../../domain/entities/city_entity.dart';
import '../../domain/repositories/city_repository.dart';
import '../providers/city_picker_provider.dart';

enum CityPickerViewMode { map, list }

class CityPickerPage extends StatefulWidget {
  const CityPickerPage({
    super.key,
    required this.title,
    this.excludedCityId,
    this.initialMode = CityPickerViewMode.map,
  });

  final String title;
  final String? excludedCityId;
  final CityPickerViewMode initialMode;

  @override
  State<CityPickerPage> createState() => _CityPickerPageState();
}

class _CityPickerPageState extends State<CityPickerPage> {
  final TextEditingController _searchController = TextEditingController();
  late final CityPickerCubit _cityPickerCubit;
  GoogleMapController? _mapController;
  CityEntity? _selectedCity;
  MapType _mapType = MapType.normal;
  bool _isLocatingGps = false;

  // Selected Region Tab ('all', 'andijan', 'fergana', 'namangan')
  String _selectedRegionKey = 'andijan';

  // Initial Camera centered on Fergana Valley (Vodiy)
  static const CameraPosition _vodiyCenter = CameraPosition(
    target: LatLng(40.7500, 71.8000),
    zoom: 9.8,
  );

  @override
  void initState() {
    super.initState();
    final cityRepo = sl.isRegistered<CityRepository>()
        ? sl<CityRepository>()
        : MockCityRepository();
    _cityPickerCubit = CityPickerCubit(cityRepo);

    // Auto-detect current GPS location when opening picker
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final cities = _cityPickerCubit.state.allCities;
      if (cities.isNotEmpty) {
        _handleRealGpsDetect(cities, silent: true);
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _mapController?.dispose();
    _cityPickerCubit.close();
    super.dispose();
  }

  void _onMapCreated(GoogleMapController controller) {
    _mapController = controller;
  }

  CityEntity? _findNearestCity(LatLng point, List<CityEntity> cities) {
    if (cities.isEmpty) return null;
    CityEntity? nearest;
    double minDistance = double.infinity;

    for (final city in cities) {
      if (city.id == widget.excludedCityId) continue;
      final dLat = city.latitude - point.latitude;
      final dLng = city.longitude - point.longitude;
      final distSq = dLat * dLat + dLng * dLng;
      if (distSq < minDistance) {
        minDistance = distSq;
        nearest = city;
      }
    }
    return nearest;
  }

  void _handleMapTap(LatLng point, List<CityEntity> cities) {
    final nearest = _findNearestCity(point, cities);
    if (nearest != null) {
      setState(() => _selectedCity = nearest);
      _mapController?.animateCamera(
        CameraUpdate.newLatLngZoom(
          LatLng(nearest.latitude, nearest.longitude),
          12.5,
        ),
      );
    }
  }

  void _selectCityOnMap(CityEntity city) {
    setState(() => _selectedCity = city);
    _mapController?.animateCamera(
      CameraUpdate.newLatLngZoom(
        LatLng(city.latitude, city.longitude),
        13.0,
      ),
    );
  }

  Set<Marker> _buildMapMarkers(List<CityEntity> cities, String localeCode) {
    final Set<Marker> markers = {};
    for (final city in cities) {
      if (city.id == widget.excludedCityId) continue;
      final isSelected = _selectedCity?.id == city.id;

      markers.add(
        Marker(
          markerId: MarkerId('city_${city.id}'),
          position: LatLng(city.latitude, city.longitude),
          icon: BitmapDescriptor.defaultMarkerWithHue(
            isSelected
                ? BitmapDescriptor.hueYellow
                : (city.isPopular
                    ? BitmapDescriptor.hueViolet
                    : BitmapDescriptor.hueCyan),
          ),
          infoWindow: InfoWindow(
            title: city.localizedName(localeCode),
            snippet: city.localizedRegion(localeCode),
          ),
          onTap: () => _selectCityOnMap(city),
        ),
      );
    }
    return markers;
  }

  Future<void> _handleRealGpsDetect(List<CityEntity> cities,
      {bool silent = false}) async {
    if (!silent) setState(() => _isLocatingGps = true);

    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled().timeout(
        const Duration(seconds: 2),
        onTimeout: () => false,
      );
      if (!serviceEnabled) {
        if (!silent && mounted) {
          AppSnackBar.showError(
            context,
            'GPS xizmati o\'chiq. Iltimos, GPS ni yoqing.',
          );
        }
        return;
      }

      LocationPermission permission =
          await Geolocator.checkPermission().timeout(
        const Duration(seconds: 2),
        onTimeout: () => LocationPermission.denied,
      );
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission().timeout(
          const Duration(seconds: 3),
          onTimeout: () => LocationPermission.denied,
        );
      }

      if (permission == LocationPermission.deniedForever) {
        if (mounted && !silent) {
          AppSnackBar.showInfo(
            context,
            'GPS ruxsati berilmagan. Sozlamalardan yoqing.',
          );
        }
        return;
      }

      if (permission == LocationPermission.denied) {
        if (mounted && !silent) {
          AppSnackBar.showError(
            context,
            'GPS joylashuv ruxsati berilmadi',
          );
        }
        return;
      }

      // First check last known position (0ms fast response)
      Position? position = await Geolocator.getLastKnownPosition().timeout(
        const Duration(milliseconds: 600),
        onTimeout: () => null,
      );

      if (position == null) {
        try {
          position = await Geolocator.getCurrentPosition(
            locationSettings: const LocationSettings(
              accuracy: LocationAccuracy.medium,
              timeLimit: Duration(seconds: 3),
            ),
          ).timeout(const Duration(seconds: 3));
        } catch (_) {
          position = null;
        }
      }

      if (position != null) {
        final nearest = _findNearestCity(
            LatLng(position.latitude, position.longitude), cities);
        if (nearest != null && mounted) {
          _selectCityOnMap(nearest);
          _mapController?.animateCamera(
            CameraUpdate.newLatLngZoom(
              LatLng(position.latitude, position.longitude),
              13.5,
            ),
          );
          if (!silent && mounted) {
            final locale = context.read<LocaleCubit>().state.languageCode;
            AppSnackBar.showSuccess(
              context,
              'Joylashuv aniqlandi: ${nearest.localizedName(locale)}',
            );
          }
        }
      } else if (!silent && mounted) {
        final defaultCity =
            cities.where((c) => c.isPopular).firstOrNull ?? cities.first;
        _selectCityOnMap(defaultCity);
      }
    } catch (_) {
      if (!silent && mounted) {
        final defaultCity =
            cities.where((c) => c.isPopular).firstOrNull ?? cities.first;
        _selectCityOnMap(defaultCity);
      }
    } finally {
      if (mounted) {
        setState(() => _isLocatingGps = false);
      }
    }
  }

  List<CityEntity> _getFilteredCities(List<CityEntity> allCities) {
    final query = _searchController.text.toLowerCase().trim();

    return allCities.where((city) {
      if (city.id == widget.excludedCityId) return false;

      // Search Query Filter
      if (query.isNotEmpty) {
        final matchesName = city.nameUz.toLowerCase().contains(query) ||
            city.nameRu.toLowerCase().contains(query) ||
            city.nameEn.toLowerCase().contains(query) ||
            city.region.toLowerCase().contains(query);
        return matchesName;
      }

      // Region Tab Filter
      if (_selectedRegionKey == 'andijan') {
        return city.region.toLowerCase().contains('andijon') ||
            city.region.toLowerCase().contains('андижан');
      } else if (_selectedRegionKey == 'fergana') {
        return city.region.toLowerCase().contains('farg\'ona') ||
            city.region.toLowerCase().contains('fargona') ||
            city.region.toLowerCase().contains('ферган');
      } else if (_selectedRegionKey == 'namangan') {
        return city.region.toLowerCase().contains('namangan') ||
            city.region.toLowerCase().contains('наманган');
      }
      return true;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CityPickerCubit, CityPickerState>(
      bloc: _cityPickerCubit,
      builder: (context, cityState) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        final locale = context.watch<LocaleCubit>().state;
        final localeCode = locale.languageCode;
        final isRu = localeCode == 'ru';

        final displayCities = _getFilteredCities(cityState.allCities);

        return Scaffold(
      backgroundColor:
          isDark ? const Color(0xFF101014) : const Color(0xFFF7F6FB),
      body: Stack(
        children: [
          // 1. Google Maps View occupying full screen
          GoogleMap(
            initialCameraPosition: _vodiyCenter,
            mapType: _mapType,
            myLocationEnabled: true,
            myLocationButtonEnabled: false,
            zoomControlsEnabled: false,
            compassEnabled: false,
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).size.height * 0.44 + 10,
              top: 60,
            ),
            markers: _buildMapMarkers(cityState.allCities, localeCode),
            onMapCreated: _onMapCreated,
            onTap: (point) => _handleMapTap(point, cityState.allCities),
          ),

          // 2. Top Navigation Bar (Back button on Left, Map Style switch on Right)
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
                vertical: AppSpacing.sm,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Back Button (Back to previous screen)
                  InkWell(
                    onTap: () => context.pop(),
                    borderRadius: BorderRadius.circular(22),
                    child: Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: isDark
                            ? AppColors.surfaceDark.withValues(alpha: 0.92)
                            : Colors.white.withValues(alpha: 0.95),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black
                                .withValues(alpha: isDark ? 0.35 : 0.12),
                            blurRadius: 10,
                            offset: const Offset(0, 3),
                          ),
                        ],
                        border: Border.all(
                          color: isDark
                              ? Colors.white.withValues(alpha: 0.12)
                              : Colors.black.withValues(alpha: 0.08),
                        ),
                      ),
                      child: Center(
                        child: Icon(
                          Icons.arrow_back_ios_new_rounded,
                          color: isDark
                              ? Colors.white
                              : AppColors.textPrimaryLight,
                          size: 18,
                        ),
                      ),
                    ),
                  ),

                  // Title Pill
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: isDark
                          ? AppColors.surfaceDark.withValues(alpha: 0.92)
                          : Colors.white.withValues(alpha: 0.95),
                      borderRadius: AppRadius.borderPill,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black
                              .withValues(alpha: isDark ? 0.3 : 0.1),
                          blurRadius: 10,
                          offset: const Offset(0, 3),
                        ),
                      ],
                      border: Border.all(
                        color: isDark
                            ? Colors.white.withValues(alpha: 0.12)
                            : Colors.black.withValues(alpha: 0.08),
                      ),
                    ),
                    child: Text(
                      widget.title,
                      style: TextStyle(
                        color:
                            isDark ? Colors.white : AppColors.textPrimaryLight,
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),

                  // Map Type Toggle Button (Normal / Satellite)
                  InkWell(
                    onTap: () {
                      setState(() {
                        _mapType = _mapType == MapType.normal
                            ? MapType.hybrid
                            : MapType.normal;
                      });
                    },
                    borderRadius: BorderRadius.circular(22),
                    child: Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: isDark
                            ? AppColors.surfaceDark.withValues(alpha: 0.92)
                            : Colors.white.withValues(alpha: 0.95),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black
                                .withValues(alpha: isDark ? 0.35 : 0.12),
                            blurRadius: 10,
                            offset: const Offset(0, 3),
                          ),
                        ],
                        border: Border.all(
                          color: isDark
                              ? Colors.white.withValues(alpha: 0.12)
                              : Colors.black.withValues(alpha: 0.08),
                        ),
                      ),
                      child: Center(
                        child: Icon(
                          _mapType == MapType.normal
                              ? Icons.layers_rounded
                              : Icons.map_rounded,
                          color: isDark
                              ? AppColors.taxiYellow
                              : AppColors.primary,
                          size: 20,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // 3. Floating GPS Location Button (Above Bottom Sheet)
          Positioned(
            right: 16,
            bottom: MediaQuery.of(context).size.height * 0.44 + 14,
            child: Material(
              color: isDark
                  ? AppColors.surfaceDark.withValues(alpha: 0.92)
                  : Colors.white.withValues(alpha: 0.95),
              shape: const CircleBorder(),
              elevation: 6,
              child: InkWell(
                customBorder: const CircleBorder(),
                onTap: _isLocatingGps
                    ? null
                    : () => _handleRealGpsDetect(cityState.allCities),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: _isLocatingGps
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2.2),
                        )
                      : Icon(
                          Icons.my_location_rounded,
                          color: isDark
                              ? const Color(0xFFFCE000)
                              : AppColors.primary,
                          size: 22,
                        ),
                ),
              ),
            ),
          ),

          // 4. Luxury Bottom Sheet (Yol-Yolakay Taxi Style)
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height * 0.44,
              ),
              padding: const EdgeInsets.fromLTRB(16, 10, 16, 18),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF18181E) : Colors.white,
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(24)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: isDark ? 0.55 : 0.15),
                    blurRadius: 20,
                    offset: const Offset(0, -6),
                  ),
                ],
                border: Border(
                  top: BorderSide(
                    color: isDark
                        ? Colors.white.withValues(alpha: 0.08)
                        : Colors.black.withValues(alpha: 0.06),
                  ),
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Drag handle pill
                  Center(
                    child: Container(
                      width: 38,
                      height: 4,
                      decoration: BoxDecoration(
                        color: isDark
                            ? const Color(0xFF383842)
                            : const Color(0xFFD1D5DB),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),

                  const SizedBox(height: 10),

                  // Search Bar + GPS Icon Button Row
                  Row(
                    children: [
                      // Search Input
                      Expanded(
                        child: Container(
                          decoration: BoxDecoration(
                            color: isDark
                                ? const Color(0xFF22222A)
                                : const Color(0xFFF3F4F6),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: isDark
                                  ? const Color(0xFF2E2E38)
                                  : const Color(0xFFE5E7EB),
                            ),
                          ),
                          child: TextField(
                            controller: _searchController,
                            style: TextStyle(
                              color: isDark
                                  ? Colors.white
                                  : AppColors.textPrimaryLight,
                              fontSize: 14.5,
                              fontWeight: FontWeight.w600,
                            ),
                            decoration: InputDecoration(
                              hintText: isRu
                                  ? 'Поиск района или города...'
                                  : 'Tuman yoki shaharni qidiring...',
                              hintStyle: TextStyle(
                                color: isDark
                                    ? const Color(0xFF8E8E98)
                                    : const Color(0xFF9CA3AF),
                                fontSize: 14,
                              ),
                              prefixIcon: const Icon(
                                Icons.search_rounded,
                                color: AppColors.taxiYellowDark,
                                size: 22,
                              ),
                              suffixIcon: _searchController.text.isNotEmpty
                                  ? IconButton(
                                      icon: const Icon(Icons.clear_rounded,
                                          size: 18),
                                      onPressed: () {
                                        _searchController.clear();
                                        setState(() {});
                                      },
                                    )
                                  : null,
                              border: InputBorder.none,
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 14,
                                vertical: 11,
                              ),
                            ),
                            onChanged: (_) => setState(() {}),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      // Clean GPS Location Icon Button
                      InkWell(
                        onTap: _isLocatingGps
                            ? null
                            : () => _handleRealGpsDetect(cityState.allCities),
                        borderRadius: BorderRadius.circular(14),
                        child: Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: isDark
                                ? const Color(0xFF22222A)
                                : const Color(0xFFF3F4F6),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: AppColors.taxiYellow
                                  .withValues(alpha: isDark ? 0.35 : 0.4),
                              width: 1.2,
                            ),
                          ),
                          child: Center(
                            child: _isLocatingGps
                                ? const SizedBox(
                                    width: 18,
                                    height: 18,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                          AppColors.taxiYellow),
                                    ),
                                  )
                                : const Icon(
                                    Icons.my_location_rounded,
                                    color: AppColors.taxiYellowDark,
                                    size: 22,
                                  ),
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 10),

                  // 2. Vodiy Region Filter Tabs (Andijon, Farg'ona, Namangan)
                  if (_searchController.text.isEmpty)
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      physics: const BouncingScrollPhysics(),
                      child: Row(
                        children: [
                          _buildRegionCategoryChip(
                            id: 'andijan',
                            label: isRu ? 'Андижан' : 'Andijon',
                            isDark: isDark,
                          ),
                          const SizedBox(width: 8),
                          _buildRegionCategoryChip(
                            id: 'fergana',
                            label: isRu ? 'Фергана' : 'Farg\'ona',
                            isDark: isDark,
                          ),
                          const SizedBox(width: 8),
                          _buildRegionCategoryChip(
                            id: 'namangan',
                            label: isRu ? 'Наманган' : 'Namangan',
                            isDark: isDark,
                          ),
                        ],
                      ),
                    ),

                  const SizedBox(height: 10),

                  // 3. Scrollable Cities / Districts List
                  Flexible(
                    child: displayCities.isEmpty
                        ? Center(
                            child: Padding(
                              padding: const EdgeInsets.all(20),
                              child: Text(
                                isRu
                                    ? 'Ничего не найдено'
                                    : 'Hech qanday tuman/shahar topilmadi',
                                style: TextStyle(
                                  color: isDark
                                      ? AppColors.textSecondaryDark
                                      : AppColors.textSecondaryLight,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          )
                        : ListView.separated(
                            physics: const BouncingScrollPhysics(),
                            padding: const EdgeInsets.only(bottom: 12),
                            shrinkWrap: true,
                            itemCount: displayCities.length,
                            separatorBuilder: (_, __) => Divider(
                              height: 1,
                              color: isDark
                                  ? const Color(0xFF24242E)
                                  : const Color(0xFFF0F0F4),
                            ),
                            itemBuilder: (context, index) {
                              final city = displayCities[index];
                              final isSelected = _selectedCity?.id == city.id;

                              return InkWell(
                                onTap: () {
                                  setState(() => _selectedCity = city);
                                  context.pop(city);
                                },
                                borderRadius: BorderRadius.circular(12),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 9,
                                  ),
                                  decoration: BoxDecoration(
                                    color: isSelected
                                        ? (isDark
                                            ? const Color(0xFF2A2A35)
                                            : AppColors.taxiYellow
                                                .withValues(alpha: 0.15))
                                        : Colors.transparent,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Row(
                                    children: [
                                      Container(
                                        width: 32,
                                        height: 32,
                                        decoration: BoxDecoration(
                                          color: isSelected
                                              ? AppColors.taxiYellow
                                              : (isDark
                                                  ? const Color(0xFF252530)
                                                  : const Color(0xFFF3F4F6)),
                                          shape: BoxShape.circle,
                                        ),
                                        child: Icon(
                                          Icons.location_on_rounded,
                                          size: 16,
                                          color: isSelected
                                              ? AppColors.charcoalBlack
                                              : AppColors.taxiYellowDark,
                                        ),
                                      ),
                                      const SizedBox(width: 10),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Text(
                                              city.localizedName(localeCode),
                                              style: TextStyle(
                                                color: isDark
                                                    ? Colors.white
                                                    : AppColors
                                                        .textPrimaryLight,
                                                fontWeight: FontWeight.w700,
                                                fontSize: 14,
                                              ),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                            Text(
                                              city.localizedRegion(localeCode),
                                              style: TextStyle(
                                                color: isDark
                                                    ? AppColors
                                                        .textSecondaryDark
                                                    : AppColors
                                                        .textSecondaryLight,
                                                fontSize: 11.5,
                                              ),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ],
                                        ),
                                      ),
                                      if (isSelected)
                                        const Icon(
                                          Icons.check_circle_rounded,
                                          color: AppColors.taxiYellowDark,
                                          size: 20,
                                        )
                                      else
                                        Icon(
                                          Icons.arrow_forward_ios_rounded,
                                          color: isDark
                                              ? const Color(0xFF555562)
                                              : const Color(0xFFC4C4CE),
                                          size: 14,
                                        ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                  ),

                  // 4. Selected City Quick Confirm Button
                  if (_selectedCity != null) ...[
                    const SizedBox(height: 8),
                    AppButton(
                      text: isRu
                          ? 'Выбрать: ${_selectedCity!.localizedName(localeCode)}'
                          : 'Tanlash: ${_selectedCity!.localizedName(localeCode)}',
                      height: 44,
                      onPressed: () => context.pop(_selectedCity),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
      },
    );
  }

  Widget _buildRegionCategoryChip({
    required String id,
    required String label,
    required bool isDark,
  }) {
    final isSelected = _selectedRegionKey == id;

    return InkWell(
      onTap: () => setState(() => _selectedRegionKey = id),
      borderRadius: BorderRadius.circular(20),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.taxiYellow
              : (isDark ? const Color(0xFF22222A) : const Color(0xFFF3F4F6)),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected
                ? AppColors.taxiYellowDark
                : (isDark ? const Color(0xFF2E2E38) : const Color(0xFFE5E7EB)),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected
                ? AppColors.charcoalBlack
                : (isDark
                    ? AppColors.textPrimaryDark
                    : AppColors.textPrimaryLight),
            fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
            fontSize: 12.5,
          ),
        ),
      ),
    );
  }
}
