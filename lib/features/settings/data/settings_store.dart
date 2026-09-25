import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsStore {
  SettingsStore(this._prefs);

  static const _languageKey = 'settings.language';
  static const _themeModeKey = 'settings.themeMode';
  static const _playbackSpeedKey = 'settings.playbackSpeed';

  final SharedPreferences _prefs;

  String? get languageCode => _prefs.getString(_languageKey);
  Future<void> setLanguageCode(String code) =>
      _prefs.setString(_languageKey, code);

  ThemeMode get themeMode =>
      ThemeMode.values.asNameMap()[_prefs.getString(_themeModeKey)] ??
      ThemeMode.system;
  Future<void> setThemeMode(ThemeMode mode) =>
      _prefs.setString(_themeModeKey, mode.name);

  double? get playbackSpeed => _prefs.getDouble(_playbackSpeedKey);
  Future<void> setPlaybackSpeed(double speed) =>
      _prefs.setDouble(_playbackSpeedKey, speed);
}
