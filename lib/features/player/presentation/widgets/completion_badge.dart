import 'package:flutter/material.dart';

import '../../../../core/l10n/l10n.dart';

/// Fades the [CompletionBadge] in over the video while [visible]. It never
/// takes taps, so the video and controls under it keep working.
class CompletionOverlay extends StatelessWidget {
  const CompletionOverlay({super.key, required this.visible});

  final bool visible;

  @override
  Widget build(BuildContext context) => IgnorePointer(
    child: AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      child: visible
          ? const Center(key: ValueKey('completed'), child: CompletionBadge())
          : const SizedBox.shrink(),
    ),
  );
}

/// "Lesson completed" celebration shown over the video
class CompletionBadge extends StatelessWidget {
  const CompletionBadge({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: const Duration(milliseconds: 700),
      curve: Curves.elasticOut,
      builder: (context, scale, child) =>
          Transform.scale(scale: scale, child: child),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.7),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.check_circle, color: colors.primaryContainer, size: 56),
            const SizedBox(height: 8),
            Text(
              context.l10n.lessonCompleted,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
