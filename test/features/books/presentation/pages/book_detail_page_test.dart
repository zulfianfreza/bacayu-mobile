import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/core/di/injection.dart';
import 'package:mobile/core/error/failure.dart';
import 'package:mobile/features/books/domain/entities/book.dart';
import 'package:mobile/features/books/domain/usecases/get_book_detail.dart';
import 'package:mobile/features/books/presentation/pages/book_detail_page.dart';
import 'package:mobile/features/shelf/domain/entities/book_read.dart';
import 'package:mobile/features/shelf/domain/entities/user_book.dart';
import 'package:mobile/features/shelf/domain/usecases/get_book_reads.dart';
import 'package:mobile/l10n/app_localizations.dart';
import 'package:mocktail/mocktail.dart';

class _MockGetBookDetail extends Mock implements GetBookDetail {}

class _MockGetBookReads extends Mock implements GetBookReads {}

Book _book({String? description, List<String> genres = const ['Self-help']}) =>
    Book(
      id: 'book-1',
      source: 'google_books',
      googleBooksId: 'g1',
      isbn10: null,
      isbn13: null,
      title: 'Atomic Habits',
      authors: const ['James Clear'],
      description: description,
      coverUrl: null,
      totalPages: 320,
      language: 'en',
      genres: genres,
      publishedDate: '2018',
    );

void main() {
  late _MockGetBookDetail getBookDetail;
  late _MockGetBookReads getBookReads;

  setUp(() {
    getBookDetail = _MockGetBookDetail();
    getBookReads = _MockGetBookReads();
    getIt.registerFactory<GetBookDetail>(() => getBookDetail);
    getIt.registerFactory<GetBookReads>(() => getBookReads);
  });

  tearDown(() async => getIt.reset());

  Future<void> pumpDetail(
    WidgetTester tester,
    Book book, {
    List<BookRead> reads = const [],
  }) async {
    when(() => getBookDetail.call(any())).thenAnswer((_) async => Right(book));
    when(() => getBookReads.call(any())).thenAnswer((_) async => Right(reads));

    await tester.pumpWidget(
      MaterialApp(
        // Pinned to the app's primary locale so the assertions below can name
        // the strings it actually ships with.
        locale: const Locale('id'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: const BookDetailPage(bookId: 'book-1'),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('the identity card carries the title, author and facts', (
    tester,
  ) async {
    await pumpDetail(tester, _book());

    expect(find.text('Atomic Habits'), findsOneWidget);
    expect(find.text('oleh James Clear'), findsOneWidget);
    expect(find.text('320 halaman'), findsOneWidget);
    expect(find.text('Self-help'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('the synopsis gets its own titled card', (tester) async {
    await pumpDetail(tester, _book(description: 'A great book.'));

    expect(find.text('Sinopsis'), findsOneWidget);
    expect(find.text('A great book.'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('a book without a description shows no synopsis card', (
    tester,
  ) async {
    await pumpDetail(tester, _book());

    expect(find.text('Sinopsis'), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('a genre that runs long wraps instead of overflowing', (
    tester,
  ) async {
    // A phone-width viewport on purpose: at the default test size the chip
    // might still fit on one line, which would hide the case this guards.
    tester.view.physicalSize = const Size(390 * 2, 900 * 2);
    tester.view.devicePixelRatio = 2;
    addTearDown(tester.view.reset);

    const longGenre = 'Foreign Language Study / English as a Second Language';
    await pumpDetail(tester, _book(genres: const [longGenre]));

    // Shown in full, not truncated — and no "RenderFlex overflowed" either.
    expect(find.text(longGenre), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('a failed load shows the reason instead of an empty page', (
    tester,
  ) async {
    when(
      () => getBookDetail.call(any()),
    ).thenAnswer((_) async => const Left(CacheFailure()));

    await tester.pumpWidget(
      MaterialApp(
        locale: const Locale('id'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: const BookDetailPage(bookId: 'book-1'),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byIcon(Icons.menu_book_outlined), findsOneWidget);
    expect(find.text('Atomic Habits'), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('a book read more than once lists its read history', (
    tester,
  ) async {
    final first = BookRead(
      id: 'read-1',
      status: ShelfStatus.finished,
      currentPage: 320,
      rating: 4,
      isReread: false,
      startedAt: DateTime.utc(2025, 1, 5),
      finishedAt: DateTime.utc(2025, 2, 11),
      createdAt: DateTime.utc(2025, 1, 5),
    );
    final reread = BookRead(
      id: 'read-2',
      status: ShelfStatus.reading,
      currentPage: 0,
      rating: null,
      isReread: true,
      startedAt: null,
      finishedAt: null,
      createdAt: DateTime.utc(2026, 9, 1),
    );

    await pumpDetail(tester, _book(), reads: [first, reread]);

    expect(find.text('Riwayat baca'), findsOneWidget);
    expect(find.text('Dibaca pertama'), findsOneWidget);
    expect(find.text('Dibaca ulang'), findsOneWidget);
    expect(find.text('4★'), findsOneWidget);
    expect(find.textContaining('Selesai'), findsOneWidget);
    expect(find.textContaining('Sedang berjalan'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('a book with a single read shows no history section', (
    tester,
  ) async {
    await pumpDetail(
      tester,
      _book(),
      reads: [
        BookRead(
          id: 'read-1',
          status: ShelfStatus.finished,
          currentPage: 320,
          rating: null,
          isReread: false,
          startedAt: null,
          finishedAt: DateTime.utc(2025, 2, 11),
          createdAt: DateTime.utc(2025, 1, 5),
        ),
      ],
    );

    expect(find.text('Riwayat baca'), findsNothing);
    expect(tester.takeException(), isNull);
  });
}
