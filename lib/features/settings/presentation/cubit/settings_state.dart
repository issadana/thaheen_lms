import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

class SettingsState extends Equatable {
  const SettingsState({
    required this.languageCode,
    required this.themeMode,
    required this.playbackSpeed,
  });

  final String languageCode;
  final ThemeMode themeMode;
  /// The last speed the student picked, reused for the next lesson.
  final double playbackSpeed;

  Locale get locale => Locale(languageCode);

  SettingsState copyWith({
    String? languageCode,
    ThemeMode? themeMode,
    double? playbackSpeed,
  }) => SettingsState(
    languageCode: languageCode ?? this.languageCode,
    themeMode: themeMode ?? this.themeMode,
    playbackSpeed: playbackSpeed ?? this.playbackSpeed,
  );

  @override
  List<Object?> get props => [languageCode, themeMode, playbackSpeed];
}
