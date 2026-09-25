import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:video_player/video_player.dart';

import '../../../../core/l10n/l10n.dart';
import '../cubit/player_cubit.dart';

/// The black video area: the poster with a spinner while loading, the video
/// when ready, and a friendly message with a retry button when the file
/// can't be played. The poster fades into the video.
class VideoSurface extends StatelessWidget {
  const VideoSurface({super.key, this.poster});

  final String? poster;

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<PlayerCubit>();
    final state = context.watch<PlayerCubit>().state;
    final controller = cubit.controller;

    return ColoredBox(
      color: Colors.black,
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        child: switch (state.status) {
          PlayerStatus.loading => _Poster(
            key: const ValueKey('poster'),
            path: poster,
          ),
          PlayerStatus.error => const Center(child: _VideoError()),
          PlayerStatus.ready when controller == null => const SizedBox.shrink(),
          PlayerStatus.ready => Center(
            key: const ValueKey('video'),
            child: AspectRatio(
              aspectRatio: controller!.value.aspectRatio,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  VideoPlayer(controller),
                  if (state.isBuffering)
                    const Center(
                      child: CircularProgressIndicator(color: Colors.white),
                    ),
                ],
              ),
            ),
          ),
        },
      ),
    );
  }
}

/// The course image, dimmed so the white spinner on top stays visible.
class _Poster extends StatelessWidget {
  const _Poster({super.key, required this.path});

  final String? path;

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        if (path != null)
          Image.asset(
            path!,
            fit: BoxFit.cover,
            color: Colors.black54,
            colorBlendMode: BlendMode.darken,
            errorBuilder: (_, _, _) => const SizedBox.shrink(),
          ),
        const Center(child: CircularProgressIndicator(color: Colors.white)),
      ],
    );
  }
}

class _VideoError extends StatelessWidget {
  const _VideoError();

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.videocam_off_outlined,
            color: Colors.white70,
            size: 40,
          ),
          const SizedBox(height: 12),
          Text(
            l10n.videoErrorTitle,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          Text(
            l10n.videoErrorMessage,
            style: const TextStyle(color: Colors.white70),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          OutlinedButton.icon(
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.white,
              side: const BorderSide(color: Colors.white54),
            ),
            onPressed: context.read<PlayerCubit>().initialize,
            icon: const Icon(Icons.refresh),
            label: Text(l10n.retry),
          ),
        ],
      ),
    );
  }
}
