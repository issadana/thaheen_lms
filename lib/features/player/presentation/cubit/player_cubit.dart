import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:video_player/video_player.dart';
import '../../../courses/domain/lesson.dart';
import '../../../progress/domain/progress_rules.dart';
import '../../../progress/presentation/cubit/progress_cubit.dart';
import '../../../settings/presentation/cubit/settings_cubit.dart';
import 'player_state.dart';

export 'player_state.dart';

const playbackSpeeds = <double>[1, 1.25, 1.5, 2];

typedef VideoControllerFactory =
    VideoPlayerController Function(String assetPath);

class PlayerCubit extends Cubit<PlayerState> {
  PlayerCubit({
    required this.courseId,
    required this.lesson,
    required ProgressCubit progress,
    required SettingsCubit settings,
    VideoControllerFactory? controllerFactory,
  }) : _progress = progress,
       _settings = settings,
       _controllerFactory = controllerFactory ?? VideoPlayerController.asset,
       super(
         PlayerState(
           speed: playbackSpeeds.contains(settings.state.playbackSpeed)
               ? settings.state.playbackSpeed
               : 1,
         ),
       );

  /// While playing, the position is saved at least this often, so a crash
  /// or a killed app loses at most a few seconds.
  static const saveInterval = Duration(seconds: 5);
  /// How long the fullscreen controls stay up once playback is running.
  static const hideControlsDelay = Duration(seconds: 3);
  /// How long the "Lesson completed" badge stays over the video.
  static const completionBadgeDuration = Duration(milliseconds: 2200);

  final String courseId;
  final Lesson lesson;
  final ProgressCubit _progress;
  final SettingsCubit _settings;
  final VideoControllerFactory _controllerFactory;
  final Stopwatch _sinceLastSave = Stopwatch();

  VideoPlayerController? _controller;
  Timer? _hideControlsTimer;
  Timer? _completionTimer;

  VideoPlayerController? get controller => _controller;

  Future<void> initialize() async {
    await _disposeController();
    emit(state.copyWith(status: PlayerStatus.loading));

    final controller = _controllerFactory(lesson.video);
    _controller = controller;
    try {
      await controller.initialize();
      if (isClosed) return;
      final duration = controller.value.duration;
      final start = resumePosition(
        _progress.state.of(courseId, lesson.id),
        duration,
      );
      if (start > Duration.zero) await controller.seekTo(start);
      await controller.setPlaybackSpeed(state.speed);
      if (isClosed) return;
      controller.addListener(_onControllerChanged);
      emit(
        state.copyWith(
          status: PlayerStatus.ready,
          position: start,
          duration: duration,
        ),
      );
      _sinceLastSave
        ..reset()
        ..start();
      await controller.play();
    } catch (error) {
      // Missing or corrupt files end up here (a PlatformException from the
      // native player). Show the friendly error state instead of crashing.
      debugPrint('Could not play ${lesson.video}: $error');
      if (isClosed) return;
      await _disposeController();
      emit(state.copyWith(status: PlayerStatus.error, isPlaying: false));
    }
  }

  void _onControllerChanged() {
    final controller = _controller;
    if (controller == null || isClosed) return;
    final value = controller.value;
    if (value.hasError) {
      debugPrint(
        'Playback error in ${lesson.video}: ${value.errorDescription}',
      );
      emit(state.copyWith(status: PlayerStatus.error, isPlaying: false));
      return;
    }
    final wasPlaying = state.isPlaying;
    emit(
      state.copyWith(
        position: value.position,
        duration: value.duration,
        isPlaying: value.isPlaying,
        isBuffering: value.isBuffering,
      ),
    );
    // Controls fade out once playback runs, and stay up while paused.
    if (value.isPlaying != wasPlaying) {
      value.isPlaying ? scheduleHideControls() : showControls();
    }

    // Positions seen while scrubbing are only previews: nothing is saved, so
    // dragging past 90% and back doesn't complete the lesson.
    if (state.isScrubbing) return;

    final justReached90 =
        !_isCompleted &&
        reachesCompletion(position: value.position, duration: value.duration);
    final dueForSave =
        value.isPlaying && _sinceLastSave.elapsed >= saveInterval;
    if (justReached90 || value.isCompleted || dueForSave) saveProgress();
  }

  /// Saves the current position. Also called when the app goes to the
  /// background and when the screen closes.
  Future<void> saveProgress() async {
    final controller = _controller;
    if (controller == null || !controller.value.isInitialized) return;
    _sinceLastSave
      ..reset()
      ..start();
    final wasCompleted = _isCompleted;
    await _progress.recordPosition(
      courseId: courseId,
      lessonId: lesson.id,
      position: controller.value.position,
      duration: controller.value.duration,
    );
    if (!wasCompleted && _isCompleted && !isClosed) _celebrateCompletion();
  }

  bool get _isCompleted =>
      _progress.state.of(courseId, lesson.id)?.completed ?? false;

  /// Shows the "Lesson completed" badge for a moment.
  void _celebrateCompletion() {
    emit(state.copyWith(showCompletion: true));
    _completionTimer?.cancel();
    _completionTimer = Timer(completionBadgeDuration, () {
      if (!isClosed) emit(state.copyWith(showCompletion: false));
    });
  }

  Future<void> togglePlay() async {
    final controller = _controller;
    if (controller == null || state.status != PlayerStatus.ready) return;
    if (controller.value.isPlaying) {
      await controller.pause();
      await saveProgress();
    } else {
      if (controller.value.isCompleted) await controller.seekTo(Duration.zero);
      await controller.play();
    }
  }

  Future<void> seekTo(Duration position) async {
    final controller = _controller;
    if (controller == null || state.status != PlayerStatus.ready) return;
    await controller.seekTo(position);
    await saveProgress();
  }

  // Scrubbing: while the student drags the seek bar, the video pauses and
  // jumps to each new position, so the picture follows their finger. When
  // they let go it seeks for real, saves, and resumes if it was playing.

  bool _resumeAfterScrub = false;
  bool _scrubSeekRunning = false;
  Duration? _pendingScrub;

  Future<void> startScrub() async {
    final controller = _controller;
    if (controller == null || state.status != PlayerStatus.ready) return;
    _resumeAfterScrub = controller.value.isPlaying;
    emit(state.copyWith(isScrubbing: true));
    await controller.pause();
  }

  /// Shows the frame at [position]. Seeks can't keep up with a finger, so
  /// while one is running only the latest requested position is kept, and
  /// the positions in between are skipped.
  Future<void> scrubTo(Duration position) async {
    final controller = _controller;
    if (controller == null || !state.isScrubbing) return;
    if (_scrubSeekRunning) {
      _pendingScrub = position;
      return;
    }
    _scrubSeekRunning = true;
    Duration? next = position;
    while (next != null && identical(controller, _controller)) {
      _pendingScrub = null;
      await controller.seekTo(next);
      next = _pendingScrub;
    }
    _scrubSeekRunning = false;
  }

  Future<void> endScrub(Duration position) async {
    final controller = _controller;
    _pendingScrub = null;
    if (controller == null || !state.isScrubbing) return;
    emit(state.copyWith(isScrubbing: false));
    await seekTo(position);
    if (_resumeAfterScrub && !isClosed) await controller.play();
  }

  Future<void> setSpeed(double speed) async {
    await _controller?.setPlaybackSpeed(speed);
    emit(state.copyWith(speed: speed));
    await _settings.setPlaybackSpeed(speed);
  }

  void setFullscreen(bool fullscreen) =>
      emit(state.copyWith(isFullscreen: fullscreen));

  // Fullscreen controls behave like YouTube's: a tap on the video shows or
  // hides them, they fade out a few seconds into playback, and they stay on
  // screen while the video is paused.

  void toggleControls() =>
      state.controlsVisible ? hideControls() : showControlsBriefly();

  void showControls() {
    _hideControlsTimer?.cancel();
    emit(state.copyWith(controlsVisible: true));
  }

  void hideControls() {
    _hideControlsTimer?.cancel();
    emit(state.copyWith(controlsVisible: false));
  }

  void showControlsBriefly() {
    emit(state.copyWith(controlsVisible: true));
    scheduleHideControls();
  }

  /// Hides the controls after [hideControlsDelay], if the video is still
  /// playing by then.
  void scheduleHideControls() {
    _hideControlsTimer?.cancel();
    _hideControlsTimer = Timer(hideControlsDelay, () {
      if (!isClosed && state.isPlaying) {
        emit(state.copyWith(controlsVisible: false));
      }
    });
  }

  /// Keeps the controls up while the student is touching them.
  void holdControls() => _hideControlsTimer?.cancel();

  Future<void> _disposeController() async {
    final controller = _controller;
    _controller = null;
    if (controller == null) return;
    controller.removeListener(_onControllerChanged);
    await controller.dispose();
  }

  @override
  Future<void> close() async {
    await saveProgress();
    await _disposeController();
    _hideControlsTimer?.cancel();
    _completionTimer?.cancel();
    return super.close();
  }
}
