import 'package:dartz/dartz.dart';

import '../../../../core/error/failure.dart';
import '../entities/book_read.dart';
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

  /// Every read of one book, oldest first — the original entry plus each reread.
  Future<Either<Failure, List<BookRead>>> getBookReads(String bookId);

  /// Opens a new read for a finished book. Backend inserts a fresh row
  /// (`is_reread`, page 0) and refuses anything not currently `finished`.
  Future<Either<Failure, UserBook>> startReread(String bookId);
}
