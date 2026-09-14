import 'package:dartz/dartz.dart';

import '../../../../core/error/failure.dart';
import '../entities/user_book.dart';

abstract class ShelfRepository {
  Future<Either<Failure, UserBook>> addToShelf({
    required String bookId,
    ShelfStatus? status,
  });

  Future<Either<Failure, List<UserBook>>> listShelf({
    ShelfStatus? status,
    int page = 1,
  });

  Future<Either<Failure, UserBook>> updateShelfStatus({
    required String userBookId,
    ShelfStatus? status,
    int? currentPage,
    int? rating,
  });
}
