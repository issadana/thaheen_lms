import 'package:flutter/material.dart';

import '../../../../core/localization/localized_text_x.dart';
import '../../../courses/domain/course.dart';
import '../../../courses/domain/lesson.dart';

/// The lesson's title, with the course and section it belongs to below it.
class LessonInfo extends StatelessWidget {
  const LessonInfo({super.key, required this.course, required this.lesson});

  final Course course;
  final Lesson lesson;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final section = course.sectionOf(lesson.id);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          lesson.title.of(context),
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          [
            course.title.of(context),
            if (section != null) section.title.of(context),
          ].join('  •  '),
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}
