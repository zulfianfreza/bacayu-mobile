import 'package:dartz/dartz.dart';

import '../../../../core/error/failure.dart';
import '../entities/book.dart';
import '../entities/book_input.dart';

abstract class BookRepository {
  /// Ephemeral results, nothing persisted — see `SearchBooks` on the backend.
  Future<Either<Failure, List<Book>>> searchBooks(String query);

  /// Find-or-create by `google_books_id`; returns a [Book] with a real
  /// internal `id`.
  Future<Either<Failure, Book>> importFromGoogle(String googleBooksId);

  /// Find-or-create by ISBN; returns a [Book] with a real internal `id`.
  Future<Either<Failure, Book>> lookupByIsbn(String isbn);

  Future<Either<Failure, Book>> addManual(BookInput input);

  /// GET /books/:id — fetch a previously imported/added book by its
  /// internal id. Used by `shelf` to resolve display data for a
  /// `book_id`-only shelf entry.
  Future<Either<Failure, Book>> getById(String id);
}
