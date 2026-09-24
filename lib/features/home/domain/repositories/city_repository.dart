import '../entities/city_entity.dart';

/// Repository contract for fetching and searching Uzbekistan cities.
abstract class CityRepository {
  Future<List<CityEntity>> getCities();
  Future<List<CityEntity>> getPopularCities();
  Future<List<CityEntity>> searchCities(String query);
}
