import 'package:equatable/equatable.dart';

import '../../../core/localization/localized_text.dart';
import 'json_fields.dart';

class Lesson extends Equatable {
  const Lesson({
    required this.id,
    required this.title,
    required this.duration,
    required this.video,
  });

  factory Lesson.fromJson(Map<String, dynamic> json) {
    final id = readId(json, 'lesson');
    final where = 'lesson "$id"';
    final durationSec = readField<num>(json, 'durationSec', where);
    if (!durationSec.isFinite || durationSec < 0) {
      throw FormatException(
        '$where: "durationSec" must be a non-negative number',
      );
    }
    return Lesson(
      id: id,
      title: LocalizedText.fromJson(json['title']),
      duration: Duration(milliseconds: (durationSec * 1000).round()),
      video: readField<String>(json, 'video', where),
    );
  }

  final String id;
  final LocalizedText title;

  /// Duration from the catalog, used for display only. The completion rule
  /// uses the real duration reported by the video player.
  final Duration duration;

  /// Asset path of the video file.
  final String video;

  @override
  List<Object?> get props => [id, title, duration, video];
}
