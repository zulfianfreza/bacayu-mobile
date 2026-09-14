import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/features/books/domain/entities/book.dart';
import 'package:mobile/features/shelf/domain/entities/user_book.dart';
import 'package:mobile/features/shelf/domain/repositories/shelf_repository.dart';
import 'package:mobile/features/shelf/domain/usecases/list_shelf.dart';
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
}) =>
    UserBook(
      id: id,
      book: _book,
      status: status,
      format: null,
      currentPage: currentPage,
      startedAt: null,
      finishedAt: null,
      rating: null,
      isReread: false,
    );

void main() {
  late _MockShelfRepository repository;
  late ShelfCubit cubit;

  setUp(() {
    repository = _MockShelfRepository();
    cubit = ShelfCubit(
      ListShelf(repository),
      UpdateShelfStatus(repository),
    );
  });

  tearDown(() => cubit.close());

  group('changeFilter', () {
    test('re-fetches with the selected status', () async {
      when(() => repository.listShelf(
            status: any(named: 'status'),
            page: any(named: 'page'),
          )).thenAnswer((_) async => Right([_userBook()]));

      await cubit.changeFilter(ShelfStatus.reading);

      verify(() => repository.listShelf(status: ShelfStatus.reading, page: 1))
          .called(1);
      expect(cubit.state.activeFilter, ShelfStatus.reading);

      await cubit.changeFilter(ShelfStatus.finished);

      verify(() => repository.listShelf(status: ShelfStatus.finished, page: 1))
          .called(1);
      expect(cubit.state.activeFilter, ShelfStatus.finished);
    });
  });

  group('updateStatus', () {
    test(
        'patches the item in place on success — no refetch of the whole shelf',
        () async {
      final original = _userBook(status: ShelfStatus.reading);
      when(() => repository.listShelf(
            status: any(named: 'status'),
            page: any(named: 'page'),
          )).thenAnswer((_) async => Right([original]));

      final finished = _userBook(status: ShelfStatus.finished);
      when(() => repository.updateShelfStatus(
            userBookId: any(named: 'userBookId'),
            status: any(named: 'status'),
            currentPage: any(named: 'currentPage'),
            rating: any(named: 'rating'),
          )).thenAnswer((_) async => Right(finished));

      await cubit.loadShelf();
      await cubit.updateStatus(
        userBookId: original.id,
        status: ShelfStatus.finished,
      );

      // listShelf was only called once, from the initial loadShelf — the
      // status update must NOT trigger a refetch.
      verify(() => repository.listShelf(
            status: any(named: 'status'),
            page: any(named: 'page'),
          )).called(1);

      final state = cubit.state;
      expect(state, isA<ShelfLoaded>());
      expect(state.items, hasLength(1));
      expect(state.items.single.status, ShelfStatus.finished);
    });
  });
}
