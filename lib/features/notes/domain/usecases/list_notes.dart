import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/error/failure.dart';
import '../entities/note.dart';
import '../repositories/note_repository.dart';

@injectable
class ListNotes {
  ListNotes(this._repository);

  final NoteRepository _repository;

  Future<Either<Failure, List<Note>>> call({
    String? userBookId,
    int page = 1,
  }) {
    return _repository.listNotes(userBookId: userBookId, page: page);
  }
}
