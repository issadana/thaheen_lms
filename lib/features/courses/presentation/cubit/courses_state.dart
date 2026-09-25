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
  const CoursesLoaded(this.courses);

  final List<Course> courses;

  @override
  List<Object?> get props => [courses];
}

/// The catalog could not be read. The technical details are logged; the UI
/// shows a friendly, localized message with a retry button.
final class CoursesError extends CoursesState {
  const CoursesError();
}
