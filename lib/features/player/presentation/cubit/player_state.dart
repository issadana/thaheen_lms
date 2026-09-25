import 'package:equatable/equatable.dart';

enum PlayerStatus { loading, ready, error }

class PlayerState extends Equatable {
  const PlayerState({
    this.status = PlayerStatus.loading,
    this.position = Duration.zero,
    this.duration = Duration.zero,
    this.isPlaying = false,
    this.isBuffering = false,
    this.speed = 1.0,
    this.isFullscreen = false,
    this.isScrubbing = false,
    this.controlsVisible = true,
    this.showCompletion = false,
  });

  final PlayerStatus status;
  final Duration position;
  final Duration duration;
  final bool isPlaying;
  final bool isBuffering;
  final double speed;
  final bool isFullscreen;

  /// True while the student drags the seek bar.
  final bool isScrubbing;

  /// Whether the fullscreen controls are showing. They fade out a few
  /// seconds into playback and come back on a tap or when paused.
  final bool controlsVisible;

  /// True for a moment after the lesson becomes completed, while the
  /// "Lesson completed" badge shows over the video.
  final bool showCompletion;

  PlayerState copyWith({
    PlayerStatus? status,
    Duration? position,
    Duration? duration,
    bool? isPlaying,
    bool? isBuffering,
    double? speed,
    bool? isFullscreen,
    bool? isScrubbing,
    bool? controlsVisible,
    bool? showCompletion,
  }) => PlayerState(
    status: status ?? this.status,
    position: position ?? this.position,
    duration: duration ?? this.duration,
    isPlaying: isPlaying ?? this.isPlaying,
    isBuffering: isBuffering ?? this.isBuffering,
    speed: speed ?? this.speed,
    isFullscreen: isFullscreen ?? this.isFullscreen,
    isScrubbing: isScrubbing ?? this.isScrubbing,
    controlsVisible: controlsVisible ?? this.controlsVisible,
    showCompletion: showCompletion ?? this.showCompletion,
  );

  @override
  List<Object?> get props => [
    status,
    position,
    duration,
    isPlaying,
    isBuffering,
    speed,
    isFullscreen,
    isScrubbing,
    controlsVisible,
    showCompletion,
  ];
}
