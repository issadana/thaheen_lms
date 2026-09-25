import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/settings_store.dart';
import 'settings_state.dart';

export 'settings_state.dart';

class SettingsCubit extends Cubit<SettingsState> {
  SettingsCubit(this._store)
    : super(
        SettingsState(
          // Arabic-first: Arabic until the student picks otherwise.
          languageCode: supportedLanguages.contains(_store.languageCode)
              ? _store.languageCode!
              : 'ar',
          themeMode: _store.themeMode,
          playbackSpeed: _store.playbackSpeed ?? 1.0,
        ),
      );

  static const supportedLanguages = ['ar', 'en'];

  final SettingsStore _store;

  Future<void> toggleLanguage() async {
    final next = state.languageCode == 'ar' ? 'en' : 'ar';
    emit(state.copyWith(languageCode: next));
    await _store.setLanguageCode(next);
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    emit(state.copyWith(themeMode: mode));
    await _store.setThemeMode(mode);
  }

  Future<void> setPlaybackSpeed(double speed) async {
    emit(state.copyWith(playbackSpeed: speed));
    await _store.setPlaybackSpeed(speed);
  }
}
