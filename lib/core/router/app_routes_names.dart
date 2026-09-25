/// Named routes. One name and one path per route. Navigation goes by name
/// (`goNamed`), and go_router fills the path parameters in, so no location
/// strings are built by hand.
abstract final class AppRoutesNames {
  static const String courses = 'courses';
  static const String coursesPath = '/';

  /// Nested under [coursesPath].
  static const String courseDetails = 'courseDetails';
  static const String courseDetailsPath = 'course/:$courseIdParam';

  /// Nested under [courseDetailsPath].
  static const String player = 'player';
  static const String playerPath = 'lesson/:$lessonIdParam';

  static const String courseIdParam = 'courseId';
  static const String lessonIdParam = 'lessonId';
}
