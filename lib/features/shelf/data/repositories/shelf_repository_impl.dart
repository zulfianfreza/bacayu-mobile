import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/error/failure.dart';
import '../../../../core/network/dio_client.dart';
import '../../../books/domain/entities/book.dart';
import '../../../books/domain/repositories/book_repository.dart';
import '../../domain/entities/user_book.dart';
import '../../domain/repositories/shelf_repository.dart';
import '../datasources/shelf_remote_datasource.dart';
import '../models/user_book_model.dart';

/// The shelf API only returns `book_id` per entry (no join) — this
/// repository resolves each entry's [Book] via `books`' `BookRepository`
/// (GET /books/:id) and composes the two into a display-ready [UserBook].
/// N+1 by nature; acceptable for shelf list sizes, but a candidate for a
/// batch endpoint later if that ever becomes a problem.
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
      return bookResult.map<UserBook>((book) => UserBookModel.fromJson(json, book: book));
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

      final resolved = await Future.wait(
        items.cast<Map<String, dynamic>>().map((json) async {
          final bookResult = await _resolveBook(UserBookModel.bookIdOf(json));
          return bookResult
              .map<UserBook>((book) => UserBookModel.fromJson(json, book: book));
        }),
      );

      // If any single book failed to resolve, surface that failure rather
      // than silently dropping the shelf entry.
      Failure? firstFailure;
      final userBooks = <UserBook>[];
      for (final result in resolved) {
        result.fold((failure) => firstFailure ??= failure, userBooks.add);
      }
      if (firstFailure != null) return Left(firstFailure!);

      return Right(userBooks);
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
      return bookResult.map<UserBook>((book) => UserBookModel.fromJson(json, book: book));
    } on DioException catch (e) {
      return dioExceptionToEither(e);
    }
  }
}
