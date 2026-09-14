import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/core/error/failure.dart';
import 'package:mobile/features/books/domain/entities/book.dart';
import 'package:mobile/features/books/domain/repositories/book_repository.dart';
import 'package:mobile/features/books/domain/usecases/import_book_from_google.dart';
import 'package:mocktail/mocktail.dart';

class _MockBookRepository extends Mock implements BookRepository {}

void main() {
  late _MockBookRepository repository;
  late ImportBookFromGoogle usecase;

  setUp(() {
    repository = _MockBookRepository();
    usecase = ImportBookFromGoogle(repository);
  });

  test('returns the imported book (with an internal id) on success', () async {
    const book = Book(
      id: 'internal-id-1',
      source: 'google_books',
      googleBooksId: 'g1',
      isbn10: null,
      isbn13: null,
      title: 'Atomic Habits',
      authors: ['James Clear'],
      description: null,
      coverUrl: null,
      totalPages: 320,
      language: 'en',
      genres: [],
      publishedDate: '2018',
    );
    when(() => repository.importFromGoogle('g1'))
        .thenAnswer((_) async => const Right(book));

    final result = await usecase('g1');

    expect(result, const Right<Failure, Book>(book));
    verify(() => repository.importFromGoogle('g1')).called(1);
  });

  test('propagates a Failure from the repository unchanged', () async {
    when(() => repository.importFromGoogle('g1')).thenAnswer(
      (_) async => const Left(
        ServerFailure(code: 'INTERNAL_ERROR', message: 'internal error'),
      ),
    );

    final result = await usecase('g1');

    expect(
      result,
      const Left<Failure, Book>(
        ServerFailure(code: 'INTERNAL_ERROR', message: 'internal error'),
      ),
    );
  });
}
