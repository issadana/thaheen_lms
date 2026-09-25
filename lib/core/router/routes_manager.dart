import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';

import '../../features/courses/presentation/screens/course_details_screen.dart';
import '../../features/courses/presentation/screens/courses_screen.dart';
import '../../features/player/presentation/screens/player_screen.dart';
import 'app_routes_names.dart';

/// Owns the app's [GoRouter] and every navigation in the app.
class RoutesManager {
  GoRouter get router => _router;

  static void _goToCourse(BuildContext context, String courseId) =>
      context.goNamed(
        AppRoutesNames.courseDetails,
        pathParameters: {AppRoutesNames.courseIdParam: courseId},
      );

  /// `go`, not `push`: the routes are nested, so this always builds the stack
  /// courses -> course details -> player, and back behaves as expected even
  /// when the player is opened from "Continue watching" or "Next lesson".
  static void _goToLesson(
    BuildContext context,
    String courseId,
    String lessonId,
  ) => context.goNamed(
    AppRoutesNames.player,
    pathParameters: {
      AppRoutesNames.courseIdParam: courseId,
      AppRoutesNames.lessonIdParam: lessonId,
    },
  );

  late final GoRouter _router = GoRouter(
    routes: [
      GoRoute(
        path: AppRoutesNames.coursesPath,
        name: AppRoutesNames.courses,
        builder: (context, state) => CoursesScreen(
          onOpenCourse: (courseId) => _goToCourse(context, courseId),
          onOpenLesson: (courseId, lessonId) =>
              _goToLesson(context, courseId, lessonId),
        ),
        routes: [
          GoRoute(
            path: AppRoutesNames.courseDetailsPath,
            name: AppRoutesNames.courseDetails,
            builder: (context, state) => CourseDetailsScreen(
              courseId: state.pathParameters[AppRoutesNames.courseIdParam]!,
              onOpenLesson: (courseId, lessonId) =>
                  _goToLesson(context, courseId, lessonId),
            ),
            routes: [
              GoRoute(
                path: AppRoutesNames.playerPath,
                name: AppRoutesNames.player,
                builder: (context, state) => PlayerScreen(
                  courseId: state.pathParameters[AppRoutesNames.courseIdParam]!,
                  lessonId: state.pathParameters[AppRoutesNames.lessonIdParam]!,
                  onOpenLesson: (courseId, lessonId) =>
                      _goToLesson(context, courseId, lessonId),
                ),
              ),
            ],
          ),
        ],
      ),
    ],
  );

  void dispose() => _router.dispose();
}
