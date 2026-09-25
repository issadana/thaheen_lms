import 'package:equatable/equatable.dart';

import '../../domain/lesson_progress.dart';

class ProgressState extends Equatable {
  const ProgressState(this.lessons);

  final ProgressMap lessons;

  LessonProgress? of(String courseId, String lessonId) =>
      lessons[progressKey(courseId, lessonId)];

  @override
  List<Object?> get props => [lessons];
}
