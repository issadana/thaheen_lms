import 'package:flutter_test/flutter_test.dart';
import 'package:thaheen_lms/features/progress/domain/lesson_progress.dart';
import 'package:thaheen_lms/features/progress/domain/progress_rules.dart';

import '../../../helpers/fixtures.dart';

void main() {
  final course = sampleCourse(); // s1 = [l1, l2], s2 = [l3]
  String key(String lessonId) => progressKey(course.id, lessonId);

  group('90% completion rule', () {
    const minute = Duration(minutes: 1);

    test('is reached at exactly 90%', () {
      expect(
        reachesCompletion(
          position: const Duration(seconds: 54),
          duration: minute,
        ),
        isTrue,
      );
    });

    test('is not reached just below 90%', () {
      expect(
        reachesCompletion(
          position: const Duration(milliseconds: 53999),
          duration: minute,
        ),
        isFalse,
      );
    });

    test('completion stays when the student seeks back', () {
      final completed = applyPosition(
        null,
        position: const Duration(seconds: 55),
        duration: minute,
        now: baseTime,
      );
      final afterSeekBack = applyPosition(
        completed,
        position: const Duration(seconds: 5),
        duration: minute,
        now: baseTime,
      );
      expect(completed.completed, isTrue);
      expect(afterSeekBack.completed, isTrue);
    });
  });

  group('sequential unlock rule', () {
    test('the first lesson is always unlocked', () {
      expect(isLessonUnlocked(course, 'l1', {}), isTrue);
    });

    test('a lesson is locked until the previous one is completed', () {
      expect(isLessonUnlocked(course, 'l2', {}), isFalse);
      expect(
        isLessonUnlocked(course, 'l2', {key('l1'): progressAt(50)}),
        isFalse,
      );
      expect(isLessonUnlocked(course, 'l2', {key('l1'): done()}), isTrue);
    });

    test('the rule continues across section boundaries', () {
      expect(isLessonUnlocked(course, 'l3', {key('l1'): done()}), isFalse);
      expect(
        isLessonUnlocked(course, 'l3', {key('l1'): done(), key('l2'): done()}),
        isTrue,
      );
    });
  });

  group('course progress %', () {
    test('is 0 with no progress', () {
      expect(courseProgress(course, {}), 0);
    });

    test('counts completed lessons only, not in-progress ones', () {
      final progress = {key('l1'): done(), key('l2'): progressAt(80)};
      expect(courseProgress(course, progress), closeTo(1 / 3, 1e-9));
    });

    test('is 0 for a course with no lessons (no division by zero)', () {
      expect(courseProgress(emptyCourse(), {}), 0);
    });
  });
}
