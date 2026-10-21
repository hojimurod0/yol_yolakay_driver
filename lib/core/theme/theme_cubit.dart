import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../storage/local_storage_service.dart';

class ThemeCubit extends Cubit<ThemeMode> {
  ThemeCubit(this._localStorageService)
      : super(_parseThemeMode(_localStorageService.getThemeMode()));

  final LocalStorageService _localStorageService;

  static ThemeMode _parseThemeMode(String mode) {
    switch (mode) {
      case 'dark':
        return ThemeMode.dark;
      case 'system':
        return ThemeMode.system;
      case 'light':
      default:
        return ThemeMode.light;
    }
  }

  static String _themeModeToString(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.dark:
        return 'dark';
      case ThemeMode.light:
        return 'light';
      default:
        return 'system';
    }
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    await _localStorageService.setThemeMode(_themeModeToString(mode));
    emit(mode);
  }

  Future<void> toggleTheme() async {
    final newMode = state == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
    await setThemeMode(newMode);
  }
}
