import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/l10n/l10n.dart';
import '../cubit/settings_cubit.dart';

class SettingsActions extends StatelessWidget {
  const SettingsActions({super.key});

  @override
  Widget build(BuildContext context) {
    final settings = context.read<SettingsCubit>();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        TextButton(
          onPressed: settings.toggleLanguage,
          child: Text(context.l10n.switchLanguage),
        ),
        IconButton(
          tooltip: context.l10n.toggleTheme,
          onPressed: () =>
              settings.setThemeMode(isDark ? ThemeMode.light : ThemeMode.dark),
          icon: AnimatedSwitcher(
            duration: const Duration(milliseconds: 350),
            transitionBuilder: (child, animation) => RotationTransition(
              turns: Tween(begin: 0.75, end: 1.0).animate(animation),
              child: FadeTransition(opacity: animation, child: child),
            ),
            child: Icon(
              isDark ? Icons.light_mode_outlined : Icons.dark_mode_outlined,
              key: ValueKey(isDark),
            ),
          ),
        ),
      ],
    );
  }
}
