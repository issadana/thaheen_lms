import 'package:equatable/equatable.dart';

/// Progress is keyed by course and lesson because lesson ids are only unique
/// inside their course.
String progressKey(String courseId, String lessonId) => '$courseId/$lessonId';

typedef ProgressMap = Map<String, LessonProgress>;

class LessonProgress extends Equatable {
  const LessonProgress({
    required this.position,
    required this.duration,
    required this.completed,
    required this.updatedAt,
  });

  factory LessonProgress.fromJson(Map<String, dynamic> json) => LessonProgress(
        position: Duration(milliseconds: json['positionMs'] as int),
        duration: Duration(milliseconds: json['durationMs'] as int),
        completed: json['completed'] as bool,
        updatedAt: DateTime.parse(json['updatedAt'] as String),
      );

  /// Last watched position.
  final Duration position;
  /// Real video duration, as reported by the player.
  final Duration duration;
  /// Sticky: once a lesson is completed it stays completed.
  final bool completed;
  /// When this lesson was last watched. Used for "Continue watching".
  final DateTime updatedAt;
  /// How far through the video the saved position is, from 0 to 1.
  double get watchedFraction {
    if (duration <= Duration.zero) return 0;
    return (position.inMilliseconds / duration.inMilliseconds).clamp(0.0, 1.0);
  }

  Map<String, dynamic> toJson() => {
        'positionMs': position.inMilliseconds,
        'durationMs': duration.inMilliseconds,
        'completed': completed,
        'updatedAt': updatedAt.toIso8601String(),
      };

  @override
  List<Object?> get props => [position, duration, completed, updatedAt];
}
