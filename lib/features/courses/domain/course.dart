import 'package:equatable/equatable.dart';

import '../../../core/localization/localized_text.dart';
import 'json_fields.dart';
import 'lesson.dart';
import 'section.dart';

class Course extends Equatable {
  const Course({
    required this.id,
    required this.title,
    required this.instructor,
    required this.sections,
    this.thumbnail,
  });

  factory Course.fromJson(Map<String, dynamic> json) {
    final id = readId(json, 'course');
    final where = 'course "$id"';
    final thumbnail = json['thumbnail'];
    final course = Course(
      id: id,
      title: LocalizedText.fromJson(json['title']),
      instructor: LocalizedText.fromJson(json['instructor']),
      thumbnail: thumbnail is String && thumbnail.isNotEmpty ? thumbnail : null,
      sections: [
        for (final section in readObjectList(json, 'sections', where))
          Section.fromJson(section),
      ],
    );
    ensureUniqueIds(course.lessons.map((l) => l.id), where);
    return course;
  }

  final String id;
  final LocalizedText title;
  final LocalizedText instructor;
  /// Asset path of the thumbnail image. Optional.
  final String? thumbnail;
  final List<Section> sections;
  /// All lessons in watching order (section by section).
  List<Lesson> get lessons => [
    for (final section in sections) ...section.lessons,
  ];

  int get lessonCount =>
      sections.fold(0, (sum, section) => sum + section.lessons.length);

  Lesson? lessonById(String lessonId) {
    for (final lesson in lessons) {
      if (lesson.id == lessonId) return lesson;
    }
    return null;
  }

  Section? sectionOf(String lessonId) {
    for (final section in sections) {
      if (section.lessons.any((l) => l.id == lessonId)) return section;
    }
    return null;
  }

  /// Case-insensitive search across the title and instructor in every language.
  bool matches(String query) {
    final q = query.trim().toLowerCase();
    if (q.isEmpty) return true;
    return [
      ...title.values.values,
      ...instructor.values.values,
    ].any((text) => text.toLowerCase().contains(q));
  }

  @override
  List<Object?> get props => [id, title, instructor, thumbnail, sections];
}
