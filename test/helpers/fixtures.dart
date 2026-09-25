import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:thaheen_lms/core/localization/localized_text.dart';
import 'package:thaheen_lms/features/courses/domain/course.dart';
import 'package:thaheen_lms/features/courses/domain/lesson.dart';
import 'package:thaheen_lms/features/courses/domain/section.dart';
import 'package:thaheen_lms/features/progress/domain/lesson_progress.dart';

Lesson lesson(String id, {int seconds = 100}) => Lesson(
  id: id,
  title: LocalizedText.single('Lesson $id'),
  duration: Duration(seconds: seconds),
  video: 'assets/videos/$id.mp4',
);

/// A course with two sections: s1 = [l1, l2], s2 = [l3].
Course sampleCourse({String id = 'c1'}) => Course(
  id: id,
  title: LocalizedText.single('Course $id'),
  instructor: LocalizedText.single('Instructor'),
  sections: [
    Section(
      id: 's1',
      title: LocalizedText.single('One'),
      lessons: [lesson('l1'), lesson('l2')],
    ),
    Section(
      id: 's2',
      title: LocalizedText.single('Two'),
      lessons: [lesson('l3')],
    ),
  ],
);

Course emptyCourse() => Course(
  id: 'empty',
  title: LocalizedText.single('Empty'),
  instructor: LocalizedText.single('Instructor'),
  sections: [
    Section(id: 's1', title: LocalizedText.single('One'), lessons: const []),
  ],
);

final baseTime = DateTime(2026, 1, 1, 12);

LessonProgress progressAt(int seconds, {bool completed = false}) =>
    LessonProgress(
      position: Duration(seconds: seconds),
      duration: const Duration(seconds: 100),
      completed: completed,
      updatedAt: baseTime,
    );

LessonProgress done() => progressAt(95, completed: true);

/// An [AssetBundle] that serves strings from memory, for widget tests.
class FakeAssetBundle extends CachingAssetBundle {
  FakeAssetBundle(this.files);

  final Map<String, String> files;

  @override
  Future<ByteData> load(String key) async {
    final content = files[key];
    if (content == null) throw FlutterError('Asset not found: $key');
    return ByteData.sublistView(utf8.encode(content));
  }
}

const catalogJson = '''
{
  "courses": [
    {
      "id": "anatomy-101",
      "title": { "ar": "مقدمة في التشريح", "en": "Introduction to Anatomy" },
      "instructor": "د. سارة",
      "sections": [
        {
          "id": "s1",
          "title": "الجهاز الهيكلي",
          "lessons": [
            { "id": "l1", "title": "العظام", "durationSec": 95, "video": "assets/videos/lesson1.mp4" },
            { "id": "l2", "title": "المفاصل", "durationSec": 60, "video": "assets/videos/lesson2.mp4" }
          ]
        }
      ]
    }
  ]
}
''';
