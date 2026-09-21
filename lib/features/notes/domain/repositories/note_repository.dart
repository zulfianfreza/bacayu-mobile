import 'package:dartz/dartz.dart';

import '../../../../core/error/failure.dart';
import '../entities/note.dart';

abstract class NoteRepository {
  /// The caller's notes, newest first. With [userBookId] set, only that shelf
  /// entry's notes; without it, every note the user has.
  Future<Either<Failure, List<Note>>> listNotes({
    String? userBookId,
    int page = 1,
  });

  Future<Either<Failure, Note>> createNote({
    required String userBookId,
    required String content,
    int? page,
    String? quote,
  });

  /// Patches one note. `page`/`quote` follow the backend's partial-update
  /// rule: null means "leave unchanged", so a field can be overwritten but
  /// never reset back to empty (backend v1 scope).
  Future<Either<Failure, Note>> updateNote({
    required String noteId,
    required String content,
    int? page,
    String? quote,
  });

  Future<Either<Failure, void>> deleteNote(String noteId);
}
