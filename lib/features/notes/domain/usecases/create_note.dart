import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/error/failure.dart';
import '../entities/note.dart';
import '../repositories/note_repository.dart';

@injectable
class CreateNote {
  CreateNote(this._repository);

  final NoteRepository _repository;

  Future<Either<Failure, Note>> call({
    required String userBookId,
    required String content,
    int? page,
    String? quote,
  }) {
    return _repository.createNote(
      userBookId: userBookId,
      content: content,
      page: page,
      quote: quote,
    );
  }
}
