import 'package:flutter/material.dart';

import '../../../../core/l10n/l10n.dart';
import '../../../../core/localization/localized_text_x.dart';
import '../../../../core/widgets/animated_progress_bar.dart';
import '../../domain/course.dart';
import 'course_thumbnail.dart';

class CourseCard extends StatelessWidget {
  const CourseCard({
    super.key,
    required this.course,
    required this.progress,
    required this.onTap,
  });

  final Course course;

  /// From 0 to 1.
  final double progress;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = context.l10n;
    final muted = theme.textTheme.bodySmall?.copyWith(
      color: theme.colorScheme.onSurfaceVariant,
    );
    final percent = (progress * 100).round();

    return Card(
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              CourseThumbnail(path: course.thumbnail, heroCourseId: course.id),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      course.title.of(context),
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        Icon(
                          Icons.person_outline,
                          size: 16,
                          color: muted?.color,
                        ),
                        const SizedBox(width: 4),
                        Flexible(
                          child: Text(
                            course.instructor.of(context),
                            style: muted,
                          ),
                        ),
                        Text('  •  ', style: muted),
                        Text(
                          l10n.lessonCount(course.lessonCount),
                          style: muted,
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: AnimatedProgressBar(
                            value: progress,
                            minHeight: 6,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(l10n.percentComplete(percent), style: muted),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
