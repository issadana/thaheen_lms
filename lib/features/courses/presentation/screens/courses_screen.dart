import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/l10n/l10n.dart';
import '../../../../core/widgets/app_search_field.dart';
import '../../../../core/widgets/state_views.dart';
import '../../../progress/domain/progress_rules.dart';
import '../../../progress/presentation/cubit/progress_cubit.dart';
import '../../../settings/presentation/widgets/settings_actions.dart';
import '../../domain/course.dart';
import '../cubit/courses_cubit.dart';
import '../widgets/continue_watching_card.dart';
import '../widgets/course_card.dart';
import '../widgets/courses_more_menu.dart';

class CoursesScreen extends StatelessWidget {
  const CoursesScreen({
    super.key,
    required this.onOpenCourse,
    required this.onOpenLesson,
  });

  final void Function(String courseId) onOpenCourse;
  final void Function(String courseId, String lessonId) onOpenLesson;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.coursesTitle),
        actions: const [SettingsActions(), CoursesMoreMenu()],
      ),
      body: BlocBuilder<CoursesCubit, CoursesState>(
        builder: (context, state) => switch (state) {
          CoursesLoading() => const LoadingView(),
          CoursesError() => ErrorView(
            title: l10n.catalogErrorTitle,
            message: l10n.catalogErrorMessage,
            onRetry: context.read<CoursesCubit>().load,
          ),
          CoursesLoaded(:final courses) when courses.isEmpty => MessageView(
            icon: Icons.menu_book_outlined,
            title: l10n.emptyCatalog,
          ),
          CoursesLoaded(:final courses) => _CourseList(
            courses: courses,
            onOpenCourse: onOpenCourse,
            onOpenLesson: onOpenLesson,
          ),
        },
      ),
    );
  }
}

class _CourseList extends StatefulWidget {
  const _CourseList({
    required this.courses,
    required this.onOpenCourse,
    required this.onOpenLesson,
  });

  final List<Course> courses;
  final void Function(String courseId) onOpenCourse;
  final void Function(String courseId, String lessonId) onOpenLesson;

  @override
  State<_CourseList> createState() => _CourseListState();
}

class _CourseListState extends State<_CourseList> {
  final _search = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final progress = context.watch<ProgressCubit>().state.lessons;
    final courses = widget.courses.where((c) => c.matches(_query)).toList();
    final resume = _query.isEmpty
        ? continueWatching(widget.courses, progress)
        : null;

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
      // Scrolling the list closes the keyboard.
      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
      children: [
        AppSearchField(
          controller: _search,
          hintText: l10n.searchHint,
          onChanged: (value) => setState(() => _query = value),
        ),
        const SizedBox(height: 16),
        if (resume != null) ...[
          ContinueWatchingCard(
            item: resume,
            onTap: () =>
                widget.onOpenLesson(resume.course.id, resume.lesson.id),
          ),
          const SizedBox(height: 16),
        ],
        if (courses.isEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 48),
            child: MessageView(
              icon: Icons.search_off,
              title: l10n.noSearchResults,
            ),
          ),
        for (final course in courses) ...[
          CourseCard(
            course: course,
            progress: courseProgress(course, progress),
            onTap: () => widget.onOpenCourse(course.id),
          ),
          const SizedBox(height: 12),
        ],
      ],
    );
  }
}
