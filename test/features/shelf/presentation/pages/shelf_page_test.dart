import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/core/di/injection.dart';
import 'package:mobile/features/books/domain/entities/book.dart';
import 'package:mobile/features/shelf/domain/entities/user_book.dart';
import 'package:mobile/features/shelf/domain/repositories/shelf_repository.dart';
import 'package:mobile/features/shelf/domain/usecases/list_shelf.dart';
import 'package:mobile/features/shelf/domain/usecases/start_reread.dart';
import 'package:mobile/features/shelf/domain/usecases/update_shelf_status.dart';
import 'package:mobile/features/shelf/presentation/cubit/shelf_cubit.dart';
import 'package:mobile/features/shelf/presentation/pages/shelf_page.dart';
import 'package:mobile/features/shelf/presentation/widgets/shelf_book_card.dart';
import 'package:mobile/l10n/app_localizations.dart';
import 'package:mocktail/mocktail.dart';

class _MockShelfRepository extends Mock implements ShelfRepository {}

const _longTitle =
    'The 5 AM Club: Bangun Rutinitas Pagi Untuk Level Up Hidupmu!';

Book _book(String title, {int? totalPages = 320}) => Book(
  id: 'book-$title',
  source: 'google_books',
  googleBooksId: 'g1',
  isbn10: null,
  isbn13: null,
  title: title,
  authors: const ['James Clear'],
  description: null,
  coverUrl: null,
  totalPages: totalPages,
  language: 'en',
  genres: const [],
  publishedDate: '2018',
);

UserBook _userBook(String title, {ShelfStatus status = ShelfStatus.reading}) =>
    UserBook(
      id: 'ub-$title',
      book: _book(title),
      status: status,
      format: null,
      currentPage: 50,
      startedAt: null,
      finishedAt: null,
      rating: null,
      isReread: false,
      readCount: 1,
    );

void main() {
  late _MockShelfRepository repository;

  setUp(() {
    repository = _MockShelfRepository();
    final books = [
      _userBook('Atomic Habits'),
      _userBook(_longTitle),
      _userBook('Bumi Manusia', status: ShelfStatus.finished),
      _userBook('Deep Work'),
    ];

    when(
      () => repository.listShelf(
        status: any(named: 'status'),
        page: any(named: 'page'),
      ),
    ).thenAnswer((_) async => Right(books));

    getIt.registerFactory<ShelfCubit>(
      () => ShelfCubit(
        ListShelf(repository),
        UpdateShelfStatus(repository),
        StartReread(repository),
      ),
    );
  });

  tearDown(() async => getIt.reset());

  Future<void> pumpShelf(WidgetTester tester) async {
    // A phone, so the two columns are the width they would really be.
    tester.view.physicalSize = const Size(390 * 2, 844 * 2);
    tester.view.devicePixelRatio = 2;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: const ShelfPage(),
      ),
    );
    await tester.pumpAndSettle();
  }

  Rect cardAt(WidgetTester tester, int index) =>
      tester.getRect(find.byType(ShelfBookCard).at(index));

  testWidgets('lays the shelf out two books per row', (tester) async {
    await pumpShelf(tester);

    final first = cardAt(tester, 0);
    final second = cardAt(tester, 1);
    final third = cardAt(tester, 2);

    expect(first.left, lessThan(second.left));
    expect(second.top, first.top);
    expect(third.top, greaterThan(first.top));
    expect(tester.takeException(), isNull);
  });

  testWidgets('both cards in a row share the taller one\'s height, so the '
      'grid stays square', (tester) async {
    await pumpShelf(tester);

    // Card 0 is "Atomic Habits", card 1 the long title beside it.
    expect(cardAt(tester, 1).height, cardAt(tester, 0).height);
    expect(cardAt(tester, 1).height, greaterThan(0));
  });

  testWidgets('a long title is laid out in full, never ellipsized', (
    tester,
  ) async {
    await pumpShelf(tester);

    final title = tester.widget<Text>(find.text(_longTitle));
    expect(title.maxLines, isNull);
    expect(title.overflow, isNot(TextOverflow.ellipsis));
    expect(tester.takeException(), isNull);
  });
}
