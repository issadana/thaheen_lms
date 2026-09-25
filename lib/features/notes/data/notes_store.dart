import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Saves the student's lesson notes as one JSON object in SharedPreferences,
/// keyed like progress ("courseId/lessonId"). Plain text only, so a
/// key-value store is enough, as it is for progress.
class NotesStore {
  NotesStore(this._prefs);

  static const storageKey = 'notes.v1';

  final SharedPreferences _prefs;

  Map<String, String> load() {
    final raw = _prefs.getString(storageKey);
    if (raw == null) return const {};
    try {
      final decoded = jsonDecode(raw) as Map<String, dynamic>;
      return {
        for (final entry in decoded.entries) entry.key: entry.value as String,
      };
    } catch (error) {
      // Unreadable saved notes should not stop the app from starting.
      debugPrint('Ignoring unreadable notes data: $error');
      return const {};
    }
  }

  Future<void> save(Map<String, String> notes) =>
      _prefs.setString(storageKey, jsonEncode(notes));
}
