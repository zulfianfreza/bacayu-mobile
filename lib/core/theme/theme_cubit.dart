import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _themeModePrefsKey = 'themeMode';

/// Active [ThemeMode] — light, dark, or follow the system.
///
/// Like `LocaleCubit` this is a user preference, not sensitive data, so it is
/// persisted via `shared_preferences` (NOT `flutter_secure_storage`, which is
/// reserved for the auth token). Defaults to [ThemeMode.system] until the user
/// picks one in the appearance sheet.
@lazySingleton
class ThemeCubit extends Cubit<ThemeMode> {
  ThemeCubit(this._prefs) : super(_readStoredMode(_prefs));

  final SharedPreferences _prefs;

  static ThemeMode _readStoredMode(SharedPreferences prefs) {
    // `ThemeMode.name` is exactly the stored value ('system'/'light'/'dark');
    // anything else — including a missing key — reads as system.
    return ThemeMode.values.firstWhere(
      (mode) => mode.name == prefs.getString(_themeModePrefsKey),
      orElse: () => ThemeMode.system,
    );
  }

  Future<void> setMode(ThemeMode mode) async {
    await _prefs.setString(_themeModePrefsKey, mode.name);
    emit(mode);
  }

  /// Back to the device setting, and no stored preference to override it.
  Future<void> resetToSystem() async {
    await _prefs.remove(_themeModePrefsKey);
    emit(ThemeMode.system);
  }
}
