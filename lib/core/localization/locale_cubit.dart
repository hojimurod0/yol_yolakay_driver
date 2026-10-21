import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../storage/local_storage_service.dart';

class LocaleCubit extends Cubit<Locale> {
  LocaleCubit(this._localStorageService)
      : super(Locale(_localStorageService.getLocale()));

  final LocalStorageService _localStorageService;

  Future<void> setLocale(Locale locale) async {
    await _localStorageService.setLocale(locale.languageCode);
    emit(locale);
  }

  Future<void> changeLanguage(String languageCode) async {
    await _localStorageService.setLocale(languageCode);
    emit(Locale(languageCode));
  }
}
