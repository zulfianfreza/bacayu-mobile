import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/error/failure.dart';
import '../../../../core/network/dio_client.dart';
import '../../domain/entities/book.dart';
import '../../domain/entities/book_input.dart';
import '../../domain/repositories/book_repository.dart';
import '../datasources/book_remote_datasource.dart';
import '../models/book_model.dart';

/// No local cache here — search results are ephemeral by design (backend
/// caches search/ISBN lookups server-side; see CLAUDE.md backend Section
/// 5.6), the mobile app just displays what it gets.
@LazySingleton(as: BookRepository)
class BookRepositoryImpl implements BookRepository {
  BookRepositoryImpl(this._remote);

  final BookRemoteDataSource _remote;

  @override
  Future<Either<Failure, List<Book>>> searchBooks(String query) async {
    try {
      final json = await _remote.search(query);
      final books = json
          .cast<Map<String, dynamic>>()
          .map(BookModel.fromJson)
          .toList();
      return Right(books);
    } on DioException catch (e) {
      return dioExceptionToEither(e);
    }
  }

  @override
  Future<Either<Failure, Book>> importFromGoogle(String googleBooksId) async {
    try {
      final json = await _remote.importFromGoogle(googleBooksId);
      return Right(BookModel.fromJson(json));
    } on DioException catch (e) {
      return dioExceptionToEither(e);
    }
  }

  @override
  Future<Either<Failure, Book>> lookupByIsbn(String isbn) async {
    try {
      final json = await _remote.lookupByIsbn(isbn);
      return Right(BookModel.fromJson(json));
    } on DioException catch (e) {
      return dioExceptionToEither(e);
    }
  }

  @override
  Future<Either<Failure, Book>> getById(String id) async {
    try {
      final json = await _remote.getById(id);
      return Right(BookModel.fromJson(json));
    } on DioException catch (e) {
      return dioExceptionToEither(e);
    }
  }

  @override
  Future<Either<Failure, Book>> addManual(BookInput input) async {
    try {
      final json = await _remote.addManual(input);
      return Right(BookModel.fromJson(json));
    } on DioException catch (e) {
      return dioExceptionToEither(e);
    }
  }
}
