import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/error/failure.dart';
import '../entities/user_book.dart';
import '../repositories/shelf_repository.dart';

@injectable
class AddToShelf {
  AddToShelf(this._repository);

  final ShelfRepository _repository;

  Future<Either<Failure, UserBook>> call({
    required String bookId,
    ShelfStatus? status,
  }) {
    return _repository.addToShelf(bookId: bookId, status: status);
  }
}
