import 'package:flutter/material.dart';

/// The large call-to-action button, such as "Start course" or "Next lesson".
/// The label stays on one line and is cut with an ellipsis.
class PrimaryButton extends StatelessWidget {
  const PrimaryButton({
    super.key,
    required this.label,
    required this.icon,
    required this.onPressed,
    this.iconAlignment = IconAlignment.start,
  });

  final String label;
  final IconData icon;

  /// Null disables the button.
  final VoidCallback? onPressed;
  final IconAlignment iconAlignment;

  @override
  Widget build(BuildContext context) {
    return FilledButton.icon(
      style: FilledButton.styleFrom(padding: const EdgeInsets.all(16)),
      onPressed: onPressed,
      iconAlignment: iconAlignment,
      icon: Icon(icon),
      label: Text(label, maxLines: 1, overflow: TextOverflow.ellipsis),
    );
  }
}
