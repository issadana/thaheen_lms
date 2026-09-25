import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/l10n/l10n.dart';
import '../../../../core/localization/localized_text_x.dart';
import '../../../../core/widgets/primary_button.dart';
import '../../../courses/domain/course.dart';
import '../../../courses/domain/lesson.dart';
import '../../../progress/domain/progress_rules.dart';
import '../../../progress/presentation/cubit/progress_cubit.dart';

/// "Next lesson" button that follows the unlock rule: it stays disabled,
/// with a hint, until the current lesson is completed.
class NextLessonPanel extends StatelessWidget {
  const NextLessonPanel({
    super.key,
    required this.course,
    required this.lesson,
    required this.onOpenLesson,
  });

  final Course course;
  final Lesson lesson;
  final void Function(String lessonId) onOpenLesson;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final progress = context.watch<ProgressCubit>().state.lessons;
    final next = nextLesson(course, lesson.id);
    final completed = isLessonCompleted(course, lesson.id, progress);

    if (next == null) {
      if (!completed) return const SizedBox.shrink();
      return Card(
        color: theme.colorScheme.primaryContainer,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Text(
            l10n.courseCompleted,
            style: theme.textTheme.titleSmall?.copyWith(
              color: theme.colorScheme.onPrimaryContainer,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    final unlocked = isLessonUnlocked(course, next.id, progress);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        PrimaryButton(
          onPressed: unlocked ? () => onOpenLesson(next.id) : null,
          iconAlignment: IconAlignment.end,
          icon: unlocked ? Icons.arrow_forward : Icons.lock_outline,
          label: '${l10n.nextLesson}: ${next.title.of(context)}',
        ),
        if (!unlocked) ...[
          const SizedBox(height: 8),
          Text(
            l10n.nextLessonLockedHint,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ],
    );
  }
}
