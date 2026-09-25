import 'dart:convert';

import 'package:flutter/services.dart';

import '../domain/course.dart';
import '../domain/json_fields.dart';

/// Thrown when the course catalog is missing or cannot be parsed.
class CatalogException implements Exception {
  const CatalogException(this.message, [this.cause]);

  final String message;
  final Object? cause;

  @override
  String toString() =>
      'CatalogException: $message${cause != null ? ' ($cause)' : ''}';
}

/// Loads the course catalog from a JSON file bundled with the app.
class CourseRepository {
  CourseRepository({AssetBundle? bundle, this.assetPath = defaultCatalog})
    : _bundle = bundle ?? rootBundle;

  static const defaultCatalog = 'assets/data/courses.json';

  /// Picks the catalog from `--dart-define=CATALOG=...` so the edge-case
  /// data (empty course, missing/corrupt video, corrupt JSON) can be shown
  /// without touching the real data:
  ///   flutter run --dart-define=CATALOG=edge
  ///   flutter run --dart-define=CATALOG=corrupt
  static String catalogFromEnvironment() {
    const catalog = String.fromEnvironment('CATALOG');
    return switch (catalog) {
      'edge' => 'assets/data/courses_edge_cases.json',
      'corrupt' => 'assets/data/courses_corrupt.json',
      _ => defaultCatalog,
    };
  }

  final AssetBundle _bundle;
  final String assetPath;

  Future<List<Course>> loadCourses() async {
    final String raw;
    try {
      // cache: false so "Try again" really re-reads the file.
      raw = await _bundle.loadString(assetPath, cache: false);
    } catch (error) {
      throw CatalogException('Could not read $assetPath', error);
    }
    try {
      return parseCatalog(raw);
    } on FormatException catch (error) {
      throw CatalogException(
        'Invalid catalog in $assetPath: ${error.message}',
        error,
      );
    }
  }

  static List<Course> parseCatalog(String raw) {
    final decoded = jsonDecode(raw);
    if (decoded is! Map<String, dynamic>) {
      throw const FormatException(
        'the root must be an object with a "courses" list',
      );
    }
    final courses = [
      for (final course in readObjectList(decoded, 'courses', 'catalog'))
        Course.fromJson(course),
    ];
    ensureUniqueIds(courses.map((c) => c.id), 'catalog');
    return courses;
  }
}
