import 'package:equatable/equatable.dart';

import '../../../core/localization/localized_text.dart';
import 'json_fields.dart';
import 'lesson.dart';

class Section extends Equatable {
  const Section({required this.id, required this.title, required this.lessons});

  factory Section.fromJson(Map<String, dynamic> json) {
    final id = readId(json, 'section');
    return Section(
      id: id,
      title: LocalizedText.fromJson(json['title']),
      lessons: [
        for (final lesson in readObjectList(json, 'lessons', 'section "$id"'))
          Lesson.fromJson(lesson),
      ],
    );
  }

  final String id;
  final LocalizedText title;
  final List<Lesson> lessons;

  @override
  List<Object?> get props => [id, title, lessons];
}
