import 'package:flutter/material.dart';

/// A [LinearProgressIndicator] that fills up from empty when it first
/// appears, and glides to each new value after that.
class AnimatedProgressBar extends StatelessWidget {
  const AnimatedProgressBar({
    super.key,
    required this.value,
    this.minHeight = 6,
    this.backgroundColor,
  });

  /// From 0 to 1.
  final double value;
  final double minHeight;
  final Color? backgroundColor;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: value),
      duration: const Duration(milliseconds: 700),
      curve: Curves.easeOutCubic,
      builder: (context, animated, _) => LinearProgressIndicator(
        value: animated,
        minHeight: minHeight,
        borderRadius: BorderRadius.circular(minHeight / 2),
        backgroundColor: backgroundColor,
      ),
    );
  }
}
