import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/l10n/l10n.dart';
import '../../../../core/utils/format_duration.dart';
import '../../../../core/widgets/app_popup_menu.dart';
import '../cubit/player_cubit.dart';

/// Play/pause, seek bar with times, speed menu and fullscreen toggle.
class PlayerControls extends StatelessWidget {
  const PlayerControls({
    super.key,
    required this.onToggleFullscreen,
    this.onDark = false,
  });

  final VoidCallback onToggleFullscreen;
  final bool onDark;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final cubit = context.read<PlayerCubit>();
    final state = context.watch<PlayerCubit>().state;
    final enabled = state.status == PlayerStatus.ready;
    final color = onDark
        ? Colors.white
        : Theme.of(context).colorScheme.onSurface;

    return IconTheme(
      data: IconThemeData(color: color),
      child: DefaultTextStyle.merge(
        style: TextStyle(color: color),
        child: Padding(
          padding: const EdgeInsetsDirectional.fromSTEB(4, 0, 4, 4),
          child: Row(
            children: [
              IconButton(
                tooltip: state.isPlaying ? l10n.pause : l10n.play,
                onPressed: enabled ? cubit.togglePlay : null,
                icon: Icon(state.isPlaying ? Icons.pause : Icons.play_arrow),
              ),
              Expanded(
                child: _SeekBar(state: state, enabled: enabled, onDark: onDark),
              ),
              _SpeedMenu(speed: state.speed, enabled: enabled),
              IconButton(
                tooltip: state.isFullscreen
                    ? l10n.exitFullscreen
                    : l10n.enterFullscreen,
                onPressed: onToggleFullscreen,
                icon: Icon(
                  state.isFullscreen ? Icons.fullscreen_exit : Icons.fullscreen,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SeekBar extends StatefulWidget {
  const _SeekBar({
    required this.state,
    required this.enabled,
    required this.onDark,
  });

  final PlayerState state;
  final bool enabled;
  final bool onDark;

  @override
  State<_SeekBar> createState() => _SeekBarState();
}

class _SeekBarState extends State<_SeekBar> {
  /// Where the thumb is while the student drags it. The thumb follows the
  /// finger directly; the video catches up as fast as seeking allows.
  double? _dragMs;

  @override
  Widget build(BuildContext context) {
    final maxMs = widget.state.duration.inMilliseconds.toDouble();
    final positionMs =
        (_dragMs ?? widget.state.position.inMilliseconds.toDouble()).clamp(
          0.0,
          maxMs > 0 ? maxMs : 0.0,
        );
    final timeStyle = Theme.of(context).textTheme.labelSmall?.copyWith(
      color: DefaultTextStyle.of(context).style.color,
      fontFeatures: const [FontFeature.tabularFigures()],
    );

    return Row(
      children: [
        // Times read left-to-right, like any clock, in both languages.
        Text(
          formatDuration(Duration(milliseconds: positionMs.round())),
          style: timeStyle,
          textDirection: TextDirection.ltr,
        ),
        // A Slider grows to fill any bounded height it is given. Without a
        // fixed height, in fullscreen it would cover the whole video, which
        // centres the controls and makes any tap on the video seek.
        Expanded(
          child: SizedBox(
            height: 48,
            child: SliderTheme(
              data: SliderTheme.of(context).copyWith(
                trackHeight: 3,
                thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 7),
                overlayShape: const RoundSliderOverlayShape(overlayRadius: 14),
                inactiveTrackColor: widget.onDark ? Colors.white30 : null,
              ),
              child: Slider(
                value: positionMs,
                max: maxMs > 0 ? maxMs : 1,
                // The video follows the thumb while dragging (scrubbing).
                onChangeStart: (_) => context.read<PlayerCubit>().startScrub(),
                onChanged: widget.enabled && maxMs > 0
                    ? (v) {
                        setState(() => _dragMs = v);
                        context.read<PlayerCubit>().scrubTo(
                          Duration(milliseconds: v.round()),
                        );
                      }
                    : null,
                onChangeEnd: (v) async {
                  await context.read<PlayerCubit>().endScrub(
                    Duration(milliseconds: v.round()),
                  );
                  if (mounted) setState(() => _dragMs = null);
                },
              ),
            ),
          ),
        ),
        Text(
          formatDuration(widget.state.duration),
          style: timeStyle,
          textDirection: TextDirection.ltr,
        ),
      ],
    );
  }
}

class _SpeedMenu extends StatelessWidget {
  const _SpeedMenu({required this.speed, required this.enabled});

  final double speed;
  final bool enabled;

  static String label(double speed) =>
      '${speed == speed.roundToDouble() ? speed.toInt() : speed}x';

  @override
  Widget build(BuildContext context) {
    return AppPopupMenu<double>(
      tooltip: context.l10n.playbackSpeed,
      enabled: enabled,
      selected: speed,
      onSelected: context.read<PlayerCubit>().setSpeed,
      items: [
        for (final s in playbackSpeeds)
          AppMenuItem(
            value: s,
            label: label(s),
            labelDirection: TextDirection.ltr,
          ),
      ],
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
        child: Text(
          label(speed),
          textDirection: TextDirection.ltr,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
