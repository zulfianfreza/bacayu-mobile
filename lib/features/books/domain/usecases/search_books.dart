import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/error/failure.dart';
import '../entities/book.dart';
import '../repositories/book_repository.dart';

@injectable
class SearchBooks {
  SearchBooks(this._repository);

  final BookRepository _repository;

  Future<Either<Failure, List<Book>>> call(String query) =>
      _repository.searchBooks(query);
}
