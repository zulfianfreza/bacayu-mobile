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
import 'package:mobile/features/shelf/domain/usecases/update_shelf_status.dart';
import 'package:mobile/features/shelf/presentation/cubit/shelf_cubit.dart';
import 'package:mobile/features/shelf/presentation/widgets/shelf_book_card.dart';
import 'package:mobile/features/shelf/presentation/widgets/status_picker_bottom_sheet.dart';
import 'package:mobile/l10n/app_localizations.dart';
import 'package:mocktail/mocktail.dart';

class _MockShelfRepository extends Mock implements ShelfRepository {}

class _MockBookRepository extends Mock implements BookRepository {}

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
  ShelfStatus status = ShelfStatus.reading,
  int currentPage = 50,
}) =>
    UserBook(
      id: 'ub-1',
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
  late _MockShelfRepository shelfRepository;
  late _MockBookRepository bookRepository;

  setUp(() {
    shelfRepository = _MockShelfRepository();
    bookRepository = _MockBookRepository();
    // BookDetailPage kicks off its fetch as soon as it's built — stub it
    // with a Future that never resolves. These tests only assert on
    // navigation having happened (and with which bookId), not on the
    // detail page's fetched content.
    when(() => bookRepository.getById(any()))
        .thenAnswer((_) => Completer<Either<Failure, Book>>().future);

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

  /// Mirrors how the home screen's "Continue reading" row sizes itself.
  Widget wrapCompact(UserBook userBook, {double textScale = 1.0}) {
    return BlocProvider<ShelfCubit>(
      create: (_) => ShelfCubit(
        ListShelf(shelfRepository),
        UpdateShelfStatus(shelfRepository),
      ),
      child: MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(
          body: Builder(
            builder: (outer) => MediaQuery(
              data: MediaQuery.of(outer)
                  .copyWith(textScaler: TextScaler.linear(textScale)),
              child: Builder(
                builder: (context) => SizedBox(
                  width: 280,
                  height: ShelfBookCard.compactHeightFor(context),
                  child: ShelfBookCard.compact(userBook: userBook),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  testWidgets(
      'tapping the cover/title area navigates to BookDetailPage with the '
      "book's id", (tester) async {
    await tester.pumpWidget(wrap(_userBook()));

    await tester.tap(find.text('Atomic Habits'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.byType(BookDetailPage), findsOneWidget);
    final page = tester.widget<BookDetailPage>(find.byType(BookDetailPage));
    expect(page.bookId, 'book-1');
  });

  testWidgets(
      'tapping the progress bar area also navigates to BookDetailPage '
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
  });

  testWidgets('a long title is laid out in full, never ellipsized',
      (tester) async {
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
      'navigate to BookDetailPage', (tester) async {
    await tester.pumpWidget(wrap(_userBook(status: ShelfStatus.reading)));

    // "Reading" only appears once in this tree — as the status chip label.
    await tester.tap(find.text('Reading'));
    await tester.pumpAndSettle();

    expect(find.byType(StatusPickerBottomSheet), findsOneWidget);
    expect(find.byType(BookDetailPage), findsNothing);
  });

  testWidgets(
      'compact variant fits the height it declares for a carousel slot, and '
      'drops the redundant status chip', (tester) async {
    await tester.pumpWidget(wrapCompact(_userBook()));

    expect(tester.takeException(), isNull);
    expect(find.text('Reading'), findsNothing);
    expect(find.byType(LinearProgressIndicator), findsOneWidget);
    expect(find.text('Atomic Habits'), findsOneWidget);
  });

  testWidgets(
      'compact variant still fits when the user has larger type set',
      (tester) async {
    await tester.pumpWidget(wrapCompact(_userBook(), textScale: 1.5));

    expect(tester.takeException(), isNull);
  });
}
