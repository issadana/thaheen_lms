import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/l10n/l10n.dart';
import '../../../../core/localization/localized_text_x.dart';
import '../../../../core/widgets/app_snack_bar.dart';
import '../../../../core/widgets/state_views.dart';
import '../../../progress/domain/lesson_progress.dart';
import '../../../progress/domain/progress_rules.dart';
import '../../../progress/presentation/locked_lesson_message.dart';
import '../../../progress/presentation/cubit/progress_cubit.dart';
import '../../domain/course.dart';
import '../widgets/catalog_gate.dart';
import '../widgets/course_header.dart';
import '../widgets/lesson_tile.dart';

class CourseDetailsScreen extends StatelessWidget {
  const CourseDetailsScreen({
    super.key,
    required this.courseId,
    required this.onOpenLesson,
  });

  final String courseId;
  final void Function(String courseId, String lessonId) onOpenLesson;

  @override
  Widget build(BuildContext context) {
    return CatalogGate(
      find: (courses) => courses.courseById(courseId),
      notFoundTitle: context.l10n.courseNotFound,
      builder: (context, course) => Scaffold(
        appBar: AppBar(title: Text(course.title.of(context))),
        body: _CourseBody(course: course, onOpenLesson: onOpenLesson),
      ),
    );
  }
}

class _CourseBody extends StatelessWidget {
  const _CourseBody({required this.course, required this.onOpenLesson});

  final Course course;
  final void Function(String courseId, String lessonId) onOpenLesson;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final progress = context.watch<ProgressCubit>().state.lessons;

    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: CourseHeader(
            course: course,
            progress: progress,
            onOpenLesson: (lessonId) => onOpenLesson(course.id, lessonId),
          ),
        ),
        if (course.lessonCount == 0)
          SliverFillRemaining(
            hasScrollBody: false,
            child: MessageView(
              icon: Icons.video_library_outlined,
              title: l10n.emptyCourse,
            ),
          )
        else
          for (final section in course.sections) ...[
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsetsDirectional.fromSTEB(16, 20, 16, 4),
                child: Text(
                  section.title.of(context),
                  style: theme.textTheme.titleSmall?.copyWith(
                    color: theme.colorScheme.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            if (section.lessons.isEmpty)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsetsDirectional.fromSTEB(16, 8, 16, 8),
                  child: Text(
                    l10n.emptySection,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
              )
            else
              SliverList.list(
                children: [
                  for (final lesson in section.lessons)
                    Builder(
                      builder: (context) {
                        final lessonProgress =
                            progress[progressKey(course.id, lesson.id)];
                        final locked = !isLessonUnlocked(
                          course,
                          lesson.id,
                          progress,
                        );
                        return LessonTile(
                          lesson: lesson,
                          status: lessonStatus(lessonProgress),
                          locked: locked,
                          progress: lessonProgress,
                          onTap: locked
                              ? () => _showLockedMessage(context, progress)
                              : () => onOpenLesson(course.id, lesson.id),
                        );
                      },
                    ),
                ],
              ),
          ],
        const SliverPadding(padding: EdgeInsets.only(bottom: 24)),
      ],
    );
  }

  void _showLockedMessage(BuildContext context, ProgressMap progress) {
    // A light tap tells the student the lock is deliberate, not a dead button.
    HapticFeedback.lightImpact();
    showAppSnackBar(
      context,
      lockedLessonMessage(context, course, progress),
      icon: Icons.lock_outline,
    );
  }
}
