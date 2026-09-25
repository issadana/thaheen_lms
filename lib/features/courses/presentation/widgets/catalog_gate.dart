import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/l10n/l10n.dart';
import '../../../../core/widgets/state_views.dart';
import '../cubit/courses_cubit.dart';

/// Draws [builder] once the catalog has loaded and [find] locates what the
/// screen needs. Until then it shows the shared loading, catalog-error or
/// not-found page, so screens opened by id don't each handle those states.
class CatalogGate<T extends Object> extends StatelessWidget {
  const CatalogGate({
    super.key,
    required this.find,
    required this.notFoundTitle,
    required this.builder,
  });

  /// Looks the item up in the loaded catalog; null means it doesn't exist.
  final T? Function(CoursesCubit courses) find;
  final String notFoundTitle;
  final Widget Function(BuildContext context, T item) builder;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final courses = context.watch<CoursesCubit>();

    return switch (courses.state) {
      CoursesLoading() => const StatePage(child: LoadingView()),
      CoursesError() => StatePage(
        child: ErrorView(
          title: l10n.catalogErrorTitle,
          message: l10n.catalogErrorMessage,
          onRetry: courses.load,
        ),
      ),
      CoursesLoaded() => switch (find(courses)) {
        final item? => builder(context, item),
        null => StatePage(
          child: MessageView(icon: Icons.search_off, title: notFoundTitle),
        ),
      },
    };
  }
}
