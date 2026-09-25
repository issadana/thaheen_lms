import 'package:equatable/equatable.dart';

/// Notes are keyed by course and lesson because lesson ids are only unique
/// inside their course.
String noteKey(String courseId, String lessonId) => '$courseId/$lessonId';

class NotesState extends Equatable {
  const NotesState(this.notes);

  final Map<String, String> notes;

  /// The note for a lesson, or '' when there is none.
  String of(String courseId, String lessonId) =>
      notes[noteKey(courseId, lessonId)] ?? '';

  @override
  List<Object?> get props => [notes];
}
