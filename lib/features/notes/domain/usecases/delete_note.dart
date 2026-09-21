import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/error/failure.dart';
import '../repositories/note_repository.dart';

@injectable
class DeleteNote {
  DeleteNote(this._repository);

  final NoteRepository _repository;

  Future<Either<Failure, void>> call(String noteId) {
    return _repository.deleteNote(noteId);
  }
}
