import 'package:flutter/widgets.dart';

import '../../../core/l10n/l10n.dart';
import '../../../core/localization/localized_text_x.dart';
import '../../courses/domain/course.dart';
import '../domain/lesson_progress.dart';
import '../domain/progress_rules.dart';

/// Explains why a lesson is locked by naming the lesson to finish first.
String lockedLessonMessage(
  BuildContext context,
  Course course,
  ProgressMap progress,
) {
  final l10n = context.l10n;
  final lesson = firstUnfinishedLesson(course, progress);
  return lesson == null
      ? l10n.lockedLessonMessage
      : l10n.lockedLessonFinishFirst(lesson.title.of(context));
}
