import 'package:flutter/material.dart';

/// Course image with a neutral placeholder when the asset is missing or broken.
class CourseThumbnail extends StatelessWidget {
  const CourseThumbnail({
    super.key,
    required this.path,
    this.size = 88,
    this.heroCourseId,
  });

  final String? path;
  final double size;

  /// When set, the image flies between screens that show the same course.
  /// Only one thumbnail per course may set it on a screen, or Flutter
  /// reports duplicate hero tags.
  final String? heroCourseId;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final placeholder = ColoredBox(
      color: colors.secondaryContainer,
      child: Icon(
        Icons.school_outlined,
        color: colors.onSecondaryContainer,
        size: size * 0.4,
      ),
    );
    final thumbnail = ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: SizedBox.square(
        dimension: size,
        child: path == null
            ? placeholder
            : Image.asset(
                path!,
                fit: BoxFit.cover,
                errorBuilder: (_, _, _) => placeholder,
              ),
      ),
    );
    final courseId = heroCourseId;
    return courseId == null
        ? thumbnail
        : Hero(tag: 'course-thumbnail/$courseId', child: thumbnail);
  }
}
