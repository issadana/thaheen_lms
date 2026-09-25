import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/course_repository.dart';
import '../../domain/course.dart';
import 'courses_state.dart';

export 'courses_state.dart';

class CoursesCubit extends Cubit<CoursesState> {
  CoursesCubit(this._repository) : super(const CoursesLoading());

  final CourseRepository _repository;

  Future<void> load() async {
    emit(const CoursesLoading());
    try {
      final courses = await _repository.loadCourses();
      if (!isClosed) emit(CoursesLoaded(courses));
    } on CatalogException catch (error) {
      debugPrint('$error');
      if (!isClosed) emit(const CoursesError());
    }
  }

  /// Filters the list by title or instructor. Ignored until the catalog
  /// has loaded.
  void search(String query) {
    if (state case final CoursesLoaded loaded) {
      emit(CoursesLoaded(loaded.courses, query: query));
    }
  }

  Course? courseById(String courseId) => switch (state) {
        CoursesLoaded(:final courses) => courses.where((c) => c.id == courseId).firstOrNull,
        _ => null,
      };
}
