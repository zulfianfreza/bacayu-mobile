import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/error/failure.dart';
import '../entities/book.dart';
import '../repositories/book_repository.dart';

@injectable
class ImportBookFromGoogle {
  ImportBookFromGoogle(this._repository);

  final BookRepository _repository;

  Future<Either<Failure, Book>> call(String googleBooksId) =>
      _repository.importFromGoogle(googleBooksId);
}
