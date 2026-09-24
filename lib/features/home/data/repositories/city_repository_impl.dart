import '../../../../core/constants/api_endpoints.dart';
import '../../../../core/network/api_client.dart';
import '../../domain/entities/city_entity.dart';
import '../../domain/repositories/city_repository.dart';
import '../models/city_model.dart';

class CityRepositoryImpl implements CityRepository {
  CityRepositoryImpl(this._apiClient);

  final ApiClient _apiClient;
  List<CityEntity>? _cachedCities;

  static const List<CityModel> _defaultCities = [
    CityModel(
      id: 'tashkent',
      nameUz: 'Toshkent',
      nameRu: 'Ташкент',
      nameEn: 'Tashkent',
      region: 'Toshkent shahri',
      isPopular: true,
      latitude: 41.2995,
      longitude: 69.2401,
    ),
    CityModel(
      id: 'andijan',
      nameUz: 'Andijon',
      nameRu: 'Андижан',
      nameEn: 'Andijan',
      region: 'Andijon viloyati',
      isPopular: true,
      latitude: 40.7821,
      longitude: 72.3442,
    ),
    CityModel(
      id: 'fergana',
      nameUz: 'Farg\'ona',
      nameRu: 'Фергана',
      nameEn: 'Fergana',
      region: 'Farg\'ona viloyati',
      isPopular: true,
      latitude: 40.3842,
      longitude: 71.7843,
    ),
    CityModel(
      id: 'namangan',
      nameUz: 'Namangan',
      nameRu: 'Наманган',
      nameEn: 'Namangan',
      region: 'Namangan viloyati',
      isPopular: true,
      latitude: 40.9983,
      longitude: 71.6726,
    ),
    CityModel(
      id: 'samarkand',
      nameUz: 'Samarqand',
      nameRu: 'Самарканд',
      nameEn: 'Samarkand',
      region: 'Samarqand viloyati',
      isPopular: true,
      latitude: 39.6270,
      longitude: 66.9750,
    ),
    CityModel(
      id: 'bukhara',
      nameUz: 'Buxoro',
      nameRu: 'Бухара',
      nameEn: 'Bukhara',
      region: 'Buxoro viloyati',
      isPopular: true,
      latitude: 39.7681,
      longitude: 64.4556,
    ),
  ];

  @override
  Future<List<CityEntity>> getCities() async {
    if (_cachedCities != null && _cachedCities!.isNotEmpty) {
      return _cachedCities!;
    }
    try {
      final response = await _apiClient.get(
        ApiEndpoints.cities,
        fromData: (data) {
          final List<CityModel> list = [];
          if (data is List) {
            for (final item in data) {
              if (item is Map<String, dynamic>) {
                list.add(CityModel.fromJson(item));
              }
            }
          } else if (data is Map<String, dynamic> && data['cities'] is List) {
            for (final item in data['cities'] as List) {
              if (item is Map<String, dynamic>) {
                list.add(CityModel.fromJson(item));
              }
            }
          }
          return list;
        },
      );
      final cities = response.data;
      if (cities != null && cities.isNotEmpty) {
        _cachedCities = cities;
        return cities;
      }
    } catch (_) {
      // Graceful fallback to default cities if offline or initial load
    }
    _cachedCities = _defaultCities;
    return _defaultCities;
  }

  @override
  Future<List<CityEntity>> getPopularCities() async {
    final cities = await getCities();
    final popular = cities.where((c) => c.isPopular).toList();
    return popular.isNotEmpty ? popular : cities.take(4).toList();
  }

  @override
  Future<List<CityEntity>> searchCities(String query) async {
    final cities = await getCities();
    if (query.trim().isEmpty) return cities;
    final q = query.toLowerCase().trim();
    return cities.where((c) {
      return c.nameUz.toLowerCase().contains(q) ||
          c.nameRu.toLowerCase().contains(q) ||
          c.nameEn.toLowerCase().contains(q) ||
          c.region.toLowerCase().contains(q);
    }).toList();
  }
}
