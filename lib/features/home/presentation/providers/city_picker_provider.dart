import 'package:flutter_bloc/flutter_bloc.dart';
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

class CityPickerCubit extends Cubit<CityPickerState> {
  CityPickerCubit(this._cityRepository) : super(const CityPickerState()) {
    loadCities();
  }

  final CityRepository _cityRepository;

  Future<void> loadCities() async {
    emit(state.copyWith(isLoading: true));
    try {
      final results = await Future.wait([
        _cityRepository.getCities(),
        _cityRepository.getPopularCities(),
      ]);

      final all = results[0];
      final popular = results[1];

      emit(state.copyWith(
        allCities: all,
        filteredCities: all,
        popularCities: popular,
        isLoading: false,
      ));
    } catch (_) {
      emit(state.copyWith(isLoading: false));
    }
  }

  void search(String query) {
    emit(state.copyWith(searchQuery: query));
    if (query.trim().isEmpty) {
      emit(state.copyWith(filteredCities: state.allCities));
      return;
    }

    final q = query.toLowerCase().trim();
    final filtered = state.allCities.where((c) {
      return c.nameUz.toLowerCase().contains(q) ||
          c.nameRu.toLowerCase().contains(q) ||
          c.nameEn.toLowerCase().contains(q) ||
          c.region.toLowerCase().contains(q);
    }).toList();

    emit(state.copyWith(filteredCities: filtered));
  }

  void setSearchQuery(String query) => search(query);
}
