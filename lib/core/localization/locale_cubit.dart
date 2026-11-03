import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../storage/local_storage_service.dart';
import '../utils/currency_formatter.dart';

class LocaleCubit extends Cubit<Locale> {
  LocaleCubit(this._localStorageService)
      : super(localeFromTag(_localStorageService.getLocale())) {
    AppCurrencyFormatter.currentLocale = tagOf(state);
  }

  final LocalStorageService _localStorageService;

  @override
  void onChange(Change<Locale> change) {
    super.onChange(change);
    AppCurrencyFormatter.currentLocale = tagOf(change.nextState);
  }

  /// Stored tags: `uz` (Latin), `uz_Cyrl` (Cyrillic), `ru`, `en`.
  static Locale localeFromTag(String tag) {
    final parts = tag.split('_');
    if (parts.length == 2) {
      return Locale.fromSubtags(languageCode: parts[0], scriptCode: parts[1]);
    }
    return Locale(tag);
  }

  static String tagOf(Locale locale) => locale.scriptCode == null
      ? locale.languageCode
      : '${locale.languageCode}_${locale.scriptCode}';

  Future<void> setLocale(Locale locale) async {
    await _localStorageService.setLocale(tagOf(locale));
    emit(locale);
  }

  /// Accepts a stored tag (`uz`, `uz_Cyrl`, `ru`, `en`).
  Future<void> changeLanguage(String tag) async {
    await _localStorageService.setLocale(tag);
    emit(localeFromTag(tag));
  }
}
