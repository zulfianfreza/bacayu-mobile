import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/features/books/domain/entities/book.dart';
import 'package:mobile/features/books/domain/repositories/book_repository.dart';
import 'package:mobile/features/books/domain/usecases/import_book_from_google.dart';
import 'package:mobile/features/books/domain/usecases/search_books.dart';
import 'package:mobile/features/books/presentation/bloc/book_search_bloc.dart';
import 'package:mobile/features/books/presentation/bloc/book_search_event.dart';
import 'package:mobile/features/books/presentation/bloc/book_search_state.dart';
import 'package:mocktail/mocktail.dart';

class _MockBookRepository extends Mock implements BookRepository {}

Book _book({String id = '', String title = 'Atomic Habits'}) => Book(
      id: id,
      source: 'google_books',
      googleBooksId: 'g1',
      isbn10: null,
      isbn13: null,
      title: title,
      authors: const ['James Clear'],
      description: null,
      coverUrl: null,
      totalPages: 320,
      language: 'en',
      genres: const [],
      publishedDate: '2018',
    );

void main() {
  late _MockBookRepository repository;
  late BookSearchBloc bloc;

  setUp(() {
    repository = _MockBookRepository();
    bloc = BookSearchBloc(
      SearchBooks(repository),
      ImportBookFromGoogle(repository),
    );
  });

  tearDown(() => bloc.close());

  group('SearchQueryChanged debounce', () {
    test(
        'rapid keystrokes trigger exactly one repository.searchBooks call, '
        'for the last query only', () async {
      when(() => repository.searchBooks(any()))
          .thenAnswer((_) async => Right([_book()]));

      bloc
        ..add(const SearchQueryChanged('h'))
        ..add(const SearchQueryChanged('ha'))
        ..add(const SearchQueryChanged('har'))
        ..add(const SearchQueryChanged('harry'));

      // Debounce window is 400ms; give it enough margin to fire once.
      await Future<void>.delayed(const Duration(milliseconds: 600));

      verify(() => repository.searchBooks('harry')).called(1);
      verifyNever(() => repository.searchBooks('h'));
      verifyNever(() => repository.searchBooks('ha'));
      verifyNever(() => repository.searchBooks('har'));
    });

    test('emits [loading, loaded] for a single query after debounce',
        () async {
      final results = [_book()];
      when(() => repository.searchBooks(any()))
          .thenAnswer((_) async => Right(results));

      final expectation = expectLater(
        bloc.stream,
        emitsInOrder([
          const BookSearchLoading(),
          BookSearchLoaded(results),
        ]),
      );

      bloc.add(const SearchQueryChanged('atomic habits'));
      await expectation;
    });

    test('blank query resets to initial without calling the repository',
        () async {
      bloc.add(const SearchQueryChanged('   '));
      await Future<void>.delayed(const Duration(milliseconds: 600));

      expect(bloc.state, const BookSearchInitial());
      verifyNever(() => repository.searchBooks(any()));
    });
  });
}
