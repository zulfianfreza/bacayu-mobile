import 'dart:async';

import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/core/di/injection.dart';
import 'package:mobile/core/error/failure.dart';
import 'package:mobile/features/books/domain/entities/book.dart';
import 'package:mobile/features/books/domain/repositories/book_repository.dart';
import 'package:mobile/features/books/domain/usecases/get_book_detail.dart';
import 'package:mobile/features/books/presentation/pages/book_detail_page.dart';
import 'package:mobile/features/shelf/domain/entities/user_book.dart';
import 'package:mobile/features/shelf/domain/repositories/shelf_repository.dart';
import 'package:mobile/features/shelf/domain/usecases/list_shelf.dart';
import 'package:mobile/features/shelf/domain/usecases/start_reread.dart';
import 'package:mobile/features/shelf/domain/usecases/update_shelf_status.dart';
import 'package:mobile/features/shelf/presentation/cubit/shelf_cubit.dart';
import 'package:mobile/features/shelf/presentation/widgets/reread_confirm_sheet.dart';
import 'package:mobile/features/shelf/presentation/widgets/shelf_book_card.dart';
import 'package:mobile/features/shelf/presentation/widgets/status_picker_bottom_sheet.dart';
import 'package:mobile/l10n/app_localizations.dart';
import 'package:mocktail/mocktail.dart';

class _MockShelfRepository extends Mock implements ShelfRepository {}

class _MockBookRepository extends Mock implements BookRepository {}

Book _book(String title) => Book(
  id: 'book-1',
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

UserBook _userBook({
  String title = 'Atomic Habits',
  ShelfStatus status = ShelfStatus.reading,
  int currentPage = 50,
  int readCount = 1,
}) => UserBook(
  id: 'ub-1',
  book: _book(title),
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
  late _MockShelfRepository shelfRepository;
  late _MockBookRepository bookRepository;

  setUp(() {
    shelfRepository = _MockShelfRepository();
    bookRepository = _MockBookRepository();
    // BookDetailPage kicks off its fetch as soon as it's built — stub it
    // with a Future that never resolves. These tests only assert on
    // navigation having happened (and with which bookId), not on the
    // detail page's fetched content.
    when(
      () => bookRepository.getById(any()),
    ).thenAnswer((_) => Completer<Either<Failure, Book>>().future);

    if (getIt.isRegistered<GetBookDetail>()) getIt.unregister<GetBookDetail>();
    getIt.registerFactory<GetBookDetail>(() => GetBookDetail(bookRepository));
  });

  tearDown(() {
    if (getIt.isRegistered<GetBookDetail>()) getIt.unregister<GetBookDetail>();
  });

  Widget wrap(UserBook userBook) {
    return BlocProvider<ShelfCubit>(
      create: (_) => ShelfCubit(
        ListShelf(shelfRepository),
        UpdateShelfStatus(shelfRepository),
        StartReread(shelfRepository),
      ),
      child: MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(
          // One grid column wide, stacked in a Column so the tile takes its
          // natural height the way a shelf row gives it.
          body: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(width: 173, child: ShelfBookCard(userBook: userBook)),
            ],
          ),
        ),
      ),
    );
  }

  /// Mirrors how the home screen's "Continue reading" row sizes itself: a
  /// fixed slot width, and no height of its own.
  Widget wrapCompact(UserBook userBook, {double textScale = 1.0}) {
    return BlocProvider<ShelfCubit>(
      create: (_) => ShelfCubit(
        ListShelf(shelfRepository),
        UpdateShelfStatus(shelfRepository),
        StartReread(shelfRepository),
      ),
      child: MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(
          body: Builder(
            builder: (outer) => MediaQuery(
              data: MediaQuery.of(
                outer,
              ).copyWith(textScaler: TextScaler.linear(textScale)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    width: 280,
                    child: ShelfBookCard.compact(userBook: userBook),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  double compactHeight(WidgetTester tester) =>
      tester.getSize(find.byType(ShelfBookCard)).height;

  testWidgets(
    'tapping the cover/title area navigates to BookDetailPage with the '
    "book's id",
    (tester) async {
      await tester.pumpWidget(wrap(_userBook()));

      await tester.tap(find.text('Atomic Habits'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.byType(BookDetailPage), findsOneWidget);
      final page = tester.widget<BookDetailPage>(find.byType(BookDetailPage));
      expect(page.bookId, 'book-1');
    },
  );

  testWidgets('tapping the progress bar area also navigates to BookDetailPage '
      '(status: reading)', (tester) async {
    await tester.pumpWidget(wrap(_userBook(status: ShelfStatus.reading)));

    await tester.tap(find.byType(LinearProgressIndicator));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.byType(BookDetailPage), findsOneWidget);
    final page = tester.widget<BookDetailPage>(find.byType(BookDetailPage));
    expect(page.bookId, 'book-1');
  });

  testWidgets(
    'tapping the cover navigates to BookDetailPage with the book\'s id',
    (tester) async {
      await tester.pumpWidget(wrap(_userBook()));

      // No cover URL in the fixture, so the placeholder is the cover.
      await tester.tap(find.byIcon(Icons.menu_book));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.byType(BookDetailPage), findsOneWidget);
    },
  );

  testWidgets('a long title is laid out in full, never ellipsized', (
    tester,
  ) async {
    const long = 'The 100-Year-Old Man Who Climbed Out the Window';
    await tester.pumpWidget(
      wrap(
        UserBook(
          id: 'ub-1',
          book: Book(
            id: 'book-1',
            source: 'google_books',
            googleBooksId: 'g1',
            isbn10: null,
            isbn13: null,
            title: long,
            authors: const ['Jonas Jonasson'],
            description: null,
            coverUrl: null,
            totalPages: 320,
            language: 'en',
            genres: const [],
            publishedDate: '2012',
          ),
          status: ShelfStatus.reading,
          format: null,
          currentPage: 50,
          startedAt: null,
          finishedAt: null,
          rating: null,
          isReread: false,
          readCount: 1,
        ),
      ),
    );

    final title = tester.widget<Text>(find.text(long));
    expect(title.maxLines, isNull);
    expect(title.overflow, isNot(TextOverflow.ellipsis));
    expect(tester.takeException(), isNull);
  });

  testWidgets(
    'tapping the status chip opens StatusPickerBottomSheet, and does NOT '
    'navigate to BookDetailPage',
    (tester) async {
      await tester.pumpWidget(wrap(_userBook(status: ShelfStatus.reading)));

      // "Reading" only appears once in this tree — as the status chip label.
      await tester.tap(find.text('Reading'));
      await tester.pumpAndSettle();

      expect(find.byType(StatusPickerBottomSheet), findsOneWidget);
      expect(find.byType(BookDetailPage), findsNothing);
    },
  );

  testWidgets(
    'compact variant is as tall as its content, and drops the redundant '
    'status chip',
    (tester) async {
      await tester.pumpWidget(wrapCompact(_userBook(title: 'Dune')));
      final oneLine = compactHeight(tester);

      await tester.pumpWidget(wrapCompact(_userBook()));
      final twoLines = compactHeight(tester);

      expect(tester.takeException(), isNull);
      expect(find.text('Reading'), findsNothing);
      expect(find.byType(LinearProgressIndicator), findsOneWidget);

      // Nothing is reserved for a title that isn't there, and nothing is cut
      // off: more title, taller card.
      expect(twoLines, greaterThan(oneLine));

      await tester.pumpWidget(
        wrapCompact(
          _userBook(title: 'The 100-Year-Old Man Who Climbed Out the Window'),
        ),
      );
      expect(compactHeight(tester), greaterThan(twoLines));
    },
  );

  testWidgets('compact variant still fits when the user has larger type set', (
    tester,
  ) async {
    await tester.pumpWidget(wrapCompact(_userBook(), textScale: 1.5));

    expect(tester.takeException(), isNull);
  });

  testWidgets(
    'a book read more than once carries the neutral read-count badge',
    (tester) async {
      await tester.pumpWidget(
        wrap(_userBook(status: ShelfStatus.finished, readCount: 2)),
      );

      expect(find.text('Read 2×'), findsOneWidget);
    },
  );

  group('reread', () {
    testWidgets('button only appears on finished cards', (tester) async {
      await tester.pumpWidget(wrap(_userBook(status: ShelfStatus.reading)));
      expect(find.text('Read again'), findsNothing);

      await tester.pumpWidget(wrap(_userBook(status: ShelfStatus.finished)));
      expect(find.text('Read again'), findsOneWidget);
    });

    testWidgets(
      'tapping the button only opens the confirmation sheet; confirming is '
      'what calls StartReread',
      (tester) async {
        final reread = _userBook(status: ShelfStatus.reading);
        when(
          () => shelfRepository.startReread(any()),
        ).thenAnswer((_) async => Right(reread));
        // startReread re-fetches the shelf so the book's card flips to the
        // new reading row.
        when(
          () => shelfRepository.listShelf(
            status: any(named: 'status'),
            page: any(named: 'page'),
          ),
        ).thenAnswer((_) async => Right(<UserBook>[reread]));

        await tester.pumpWidget(wrap(_userBook(status: ShelfStatus.finished)));

        await tester.tap(find.text('Read again'));
        await tester.pumpAndSettle();

        expect(find.byType(RereadConfirmSheet), findsOneWidget);
        verifyNever(() => shelfRepository.startReread(any()));

        await tester.tap(find.text('Start reread'));
        await tester.pumpAndSettle();

        verify(() => shelfRepository.startReread('book-1')).called(1);
      },
    );
  });
}
