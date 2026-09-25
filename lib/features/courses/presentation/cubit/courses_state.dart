import 'package:equatable/equatable.dart';

import '../../domain/course.dart';

sealed class CoursesState extends Equatable {
  const CoursesState();

  @override
  List<Object?> get props => [];
}

final class CoursesLoading extends CoursesState {
  const CoursesLoading();
}

final class CoursesLoaded extends CoursesState {
  const CoursesLoaded(this.courses, {this.query = ''});

  /// The whole catalog.
  final List<Course> courses;

  /// What the student typed in the search box.
  final String query;

  bool get isSearching => query.trim().isNotEmpty;

  /// The courses matching [query]; all of them when it's empty.
  List<Course> get visibleCourses =>
      courses.where((course) => course.matches(query)).toList();

  @override
  List<Object?> get props => [courses, query];
}

/// The catalog could not be read. The technical details are logged; the UI
/// shows a friendly, localized message with a retry button.
final class CoursesError extends CoursesState {
  const CoursesError();
}
