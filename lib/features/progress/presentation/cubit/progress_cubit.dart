import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/progress_store.dart';
import '../../domain/lesson_progress.dart';
import '../../domain/progress_rules.dart';
import 'progress_state.dart';

export 'progress_state.dart';

/// The single source of truth for lesson progress. Screens read it and derive
/// statuses, locks and percentages with the functions in `progress_rules.dart`.
class ProgressCubit extends Cubit<ProgressState> {
  ProgressCubit(this._store, {DateTime Function()? clock})
    : _clock = clock ?? DateTime.now,
      super(ProgressState(_store.load()));

  final ProgressStore _store;
  final DateTime Function() _clock;

  /// Records that [lessonId] was watched up to [position] and saves it.
  Future<void> recordPosition({
    required String courseId,
    required String lessonId,
    required Duration position,
    required Duration duration,
  }) async {
    final key = progressKey(courseId, lessonId);
    final previous = state.lessons[key];
    final updated = applyPosition(
      previous,
      position: position,
      duration: duration,
      now: _clock(),
    );
    if (previous != null &&
        previous.position == updated.position &&
        previous.completed == updated.completed) {
      return; // Nothing new to save.
    }
    final lessons = Map<String, LessonProgress>.unmodifiable({
      ...state.lessons,
      key: updated,
    });
    emit(ProgressState(lessons));
    await _store.save(lessons);
  }

  Future<void> reset() async {
    emit(const ProgressState({}));
    await _store.clear();
  }
}
