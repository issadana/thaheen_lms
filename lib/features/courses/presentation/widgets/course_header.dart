import 'package:flutter/material.dart';

import '../../../../core/l10n/l10n.dart';
import '../../../../core/localization/localized_text_x.dart';
import '../../../../core/widgets/animated_progress_bar.dart';
import '../../../../core/widgets/primary_button.dart';
import '../../../progress/domain/lesson_progress.dart';
import '../../../progress/domain/progress_rules.dart';
import '../../domain/course.dart';
import 'course_thumbnail.dart';

/// Top of the course details screen: thumbnail, instructor, progress, and the
/// button for the lesson the student should watch next.
class CourseHeader extends StatelessWidget {
  const CourseHeader({
    super.key,
    required this.course,
    required this.progress,
    required this.onOpenLesson,
  });

  final Course course;
  final ProgressMap progress;
  final void Function(String lessonId) onOpenLesson;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final muted = theme.textTheme.bodyMedium?.copyWith(
      color: theme.colorScheme.onSurfaceVariant,
    );
    final action = courseAction(course, progress);

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              CourseThumbnail(
                path: course.thumbnail,
                size: 96,
                heroCourseId: course.id,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      course.instructor.of(context),
                      style: theme.textTheme.titleMedium,
                    ),
                    Text(l10n.lessonCount(course.lessonCount), style: muted),
                    const SizedBox(height: 12),
                    AnimatedProgressBar(
                      value: courseProgress(course, progress),
                      minHeight: 6,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      l10n.completedOfTotal(
                        completedLessonCount(course, progress),
                        course.lessonCount,
                      ),
                      style: muted,
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (action != null) ...[
            const SizedBox(height: 16),
            _CourseActionButton(
              action: action,
              onPressed: () => onOpenLesson(action.lesson.id),
            ),
          ],
        ],
      ),
    );
  }
}

/// Opens the lesson the student should watch next, so they don't have to
/// look for where they stopped.
class _CourseActionButton extends StatelessWidget {
  const _CourseActionButton({required this.action, required this.onPressed});

  final CourseAction action;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final (label, icon) = switch (action.kind) {
      CourseActionKind.start => (l10n.startCourse, Icons.play_arrow),
      CourseActionKind.resume => (
        l10n.continueLesson(action.lesson.title.of(context)),
        Icons.play_arrow,
      ),
      CourseActionKind.watchAgain => (l10n.watchAgain, Icons.replay),
    };

    return PrimaryButton(label: label, icon: icon, onPressed: onPressed);
  }
}
