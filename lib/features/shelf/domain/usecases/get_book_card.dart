import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/error/failure.dart';
import '../entities/user_book.dart';
import '../repositories/shelf_repository.dart';

@injectable
class GetBookCard {
  GetBookCard(this._repository);

  final ShelfRepository _repository;

  /// The caller's active shelf entry for one book, or a `ServerFailure` with
  /// `USER_BOOK_NOT_FOUND` when the book isn't on their shelf.
  Future<Either<Failure, UserBook>> call(String bookId) {
    return _repository.getBookCard(bookId);
  }
}
