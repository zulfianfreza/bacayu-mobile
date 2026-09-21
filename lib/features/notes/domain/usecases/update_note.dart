import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/error/failure.dart';
import '../entities/note.dart';
import '../repositories/note_repository.dart';

@injectable
class UpdateNote {
  UpdateNote(this._repository);

  final NoteRepository _repository;

  Future<Either<Failure, Note>> call({
    required String noteId,
    required String content,
    int? page,
    String? quote,
  }) {
    return _repository.updateNote(
      noteId: noteId,
      content: content,
      page: page,
      quote: quote,
    );
  }
}
