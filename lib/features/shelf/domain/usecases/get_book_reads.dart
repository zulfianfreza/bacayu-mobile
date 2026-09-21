import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/error/failure.dart';
import '../entities/book_read.dart';
import '../repositories/shelf_repository.dart';

@injectable
class GetBookReads {
  GetBookReads(this._repository);

  final ShelfRepository _repository;

  Future<Either<Failure, List<BookRead>>> call(String bookId) {
    return _repository.getBookReads(bookId);
  }
}
