/// The learning rules of the app, as pure functions with no Flutter or
/// storage dependencies, so they can be unit tested directly.
library;

import '../../courses/domain/course.dart';
import '../../courses/domain/lesson.dart';
import 'lesson_progress.dart';
import 'lesson_status.dart';

/// A lesson counts as completed once 90% of it has been watched.
const completionThreshold = 0.9;

/// Reopening a lesson this close to the end starts it again from the beginning.
const restartMargin = Duration(seconds: 3);

bool reachesCompletion({
  required Duration position,
  required Duration duration,
}) {
  if (duration <= Duration.zero) return false;
  return position.inMilliseconds >=
      duration.inMilliseconds * completionThreshold;
}

/// Returns the progress after watching up to [position]. Completion is
/// sticky: seeking back after reaching 90% does not undo it.
LessonProgress applyPosition(
  LessonProgress? previous, {
  required Duration position,
  required Duration duration,
  required DateTime now,
}) {
  final clamped = position < Duration.zero
      ? Duration.zero
      : (duration > Duration.zero && position > duration ? duration : position);
  return LessonProgress(
    position: clamped,
    duration: duration,
    completed:
        (previous?.completed ?? false) ||
        reachesCompletion(position: clamped, duration: duration),
    updatedAt: now,
  );
}

LessonStatus lessonStatus(LessonProgress? progress) {
  if (progress == null) return LessonStatus.notStarted;
  if (progress.completed) return LessonStatus.completed;
  if (progress.position > Duration.zero) return LessonStatus.inProgress;
  return LessonStatus.notStarted;
}

bool isLessonCompleted(Course course, String lessonId, ProgressMap progress) =>
    progress[progressKey(course.id, lessonId)]?.completed ?? false;

/// Sequential unlock: the first lesson of a course is always open, and every
/// other lesson opens once the lesson before it (in watching order, across
/// section boundaries) is completed.
bool isLessonUnlocked(Course course, String lessonId, ProgressMap progress) {
  final lessons = course.lessons;
  final index = lessons.indexWhere((l) => l.id == lessonId);
  if (index < 0) return false;
  if (index == 0) return true;
  return isLessonCompleted(course, lessons[index - 1].id, progress);
}

Lesson? nextLesson(Course course, String lessonId) {
  final lessons = course.lessons;
  final index = lessons.indexWhere((l) => l.id == lessonId);
  if (index < 0 || index == lessons.length - 1) return null;
  return lessons[index + 1];
}

int completedLessonCount(Course course, ProgressMap progress) => course.lessons
    .where((l) => isLessonCompleted(course, l.id, progress))
    .length;

/// Course progress from 0 to 1: completed lessons divided by total lessons.
/// A course with no lessons has 0 progress.
double courseProgress(Course course, ProgressMap progress) {
  final total = course.lessonCount;
  if (total == 0) return 0;
  return completedLessonCount(course, progress) / total;
}

enum CourseActionKind { start, resume, watchAgain }

/// What the main button on the course details screen does.
class CourseAction {
  const CourseAction(this.kind, this.lesson);

  final CourseActionKind kind;
  final Lesson lesson;
}

/// The first lesson in [course] that isn't completed, or null when every
/// lesson is. It is always unlocked, because every lesson before it is
/// completed, so it is the lesson to finish to unlock the rest.
Lesson? firstUnfinishedLesson(Course course, ProgressMap progress) => course
    .lessons
    .where((l) => !isLessonCompleted(course, l.id, progress))
    .firstOrNull;

/// The lesson the student should open next in [course], or null when the
/// course has no lessons.
///
/// That is the first unfinished lesson. When the whole course is completed,
/// the first lesson is offered again.
CourseAction? courseAction(Course course, ProgressMap progress) {
  final lessons = course.lessons;
  if (lessons.isEmpty) return null;

  final next = firstUnfinishedLesson(course, progress);
  if (next == null) {
    return CourseAction(CourseActionKind.watchAgain, lessons.first);
  }
  final notStarted =
      next == lessons.first &&
      lessonStatus(progress[progressKey(course.id, next.id)]) ==
          LessonStatus.notStarted;
  return CourseAction(
    notStarted ? CourseActionKind.start : CourseActionKind.resume,
    next,
  );
}

/// Where a lesson should start playing when it is opened.
///
/// It resumes from the saved position, except when the student had
/// effectively finished it (within [restartMargin] of the end, or completed
/// and still past the 90% mark). In those cases it starts again from 0.
Duration resumePosition(LessonProgress? progress, Duration duration) {
  if (progress == null || progress.position <= Duration.zero) {
    return Duration.zero;
  }
  final position = progress.position;
  if (duration <= Duration.zero) return position;
  if (position >= duration - restartMargin) return Duration.zero;
  if (progress.completed &&
      reachesCompletion(position: position, duration: duration)) {
    return Duration.zero;
  }
  return position;
}

class ContinueWatching {
  const ContinueWatching({
    required this.course,
    required this.lesson,
    required this.progress,
  });

  final Course course;
  final Lesson lesson;
  final LessonProgress progress;
}

/// The most recently watched lesson that is started but not completed.
/// Progress for lessons that are no longer in the catalog is ignored.
ContinueWatching? continueWatching(List<Course> courses, ProgressMap progress) {
  ContinueWatching? latest;
  for (final course in courses) {
    for (final lesson in course.lessons) {
      final p = progress[progressKey(course.id, lesson.id)];
      if (lessonStatus(p) != LessonStatus.inProgress) continue;
      if (latest == null || p!.updatedAt.isAfter(latest.progress.updatedAt)) {
        latest = ContinueWatching(course: course, lesson: lesson, progress: p!);
      }
    }
  }
  return latest;
}
