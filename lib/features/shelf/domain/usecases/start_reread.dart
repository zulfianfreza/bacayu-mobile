import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/error/failure.dart';
import '../entities/user_book.dart';
import '../repositories/shelf_repository.dart';

@injectable
class StartReread {
  StartReread(this._repository);

  final ShelfRepository _repository;

  Future<Either<Failure, UserBook>> call(String bookId) {
    return _repository.startReread(bookId);
  }
}
