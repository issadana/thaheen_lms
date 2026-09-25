import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/l10n/l10n.dart';
import '../../../../core/config/orientation.dart';
import '../../../../core/localization/localized_text_x.dart';
import '../../../../core/widgets/state_views.dart';
import '../../../courses/domain/course.dart';
import '../../../courses/domain/lesson.dart';
import '../../../courses/presentation/widgets/catalog_gate.dart';
import '../../../notes/presentation/widgets/lesson_notes.dart';
import '../../../progress/domain/progress_rules.dart';
import '../../../progress/presentation/locked_lesson_message.dart';
import '../../../progress/presentation/cubit/progress_cubit.dart';
import '../../../settings/presentation/cubit/settings_cubit.dart';
import '../cubit/player_cubit.dart';
import '../widgets/center_play_button.dart';
import '../widgets/completion_badge.dart';
import '../widgets/lesson_info.dart';
import '../widgets/next_lesson_panel.dart';
import '../widgets/player_controls.dart';
import '../widgets/video_surface.dart';

class PlayerScreen extends StatelessWidget {
  const PlayerScreen({
    super.key,
    required this.courseId,
    required this.lessonId,
    required this.onOpenLesson,
  });

  final String courseId;
  final String lessonId;
  final void Function(String courseId, String lessonId) onOpenLesson;

  @override
  Widget build(BuildContext context) {
    return CatalogGate<(Course, Lesson)>(
      find: (courses) {
        final course = courses.courseById(courseId);
        final lesson = course?.lessonById(lessonId);
        return lesson == null ? null : (course!, lesson);
      },
      notFoundTitle: context.l10n.lessonNotFound,
      builder: (context, found) => _buildLesson(context, found.$1, found.$2),
    );
  }

  Widget _buildLesson(BuildContext context, Course course, Lesson lesson) {
    final progress = context.read<ProgressCubit>().state.lessons;
    if (!isLessonUnlocked(course, lesson.id, progress)) {
      return StatePage(
        child: MessageView(
          icon: Icons.lock_outline,
          title: context.l10n.lockedLessonTitle,
          message: lockedLessonMessage(context, course, progress),
        ),
      );
    }

    return BlocProvider(
      key: ValueKey('${course.id}/${lesson.id}'),
      create: (context) => PlayerCubit(
        courseId: course.id,
        lesson: lesson,
        progress: context.read<ProgressCubit>(),
        settings: context.read<SettingsCubit>(),
      )..initialize(),
      child: _PlayerView(
        course: course,
        lesson: lesson,
        onOpenLesson: onOpenLesson,
      ),
    );
  }
}

class _PlayerView extends StatefulWidget {
  const _PlayerView({
    required this.course,
    required this.lesson,
    required this.onOpenLesson,
  });

  final Course course;
  final Lesson lesson;
  final void Function(String courseId, String lessonId) onOpenLesson;

  @override
  State<_PlayerView> createState() => _PlayerViewState();
}

class _PlayerViewState extends State<_PlayerView> {
  late final AppLifecycleListener _lifecycle;
  bool _wasFullscreen = false;

  @override
  void initState() {
    super.initState();
    // Save when the app goes to the background, where it may be killed.
    _lifecycle = AppLifecycleListener(
      onHide: () => context.read<PlayerCubit>().saveProgress(),
    );
  }

  @override
  void dispose() {
    _lifecycle.dispose();
    _restoreSystemUi();
    super.dispose();
  }

  /// Landscape only happens through the fullscreen button. The orientation
  /// check keeps the fullscreen layout while the screen rotates back to
  /// portrait, instead of squeezing the portrait layout into landscape.
  bool _isFullscreen(PlayerState state) =>
      state.isFullscreen ||
      MediaQuery.orientationOf(context) == Orientation.landscape;

  Future<void> _toggleFullscreen() async {
    final cubit = context.read<PlayerCubit>();
    if (_isFullscreen(cubit.state)) {
      cubit.setFullscreen(false);
      await SystemChrome.setPreferredOrientations(appOrientations);
      await SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    } else {
      cubit.setFullscreen(true);
      await SystemChrome.setPreferredOrientations([
        DeviceOrientation.landscapeLeft,
        DeviceOrientation.landscapeRight,
      ]);
      await SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    }
  }

  /// Back to the portrait-only app. An empty list here would unlock every
  /// orientation, and the course screens would then rotate with the phone.
  void _restoreSystemUi() {
    SystemChrome.setPreferredOrientations(appOrientations);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<PlayerCubit>().state;
    final fullscreen = _isFullscreen(state);

    // Entering fullscreen (by the button or by rotating) starts with the
    // controls showing, then lets them fade out.
    if (fullscreen && !_wasFullscreen) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) context.read<PlayerCubit>().showControlsBriefly();
      });
    }
    _wasFullscreen = fullscreen;

    return PopScope(
      // In fullscreen, "back" leaves fullscreen instead of the screen.
      canPop: !fullscreen,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _toggleFullscreen();
      },
      child: fullscreen ? _buildFullscreen(state) : _buildPortrait(state),
    );
  }

  Widget _buildPortrait(PlayerState state) {
    // Size the video area to the video itself, capped at half the screen so
    // the controls stay visible even for portrait clips.
    final cubit = context.read<PlayerCubit>();
    final ready = state.status == PlayerStatus.ready;
    final screen = MediaQuery.sizeOf(context);
    final aspectRatio = ready
        ? cubit.controller?.value.aspectRatio ?? 16 / 9
        : 16 / 9;
    final videoHeight = math.min(
      screen.width / aspectRatio,
      screen.height * 0.5,
    );

    return Scaffold(
      appBar: AppBar(title: Text(widget.lesson.title.of(context))),
      body: ListView(
        children: [
          SizedBox(
            height: videoHeight,
            // Tapping the video plays or pauses it.
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: ready ? cubit.togglePlay : null,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  VideoSurface(poster: widget.course.thumbnail),
                  if (ready && !state.isPlaying && !state.isScrubbing)
                    const Center(child: CenterPlayButton()),
                  CompletionOverlay(visible: state.showCompletion),
                ],
              ),
            ),
          ),
          PlayerControls(onToggleFullscreen: _toggleFullscreen),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                LessonInfo(course: widget.course, lesson: widget.lesson),
                const SizedBox(height: 24),
                NextLessonPanel(
                  course: widget.course,
                  lesson: widget.lesson,
                  onOpenLesson: (lessonId) =>
                      widget.onOpenLesson(widget.course.id, lessonId),
                ),
                const SizedBox(height: 24),
                LessonNotes(
                  courseId: widget.course.id,
                  lessonId: widget.lesson.id,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFullscreen(PlayerState state) {
    final cubit = context.read<PlayerCubit>();
    final ready = state.status == PlayerStatus.ready;

    return Scaffold(
      backgroundColor: Colors.black,
      body: GestureDetector(
        // A tap anywhere that isn't a control only shows or hides the
        // controls; it never plays, pauses or seeks.
        behavior: HitTestBehavior.opaque,
        onTap: cubit.toggleControls,
        child: Stack(
          fit: StackFit.expand,
          children: [
            VideoSurface(poster: widget.course.thumbnail),
            // Only while the video is ready, so the error view's retry
            // button is never covered.
            if (ready)
              AnimatedOpacity(
                opacity: state.controlsVisible ? 1 : 0,
                duration: const Duration(milliseconds: 200),
                child: IgnorePointer(
                  ignoring: !state.controlsVisible,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      // While scrubbing, the dimming and the big button step
                      // aside so the frames under the finger are clear.
                      if (!state.isScrubbing) ...[
                        const ColoredBox(color: Colors.black38),
                        if (!state.isBuffering)
                          const Center(child: CenterPlayButton()),
                      ],
                      Align(
                        alignment: Alignment.bottomCenter,
                        // Keep the controls up while the student is using them.
                        child: Listener(
                          onPointerDown: (_) => cubit.holdControls(),
                          onPointerUp: (_) => cubit.scheduleHideControls(),
                          child: SafeArea(
                            top: false,
                            child: PlayerControls(
                              onToggleFullscreen: _toggleFullscreen,
                              onDark: true,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            // While loading or after an error the controls above are hidden,
            // but the student must still be able to leave fullscreen (iOS
            // has no back button). Placed where the controls' own
            // fullscreen button sits.
            if (!ready)
              Align(
                alignment: AlignmentDirectional.bottomEnd,
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsetsDirectional.fromSTEB(4, 0, 4, 4),
                    child: IconButton(
                      tooltip: context.l10n.exitFullscreen,
                      color: Colors.white,
                      onPressed: _toggleFullscreen,
                      icon: const Icon(Icons.fullscreen_exit),
                    ),
                  ),
                ),
              ),
            CompletionOverlay(visible: state.showCompletion),
          ],
        ),
      ),
    );
  }
}
