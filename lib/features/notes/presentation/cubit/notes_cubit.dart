import 'package:dartz/dartz.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/error/failure.dart';
import '../../domain/usecases/create_note.dart';
import '../../domain/usecases/delete_note.dart';
import '../../domain/usecases/list_notes.dart';
import '../../domain/usecases/update_note.dart';
import 'notes_state.dart';

/// Notes for one shelf entry (one read) — the book-detail section's cubit.
///
/// Writes re-fetch the list instead of patching in place: note rows are few, and
/// the backend is the one that trims content and stamps `updated_at`, so the
/// cheap refetch keeps the list honest (contrast `ShelfCubit.updateStatus`,
/// where the row is big enough that a refetch isn't worth it).
@injectable
class NotesCubit extends Cubit<NotesState> {
  NotesCubit(
    this._listNotes,
    this._createNote,
    this._updateNote,
    this._deleteNote,
  ) : super(const NotesLoading());

  final ListNotes _listNotes;
  final CreateNote _createNote;
  final UpdateNote _updateNote;
  final DeleteNote _deleteNote;

  String? _userBookId;

  Future<void> load(String userBookId) async {
    _userBookId = userBookId;
    emit(const NotesLoading());
    final result = await _listNotes(userBookId: userBookId);
    result.fold(
      (failure) => emit(NotesError(failure: failure)),
      (notes) => emit(NotesLoaded(items: notes)),
    );
  }

  /// Returns the failure when the write failed, `null` on success — the caller
  /// snackbars it and the list is already refreshed.
  Future<Failure?> add({
    required String content,
    int? page,
    String? quote,
  }) async {
    final userBookId = _userBookId;
    if (userBookId == null) return null;

    final result = await _createNote(
      userBookId: userBookId,
      content: content,
      page: page,
      quote: quote,
    );
    return _afterWrite(result);
  }

  Future<Failure?> update({
    required String noteId,
    required String content,
    int? page,
    String? quote,
  }) async {
    final result = await _updateNote(
      noteId: noteId,
      content: content,
      page: page,
      quote: quote,
    );
    return _afterWrite(result);
  }

  Future<Failure?> delete(String noteId) async {
    final result = await _deleteNote(noteId);
    return result.fold((failure) async => failure, (_) async {
      await _refresh();
      return null;
    });
  }

  Future<Failure?> _afterWrite(Either<Failure, dynamic> result) {
    return result.fold((failure) async => failure, (_) async {
      await _refresh();
      return null;
    });
  }

  Future<void> _refresh() async {
    final userBookId = _userBookId;
    if (userBookId == null) return;

    final result = await _listNotes(userBookId: userBookId);
    result.fold(
      // A failed refresh keeps the previous list on screen; the write itself
      // already succeeded, so this must not surface as a failed save.
      (failure) => emit(NotesError(failure: failure)),
      (notes) => emit(NotesLoaded(items: notes)),
    );
  }
}
