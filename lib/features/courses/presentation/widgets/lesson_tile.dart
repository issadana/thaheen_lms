import 'package:flutter/material.dart';

import '../../../../core/l10n/l10n.dart';
import '../../../../core/localization/localized_text_x.dart';
import '../../../../core/utils/format_duration.dart';
import '../../../progress/domain/lesson_progress.dart';
import '../../../progress/domain/lesson_status.dart';
import '../../domain/lesson.dart';

class LessonTile extends StatelessWidget {
  const LessonTile({
    super.key,
    required this.lesson,
    required this.status,
    required this.locked,
    required this.progress,
    required this.onTap,
  });

  final Lesson lesson;
  final LessonStatus status;
  final bool locked;
  final LessonProgress? progress;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final colors = Theme.of(context).colorScheme;
    final statusLabel = locked
        ? l10n.statusLocked
        : switch (status) {
            LessonStatus.notStarted => l10n.statusNotStarted,
            LessonStatus.inProgress => l10n.statusInProgress,
            LessonStatus.completed => l10n.statusCompleted,
          };

    return ListTile(
      onTap: onTap,
      contentPadding: const EdgeInsetsDirectional.only(start: 16, end: 12),
      leading: _StatusIcon(status: status, locked: locked, progress: progress),
      title: Text(
        lesson.title.of(context),
        style: TextStyle(color: locked ? colors.onSurfaceVariant : null),
      ),
      subtitle: Row(
        children: [
          Icon(Icons.schedule, size: 14, color: colors.onSurfaceVariant),
          const SizedBox(width: 4),
          Text(formatDuration(lesson.duration), textDirection: TextDirection.ltr),
          const Text('  •  '),
          Flexible(child: Text(statusLabel)),
        ],
      ),
    );
  }
}

class _StatusIcon extends StatelessWidget {
  const _StatusIcon({required this.status, required this.locked, required this.progress});

  final LessonStatus status;
  final bool locked;
  final LessonProgress? progress;

  /// The icon pops in with a scale and fade whenever it changes, for example
  /// when a lesson unlocks or is completed.
  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 400),
      switchInCurve: Curves.easeOutBack,
      switchOutCurve: Curves.easeIn,
      transitionBuilder: (child, animation) => FadeTransition(
        opacity: animation,
        child: ScaleTransition(scale: animation, child: child),
      ),
      // Keyed by what the icon shows, so a changing in-progress ring
      // doesn't restart the transition.
      child: KeyedSubtree(
        key: ValueKey((locked, status)),
        child: _icon(context),
      ),
    );
  }

  Widget _icon(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    if (locked) return Icon(Icons.lock_outline, color: colors.outline, size: 28);
    return switch (status) {
      LessonStatus.completed => Icon(Icons.check_circle, color: colors.primary, size: 28),
      LessonStatus.notStarted => Icon(Icons.play_circle_outline, color: colors.primary, size: 28),
      LessonStatus.inProgress => SizedBox.square(
          dimension: 28,
          child: Stack(
            alignment: Alignment.center,
            children: [
              CircularProgressIndicator(
                value: progress?.watchedFraction ?? 0,
                strokeWidth: 3,
                backgroundColor: colors.surfaceContainerHighest,
              ),
              Icon(Icons.play_arrow, size: 16, color: colors.primary),
            ],
          ),
        ),
    };
  }
}
