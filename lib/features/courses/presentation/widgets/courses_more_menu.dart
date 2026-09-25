import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/l10n/l10n.dart';
import '../../../../core/widgets/app_popup_menu.dart';
import '../../../../core/widgets/confirm_dialog.dart';
import '../../../progress/presentation/cubit/progress_cubit.dart';

enum _MenuAction { resetProgress }

/// The "more" menu in the courses screen's app bar.
class CoursesMoreMenu extends StatelessWidget {
  const CoursesMoreMenu({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return AppPopupMenu<_MenuAction>(
      tooltip: l10n.moreOptions,
      onSelected: (action) => switch (action) {
        _MenuAction.resetProgress => _confirmReset(context),
      },
      items: [
        AppMenuItem(
          value: _MenuAction.resetProgress,
          label: l10n.resetProgress,
          icon: Icons.restart_alt,
          destructive: true,
        ),
      ],
    );
  }

  Future<void> _confirmReset(BuildContext context) async {
    final l10n = context.l10n;
    final progress = context.read<ProgressCubit>();
    final confirmed = await showConfirmDialog(
      context,
      title: l10n.resetProgress,
      message: l10n.resetProgressConfirm,
      confirmLabel: l10n.reset,
      destructive: true,
    );
    if (confirmed) await progress.reset();
  }
}
