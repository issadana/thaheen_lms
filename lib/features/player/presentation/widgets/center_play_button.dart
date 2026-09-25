import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/l10n/l10n.dart';
import '../cubit/player_cubit.dart';

/// The large round play/pause button in the middle of the video.
class CenterPlayButton extends StatelessWidget {
  const CenterPlayButton({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final isPlaying = context.select(
      (PlayerCubit cubit) => cubit.state.isPlaying,
    );
    return IconButton(
      tooltip: isPlaying ? l10n.pause : l10n.play,
      iconSize: 44,
      style: IconButton.styleFrom(
        backgroundColor: Colors.black54,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.all(12),
      ),
      onPressed: context.read<PlayerCubit>().togglePlay,
      icon: Icon(isPlaying ? Icons.pause : Icons.play_arrow),
    );
  }
}
