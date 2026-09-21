import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/features/books/domain/entities/book.dart';
import 'package:mobile/features/books/domain/repositories/book_repository.dart';
import 'package:mobile/features/shelf/data/datasources/shelf_remote_datasource.dart';
import 'package:mobile/features/shelf/data/repositories/shelf_repository_impl.dart';
import 'package:mobile/features/shelf/domain/entities/user_book.dart';
import 'package:mocktail/mocktail.dart';

class _MockShelfRemote extends Mock implements ShelfRemoteDataSource {}

class _MockBookRepository extends Mock implements BookRepository {}

/// One `GET /shelf` item: the entry's fields, plus the book the backend now
/// embeds (backend's `ShelfItemResponse`).
Map<String, dynamic> _shelfItem({
  String id = 'ub-1',
  String bookId = 'b-1',
  String title = 'Atomic Habits',
  int currentPage = 50,
}) => {
  'id': id,
  'user_id': 'u1',
  'book_id': bookId,
  'status': 'reading',
  'format': null,
  'current_page': currentPage,
  'started_at': null,
  'finished_at': null,
  'rating': null,
  'is_reread': false,
  'created_at': '2026-01-01T00:00:00Z',
  'updated_at': '2026-01-01T00:00:00Z',
  'book': {
    'id': bookId,
    'title': title,
    'authors': ['James Clear'],
    'cover_url': null,
    'total_pages': 320,
  },
};

Book _book() => const Book(
  id: 'b-1',
  source: 'manual',
  googleBooksId: null,
  isbn10: null,
  isbn13: null,
  title: 'Atomic Habits',
  authors: ['James Clear'],
  description: 'A book.',
  coverUrl: null,
  totalPages: 320,
  language: 'en',
  genres: ['Self-help'],
  publishedDate: '2018',
);

void main() {
  late _MockShelfRemote remote;
  late _MockBookRepository bookRepository;
  late ShelfRepositoryImpl repository;

  setUpAll(() {
    registerFallbackValue(ShelfStatus.reading);
  });

  setUp(() {
    remote = _MockShelfRemote();
    bookRepository = _MockBookRepository();
    repository = ShelfRepositoryImpl(remote, bookRepository);
  });

  test(
    'the list reads each embedded book, never fetching one per row',
    () async {
      when(() => remote.listShelf(status: null, page: 1)).thenAnswer(
        (_) async => [
          _shelfItem(),
          _shelfItem(id: 'ub-2', bookId: 'b-2', title: 'Deep Work'),
        ],
      );

      final result = await repository.listShelf();

      final items = result.getOrElse(() => fail('expected shelf items'));
      expect(items, hasLength(2));
      expect(items.first.book.id, 'b-1');
      expect(items.first.book.title, 'Atomic Habits');
      expect(items.first.book.totalPages, 320);
      expect(items.first.currentPage, 50);
      expect(items.first.status, ShelfStatus.reading);
      expect(items.last.book.title, 'Deep Work');

      verify(() => remote.listShelf(status: null, page: 1)).called(1);
      // The whole point of this shape: one request for the whole shelf.
      verifyNever(() => bookRepository.getById(any()));
    },
  );

  test('a write response still resolves its own single book', () async {
    final flat = _shelfItem()..remove('book');
    when(
      () => remote.updateShelfStatus(
        userBookId: any(named: 'userBookId'),
        status: any(named: 'status'),
        currentPage: any(named: 'currentPage'),
        rating: any(named: 'rating'),
      ),
    ).thenAnswer((_) async => flat);
    when(
      () => bookRepository.getById('b-1'),
    ).thenAnswer((_) async => Right(_book()));

    final result = await repository.updateShelfStatus(
      userBookId: 'ub-1',
      status: ShelfStatus.finished,
    );

    expect(result.isRight(), isTrue);
    verify(() => bookRepository.getById('b-1')).called(1);
  });

  test('getBookReads maps the reads endpoint, oldest first', () async {
    when(() => remote.getBookReads('b-1')).thenAnswer(
      (_) async => [
        {
          'id': 'ub-1',
          'status': 'finished',
          'current_page': 320,
          'rating': 4,
          'is_reread': false,
          'started_at': '2025-01-05T00:00:00Z',
          'finished_at': '2025-02-11T00:00:00Z',
          'created_at': '2025-01-05T00:00:00Z',
          'updated_at': '2025-02-11T00:00:00Z',
        },
        {
          'id': 'ub-2',
          'status': 'reading',
          'current_page': 0,
          'rating': null,
          'is_reread': true,
          'started_at': null,
          'finished_at': null,
          'created_at': '2026-09-01T00:00:00Z',
          'updated_at': '2026-09-01T00:00:00Z',
        },
      ],
    );

    final result = await repository.getBookReads('b-1');

    final reads = result.getOrElse(() => fail('expected reads'));
    expect(reads, hasLength(2));
    expect(reads.first.isReread, isFalse);
    expect(reads.first.rating, 4);
    expect(reads.first.finishedAt, DateTime.utc(2025, 2, 11));
    expect(reads.last.isReread, isTrue);
    expect(reads.last.startedAt, isNull);
    verify(() => remote.getBookReads('b-1')).called(1);
  });

  test(
    'startReread resolves the new row\'s book and returns the entry',
    () async {
      final flat = _shelfItem()
        ..remove('book')
        ..['status'] = 'reading'
        ..['is_reread'] = true
        ..['current_page'] = 0;
      when(() => remote.startReread('b-1')).thenAnswer((_) async => flat);
      when(
        () => bookRepository.getById('b-1'),
      ).thenAnswer((_) async => Right(_book()));

      final result = await repository.startReread('b-1');

      final entry = result.getOrElse(() => fail('expected the new reread'));
      expect(entry.status, ShelfStatus.reading);
      expect(entry.isReread, isTrue);
      expect(entry.currentPage, 0);
      expect(entry.book.id, 'b-1');
      verify(() => remote.startReread('b-1')).called(1);
      verify(() => bookRepository.getById('b-1')).called(1);
    },
  );

  test('getBookCard reads the embedded book without an extra fetch', () async {
    when(() => remote.getBookCard('b-1')).thenAnswer((_) async => _shelfItem());

    final result = await repository.getBookCard('b-1');

    final entry = result.getOrElse(() => fail('expected the card'));
    expect(entry.id, 'ub-1');
    expect(entry.book.id, 'b-1');
    expect(entry.book.title, 'Atomic Habits');
    // The response embeds the book — nothing to resolve.
    verifyNever(() => bookRepository.getById(any()));
  });
}
