import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/providers/core_providers.dart';
import '../../domain/entities/city_entity.dart';
import '../../domain/repositories/city_repository.dart';

class CityPickerState {
  const CityPickerState({
    this.allCities = const [],
    this.filteredCities = const [],
    this.popularCities = const [],
    this.isLoading = false,
    this.searchQuery = '',
  });

  final List<CityEntity> allCities;
  final List<CityEntity> filteredCities;
  final List<CityEntity> popularCities;
  final bool isLoading;
  final String searchQuery;

  CityPickerState copyWith({
    List<CityEntity>? allCities,
    List<CityEntity>? filteredCities,
    List<CityEntity>? popularCities,
    bool? isLoading,
    String? searchQuery,
  }) {
    return CityPickerState(
      allCities: allCities ?? this.allCities,
      filteredCities: filteredCities ?? this.filteredCities,
      popularCities: popularCities ?? this.popularCities,
      isLoading: isLoading ?? this.isLoading,
      searchQuery: searchQuery ?? this.searchQuery,
    );
  }
}

class CityPickerNotifier extends StateNotifier<CityPickerState> {
  CityPickerNotifier(this._cityRepository) : super(const CityPickerState()) {
    loadCities();
  }

  final CityRepository _cityRepository;

  Future<void> loadCities() async {
    state = state.copyWith(isLoading: true);
    final results = await Future.wait([
      _cityRepository.getCities(),
      _cityRepository.getPopularCities(),
    ]);

    final all = results[0];
    final popular = results[1];

    state = state.copyWith(
      allCities: all,
      filteredCities: all,
      popularCities: popular,
      isLoading: false,
    );
  }

  void search(String query) {
    state = state.copyWith(searchQuery: query);
    if (query.trim().isEmpty) {
      state = state.copyWith(filteredCities: state.allCities);
      return;
    }

    final q = query.toLowerCase().trim();
    final filtered = state.allCities.where((c) {
      return c.nameUz.toLowerCase().contains(q) ||
          c.nameRu.toLowerCase().contains(q) ||
          c.nameEn.toLowerCase().contains(q) ||
          c.region.toLowerCase().contains(q);
    }).toList();

    state = state.copyWith(filteredCities: filtered);
  }

  void setSearchQuery(String query) => search(query);
}

final cityPickerNotifierProvider =
    StateNotifierProvider<CityPickerNotifier, CityPickerState>((ref) {
  final repo = ref.watch(cityRepositoryProvider);
  return CityPickerNotifier(repo);
});

final popularCitiesProvider = FutureProvider<List<CityEntity>>((ref) {
  final repo = ref.watch(cityRepositoryProvider);
  return repo.getPopularCities();
});
