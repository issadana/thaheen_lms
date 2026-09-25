import 'package:flutter/material.dart';

/// One entry of an [AppPopupMenu].
class AppMenuItem<T> {
  const AppMenuItem({
    required this.value,
    required this.label,
    this.icon,
    this.destructive = false,
    this.labelDirection,
  });

  final T value;
  final String label;
  final IconData? icon;
  final bool destructive;
  final TextDirection? labelDirection;
}

/// The app's popup menu: rounded, opens just under its button, with optional
/// leading icons and a check mark on the [selected] item.
///
/// Without a [child] the button is the usual "more" icon.
class AppPopupMenu<T> extends StatelessWidget {
  const AppPopupMenu({
    super.key,
    required this.items,
    required this.onSelected,
    this.selected,
    this.tooltip,
    this.enabled = true,
    this.child,
  });

  final List<AppMenuItem<T>> items;
  final ValueChanged<T> onSelected;
  final T? selected;
  final String? tooltip;
  final bool enabled;
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return PopupMenuButton<T>(
      tooltip: tooltip,
      enabled: enabled,
      initialValue: selected,
      onSelected: onSelected,
      position: PopupMenuPosition.under,
      offset: const Offset(0, 4),
      elevation: 3,
      color: colors.surfaceContainer,
      surfaceTintColor: Colors.transparent,
      constraints: const BoxConstraints(minWidth: 168),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      menuPadding: const EdgeInsets.symmetric(vertical: 6),
      itemBuilder: (context) => [
        for (final item in items)
          PopupMenuItem<T>(
            value: item.value,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: _MenuRow(item: item, selected: item.value == selected),
          ),
      ],
      icon: child == null ? const Icon(Icons.more_vert) : null,
      child: child,
    );
  }
}

class _MenuRow extends StatelessWidget {
  const _MenuRow({required this.item, required this.selected});

  final AppMenuItem<Object?> item;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final color = item.destructive
        ? colors.error
        : selected
        ? colors.primary
        : colors.onSurface;

    return Row(
      children: [
        if (item.icon != null) ...[
          Icon(item.icon, size: 20, color: color),
          const SizedBox(width: 12),
        ],
        Expanded(
          child: Text(
            item.label,
            textDirection: item.labelDirection,
            style: theme.textTheme.bodyLarge?.copyWith(
              color: color,
              fontWeight: selected ? FontWeight.w600 : null,
            ),
          ),
        ),
        // Space is kept for the check on every row so labels line up.
        const SizedBox(width: 12),
        SizedBox(
          width: 20,
          child: selected ? Icon(Icons.check, size: 20, color: color) : null,
        ),
      ],
    );
  }
}
