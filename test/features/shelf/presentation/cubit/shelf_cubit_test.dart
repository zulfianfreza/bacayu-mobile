import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/core/error/failure.dart';
import 'package:mobile/features/books/domain/entities/book.dart';
import 'package:mobile/features/shelf/domain/entities/user_book.dart';
import 'package:mobile/features/shelf/domain/repositories/shelf_repository.dart';
import 'package:mobile/features/shelf/domain/usecases/list_shelf.dart';
import 'package:mobile/features/shelf/domain/usecases/start_reread.dart';
import 'package:mobile/features/shelf/domain/usecases/update_shelf_status.dart';
import 'package:mobile/features/shelf/presentation/cubit/shelf_cubit.dart';
import 'package:mobile/features/shelf/presentation/cubit/shelf_state.dart';
import 'package:mocktail/mocktail.dart';

class _MockShelfRepository extends Mock implements ShelfRepository {}

const _book = Book(
  id: 'book-1',
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

UserBook _userBook({
  String id = 'ub-1',
  ShelfStatus status = ShelfStatus.reading,
  int currentPage = 50,
  int readCount = 1,
}) => UserBook(
  id: id,
  book: _book,
  status: status,
  format: null,
  currentPage: currentPage,
  startedAt: null,
  finishedAt: null,
  rating: null,
  isReread: false,
  readCount: readCount,
);

void main() {
  late _MockShelfRepository repository;
  late ShelfCubit cubit;

  setUp(() {
    repository = _MockShelfRepository();
    cubit = ShelfCubit(
      ListShelf(repository),
      UpdateShelfStatus(repository),
      StartReread(repository),
    );
  });

  tearDown(() => cubit.close());

  group('changeFilter', () {
    test('re-fetches with the selected status', () async {
      when(
        () => repository.listShelf(
          status: any(named: 'status'),
          page: any(named: 'page'),
        ),
      ).thenAnswer((_) async => Right([_userBook()]));

      await cubit.changeFilter(ShelfStatus.reading);

      verify(
        () => repository.listShelf(status: ShelfStatus.reading, page: 1),
      ).called(1);
      expect(cubit.state.activeFilter, ShelfStatus.reading);

      await cubit.changeFilter(ShelfStatus.finished);

      verify(
        () => repository.listShelf(status: ShelfStatus.finished, page: 1),
      ).called(1);
      expect(cubit.state.activeFilter, ShelfStatus.finished);
    });
  });

  group('updateStatus', () {
    test(
      'patches the item in place on success — no refetch of the whole shelf',
      () async {
        final original = _userBook(status: ShelfStatus.reading);
        when(
          () => repository.listShelf(
            status: any(named: 'status'),
            page: any(named: 'page'),
          ),
        ).thenAnswer((_) async => Right([original]));

        final finished = _userBook(status: ShelfStatus.finished);
        when(
          () => repository.updateShelfStatus(
            userBookId: any(named: 'userBookId'),
            status: any(named: 'status'),
            currentPage: any(named: 'currentPage'),
            rating: any(named: 'rating'),
          ),
        ).thenAnswer((_) async => Right(finished));

        await cubit.loadShelf();
        await cubit.updateStatus(
          userBookId: original.id,
          status: ShelfStatus.finished,
        );

        // listShelf was only called once, from the initial loadShelf — the
        // status update must NOT trigger a refetch.
        verify(
          () => repository.listShelf(
            status: any(named: 'status'),
            page: any(named: 'page'),
          ),
        ).called(1);

        final state = cubit.state;
        expect(state, isA<ShelfLoaded>());
        expect(state.items, hasLength(1));
        expect(state.items.single.status, ShelfStatus.finished);
      },
    );

    test(
      'keeps the read_count the list gave — the badge survives a status change',
      () async {
        final original = _userBook(status: ShelfStatus.finished, readCount: 2);
        when(
          () => repository.listShelf(
            status: any(named: 'status'),
            page: any(named: 'page'),
          ),
        ).thenAnswer((_) async => Right([original]));

        // The write response is flat: no read_count comes back.
        final updated = _userBook(status: ShelfStatus.dnf);
        when(
          () => repository.updateShelfStatus(
            userBookId: any(named: 'userBookId'),
            status: any(named: 'status'),
            currentPage: any(named: 'currentPage'),
            rating: any(named: 'rating'),
          ),
        ).thenAnswer((_) async => Right(updated));

        await cubit.loadShelf();
        await cubit.updateStatus(
          userBookId: original.id,
          status: ShelfStatus.dnf,
        );

        expect(cubit.state.items.single.readCount, 2);
      },
    );
  });

  group('startReread', () {
    test(
      'refetches the shelf so the card flips to the new reading row',
      () async {
        final reread = _userBook(status: ShelfStatus.reading);
        when(
          () => repository.startReread(any()),
        ).thenAnswer((_) async => Right(reread));
        when(
          () => repository.listShelf(
            status: any(named: 'status'),
            page: any(named: 'page'),
          ),
        ).thenAnswer((_) async => Right([reread]));

        await cubit.startReread(bookId: 'book-1');

        verify(() => repository.startReread('book-1')).called(1);
        verify(
          () => repository.listShelf(
            status: any(named: 'status'),
            page: any(named: 'page'),
          ),
        ).called(1);
        expect(cubit.state.items.single.status, ShelfStatus.reading);
      },
    );

    test('on failure keeps the untouched list and reports the error', () async {
      final original = _userBook(status: ShelfStatus.finished, readCount: 3);
      when(
        () => repository.listShelf(
          status: any(named: 'status'),
          page: any(named: 'page'),
        ),
      ).thenAnswer((_) async => Right([original]));
      when(() => repository.startReread(any())).thenAnswer(
        (_) async => Left(
          ServerFailure(code: 'CANNOT_REREAD_UNFINISHED_BOOK', message: 'nope'),
        ),
      );

      await cubit.loadShelf();
      await cubit.startReread(bookId: 'book-1');

      expect(cubit.state, isA<ShelfUpdateError>());
      expect(cubit.state.items.single, original);
    });
  });
}
