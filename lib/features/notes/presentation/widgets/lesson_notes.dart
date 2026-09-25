import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/l10n/l10n.dart';
import '../cubit/notes_cubit.dart';

/// The student's own notes for one lesson, saved as they type.
class LessonNotes extends StatefulWidget {
  const LessonNotes({
    super.key,
    required this.courseId,
    required this.lessonId,
  });

  final String courseId;
  final String lessonId;

  @override
  State<LessonNotes> createState() => _LessonNotesState();
}

class _LessonNotesState extends State<LessonNotes> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    // Filled once from the saved note; after that the field is the source
    // and every change is written through to the cubit.
    _controller = TextEditingController(
      text: context.read<NotesCubit>().state.of(
        widget.courseId,
        widget.lessonId,
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Icon(Icons.edit_note, color: theme.colorScheme.primary),
            const SizedBox(width: 8),
            Text(
              l10n.lessonNotesTitle,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _controller,
          minLines: 3,
          maxLines: 8,
          keyboardType: TextInputType.multiline,
          textCapitalization: TextCapitalization.sentences,
          onTapOutside: (_) => FocusManager.instance.primaryFocus?.unfocus(),
          onChanged: (text) => context.read<NotesCubit>().setNote(
            courseId: widget.courseId,
            lessonId: widget.lessonId,
            text: text,
          ),
          decoration: InputDecoration(
            hintText: l10n.lessonNotesHint,
            helperText: l10n.lessonNotesSavedAutomatically,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide.none,
            ),
          ),
        ),
      ],
    );
  }
}
