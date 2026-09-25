import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../domain/lesson_progress.dart';

/// Saves lesson progress as one JSON object in SharedPreferences.
///
/// The data is tiny (one small record per lesson), so a key-value store is
/// enough: no schema, no code generation, and reads are synchronous once
/// SharedPreferences is loaded at startup.
class ProgressStore {
  ProgressStore(this._prefs);

  static const storageKey = 'progress.v1';

  final SharedPreferences _prefs;

  ProgressMap load() {
    final raw = _prefs.getString(storageKey);
    if (raw == null) return const {};
    try {
      final decoded = jsonDecode(raw) as Map<String, dynamic>;
      return {
        for (final entry in decoded.entries)
          entry.key: LessonProgress.fromJson(entry.value as Map<String, dynamic>),
      };
    } catch (error) {
      // Corrupt saved data should not stop the app from starting.
      // Start fresh instead.
      debugPrint('Ignoring unreadable progress data: $error');
      return const {};
    }
  }

  Future<void> save(ProgressMap progress) => _prefs.setString(
        storageKey,
        jsonEncode({for (final entry in progress.entries) entry.key: entry.value.toJson()}),
      );

  Future<void> clear() => _prefs.remove(storageKey);
}
