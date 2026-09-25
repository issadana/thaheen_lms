import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/notes_store.dart';
import 'notes_state.dart';

export 'notes_state.dart';

/// The student's personal notes, one per lesson, saved as they type.
class NotesCubit extends Cubit<NotesState> {
  NotesCubit(this._store) : super(NotesState(_store.load()));

  final NotesStore _store;

  /// Saves [text] as the note for a lesson. A blank note is removed, so
  /// clearing the field leaves nothing behind in storage.
  Future<void> setNote({
    required String courseId,
    required String lessonId,
    required String text,
  }) async {
    final key = noteKey(courseId, lessonId);
    if ((state.notes[key] ?? '') == text) return;
    final notes = Map<String, String>.of(state.notes);
    if (text.trim().isEmpty) {
      notes.remove(key);
    } else {
      notes[key] = text;
    }
    final unmodifiable = Map<String, String>.unmodifiable(notes);
    emit(NotesState(unmodifiable));
    await _store.save(unmodifiable);
  }
}
