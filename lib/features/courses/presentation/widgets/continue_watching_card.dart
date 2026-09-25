import 'package:flutter/material.dart';

import '../../../../core/l10n/l10n.dart';
import '../../../../core/localization/localized_text_x.dart';
import '../../../../core/utils/format_duration.dart';
import '../../../../core/widgets/animated_progress_bar.dart';
import '../../../progress/domain/progress_rules.dart';
import 'course_thumbnail.dart';

class ContinueWatchingCard extends StatelessWidget {
  const ContinueWatchingCard({super.key, required this.item, required this.onTap});

  final ContinueWatching item;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final progress = item.progress;

    return Card(
      color: colors.primaryContainer,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                context.l10n.continueWatching,
                style: theme.textTheme.labelLarge?.copyWith(color: colors.onPrimaryContainer),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  CourseThumbnail(path: item.course.thumbnail, size: 56),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.lesson.title.of(context),
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: colors.onPrimaryContainer,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          item.course.title.of(context),
                          style: theme.textTheme.bodySmall?.copyWith(color: colors.onPrimaryContainer),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Icon(Icons.play_circle_fill, size: 44, color: colors.primary),
                ],
              ),
              const SizedBox(height: 12),
              AnimatedProgressBar(
                value: progress.watchedFraction,
                minHeight: 4,
                backgroundColor: colors.onPrimaryContainer.withValues(alpha: 0.15),
              ),
              const SizedBox(height: 4),
              // Times are always shown left-to-right, like any clock.
              Text(
                '${formatDuration(progress.position)} / ${formatDuration(progress.duration)}',
                textDirection: TextDirection.ltr,
                style: theme.textTheme.bodySmall?.copyWith(color: colors.onPrimaryContainer),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
