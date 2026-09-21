import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/error/failure.dart';
import '../../../../core/network/dio_client.dart';
import '../../../books/domain/entities/book.dart';
import '../../../books/domain/repositories/book_repository.dart';
import '../../domain/entities/book_read.dart';
import '../../domain/entities/user_book.dart';
import '../../domain/repositories/shelf_repository.dart';
import '../datasources/shelf_remote_datasource.dart';
import '../models/book_read_model.dart';
import '../models/user_book_model.dart';

/// The list (`GET /shelf`) embeds each entry's book, so a shelf needs one
/// request no matter how many books are on it — it used to resolve every entry
/// through `books`' `BookRepository` (GET /books/:id), which was N+1 by nature.
///
/// The *writes* still stay lean server-side (`POST`/`PATCH /shelf` return the
/// entry alone), so those two paths resolve their single book here. One request
/// for one edited book is not the same problem as one per row.
@LazySingleton(as: ShelfRepository)
class ShelfRepositoryImpl implements ShelfRepository {
  ShelfRepositoryImpl(this._remote, this._bookRepository);

  final ShelfRemoteDataSource _remote;
  final BookRepository _bookRepository;

  Future<Either<Failure, Book>> _resolveBook(String bookId) =>
      _bookRepository.getById(bookId);

  @override
  Future<Either<Failure, UserBook>> addToShelf({
    required String bookId,
    ShelfStatus? status,
  }) async {
    try {
      final json = await _remote.addToShelf(
        bookId: bookId,
        status: status?.wireValue,
      );
      final bookResult = await _resolveBook(UserBookModel.bookIdOf(json));
      return bookResult.map<UserBook>(
        (book) => UserBookModel.fromJson(json, book: book),
      );
    } on DioException catch (e) {
      return dioExceptionToEither(e);
    }
  }

  @override
  Future<Either<Failure, List<UserBook>>> listShelf({
    ShelfStatus? status,
    int page = 1,
  }) async {
    try {
      final items = await _remote.listShelf(
        status: status?.wireValue,
        page: page,
      );

      return Right(
        items
            .cast<Map<String, dynamic>>()
            .map(UserBookModel.fromShelfItemJson)
            .toList(),
      );
    } on DioException catch (e) {
      return dioExceptionToEither(e);
    }
  }

  @override
  Future<Either<Failure, UserBook>> updateShelfStatus({
    required String userBookId,
    ShelfStatus? status,
    int? currentPage,
    int? rating,
  }) async {
    try {
      final json = await _remote.updateShelfStatus(
        userBookId: userBookId,
        status: status?.wireValue,
        currentPage: currentPage,
        rating: rating,
      );
      final bookResult = await _resolveBook(UserBookModel.bookIdOf(json));
      return bookResult.map<UserBook>(
        (book) => UserBookModel.fromJson(json, book: book),
      );
    } on DioException catch (e) {
      return dioExceptionToEither(e);
    }
  }

  @override
  Future<Either<Failure, List<BookRead>>> getBookReads(String bookId) async {
    try {
      final items = await _remote.getBookReads(bookId);
      return Right(
        items.cast<Map<String, dynamic>>().map(BookReadModel.fromJson).toList(),
      );
    } on DioException catch (e) {
      return dioExceptionToEither(e);
    }
  }

  @override
  Future<Either<Failure, UserBook>> startReread(String bookId) async {
    try {
      final json = await _remote.startReread(bookId);
      // Same as the other writes: the flat response carries no book, so resolve
      // the one book this request is about.
      final bookResult = await _resolveBook(UserBookModel.bookIdOf(json));
      return bookResult.map<UserBook>(
        (book) => UserBookModel.fromJson(json, book: book),
      );
    } on DioException catch (e) {
      return dioExceptionToEither(e);
    }
  }
}
