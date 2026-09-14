import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/error/failure.dart';
import '../entities/book.dart';
import '../repositories/book_repository.dart';

@injectable
class LookupBookByIsbn {
  LookupBookByIsbn(this._repository);

  final BookRepository _repository;

  Future<Either<Failure, Book>> call(String isbn) =>
      _repository.lookupByIsbn(isbn);
}
