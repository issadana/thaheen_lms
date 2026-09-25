// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Thaheen';

  @override
  String get coursesTitle => 'My courses';

  @override
  String get searchHint => 'Search courses or instructors';

  @override
  String get clearSearch => 'Clear search';

  @override
  String get noSearchResults => 'No courses match your search';

  @override
  String get continueWatching => 'Continue watching';

  @override
  String lessonCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count lessons',
      one: '1 lesson',
      zero: 'No lessons',
    );
    return '$_temp0';
  }

  @override
  String percentComplete(int percent) {
    return '$percent% complete';
  }

  @override
  String completedOfTotal(int done, int total) {
    return '$done of $total completed';
  }

  @override
  String get statusNotStarted => 'Not started';

  @override
  String get statusInProgress => 'In progress';

  @override
  String get statusCompleted => 'Completed';

  @override
  String get statusLocked => 'Locked';

  @override
  String get lockedLessonMessage =>
      'This lesson is locked. Finish the previous lesson to unlock it';

  @override
  String get lockedLessonTitle => 'This lesson isn\'t available yet';

  @override
  String lockedLessonFinishFirst(String lesson) {
    return 'Finish “$lesson” first to unlock this lesson';
  }

  @override
  String get emptyCatalog => 'No courses available yet';

  @override
  String get emptyCourse => 'This course has no lessons yet';

  @override
  String get emptySection => 'No lessons in this section yet';

  @override
  String get catalogErrorTitle => 'Couldn\'t load courses';

  @override
  String get catalogErrorMessage =>
      'Something went wrong while reading the course data. Please try again.';

  @override
  String get courseNotFound => 'Course not found';

  @override
  String get lessonNotFound => 'Lesson not found';

  @override
  String get retry => 'Try again';

  @override
  String get videoErrorTitle => 'This video can\'t be played';

  @override
  String get videoErrorMessage => 'The video file may be missing or damaged.';

  @override
  String get play => 'Play';

  @override
  String get pause => 'Pause';

  @override
  String get playbackSpeed => 'Playback speed';

  @override
  String get enterFullscreen => 'Fullscreen';

  @override
  String get exitFullscreen => 'Exit fullscreen';

  @override
  String get nextLesson => 'Next lesson';

  @override
  String get nextLessonLockedHint =>
      'Watch 90% of this lesson to unlock the next one';

  @override
  String get startCourse => 'Start course';

  @override
  String continueLesson(String lesson) {
    return 'Continue: $lesson';
  }

  @override
  String get watchAgain => 'Watch the course again';

  @override
  String get lessonCompleted => 'Well done! Lesson completed';

  @override
  String get courseCompleted =>
      'Well done! You\'ve completed every lesson in this course 🎉';

  @override
  String get switchLanguage => 'العربية';

  @override
  String get toggleTheme => 'Toggle theme';

  @override
  String get moreOptions => 'More options';

  @override
  String get resetProgress => 'Reset progress';

  @override
  String get resetProgressConfirm =>
      'This will erase your progress in every lesson. Continue?';

  @override
  String get cancel => 'Cancel';

  @override
  String get reset => 'Reset';

  @override
  String get lessonNotesTitle => 'My notes';

  @override
  String get lessonNotesHint => 'Write your notes for this lesson…';

  @override
  String get lessonNotesSavedAutomatically => 'Saved automatically';
}
