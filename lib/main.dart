import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app.dart';
import 'core/orientation.dart';
import 'features/courses/data/course_repository.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // In release builds, an unexpected build error shows a quiet placeholder
  // instead of Flutter's grey error box. Debug builds keep the full error.
  if (kReleaseMode) {
    ErrorWidget.builder = (_) =>
        const Center(child: Icon(Icons.error_outline, color: Colors.grey));
  }

  await SystemChrome.setPreferredOrientations(appOrientations);

  final prefs = await SharedPreferences.getInstance();
  runApp(
    ThaheenApp(
      prefs: prefs,
      courseRepository: CourseRepository(
        assetPath: CourseRepository.catalogFromEnvironment(),
      ),
    ),
  );
}
