import 'dart:ui';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _localePrefsKey = 'locale';
const supportedLocaleCodes = ['en', 'id'];

/// Active app locale. Not sensitive data, so it's persisted via
/// `shared_preferences` — NOT `flutter_secure_storage` (that's reserved for
/// the auth token). Defaults to the device locale until the user picks one
/// manually.
@lazySingleton
class LocaleCubit extends Cubit<Locale?> {
  LocaleCubit(this._prefs) : super(_readStoredLocale(_prefs));

  final SharedPreferences _prefs;

  static Locale? _readStoredLocale(SharedPreferences prefs) {
    final code = prefs.getString(_localePrefsKey);
    if (code == null || !supportedLocaleCodes.contains(code)) return null;
    return Locale(code);
  }

  Future<void> setLocale(Locale locale) async {
    await _prefs.setString(_localePrefsKey, locale.languageCode);
    emit(locale);
  }

  Future<void> resetToDeviceLocale() async {
    await _prefs.remove(_localePrefsKey);
    emit(null);
  }
}

@module
abstract class SharedPreferencesModule {
  @preResolve
  Future<SharedPreferences> get sharedPreferences =>
      SharedPreferences.getInstance();
}
