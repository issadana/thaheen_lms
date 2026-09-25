import 'package:flutter/material.dart';

/// Shows [message] with an optional leading [icon], replacing any snackbar
/// already on screen so quick repeated taps don't queue up.
void showAppSnackBar(BuildContext context, String message, {IconData? icon}) {
  final colors = Theme.of(context).colorScheme;
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(
      SnackBar(
        content: Row(
          children: [
            if (icon != null) ...[
              Icon(icon, color: colors.onInverseSurface),
              const SizedBox(width: 12),
            ],
            Expanded(child: Text(message)),
          ],
        ),
      ),
    );
}
