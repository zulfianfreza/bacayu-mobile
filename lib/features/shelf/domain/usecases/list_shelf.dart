import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/error/failure.dart';
import '../entities/user_book.dart';
import '../repositories/shelf_repository.dart';

@injectable
class ListShelf {
  ListShelf(this._repository);

  final ShelfRepository _repository;

  Future<Either<Failure, List<UserBook>>> call({
    ShelfStatus? status,
    int page = 1,
  }) {
    return _repository.listShelf(status: status, page: page);
  }
}
