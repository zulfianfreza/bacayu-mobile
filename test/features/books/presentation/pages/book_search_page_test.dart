import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/core/di/injection.dart';
import 'package:mobile/core/error/failure.dart';
import 'package:mobile/features/books/domain/entities/book.dart';
import 'package:mobile/features/books/domain/usecases/import_book_from_google.dart';
import 'package:mobile/features/books/domain/usecases/search_books.dart';
import 'package:mobile/features/books/presentation/bloc/book_search_bloc.dart';
import 'package:mobile/features/books/presentation/pages/book_search_page.dart';
import 'package:mobile/features/books/presentation/widgets/book_result_card.dart';
import 'package:mobile/l10n/app_localizations.dart';
import 'package:mocktail/mocktail.dart';

class _MockSearchBooks extends Mock implements SearchBooks {}

class _MockImportBookFromGoogle extends Mock implements ImportBookFromGoogle {}

/// An `Image` drawing [path] from the asset bundle.
Finder _assetImage(String path) => find.byWidgetPredicate(
  (widget) =>
      widget is Image &&
      widget.image is AssetImage &&
      (widget.image as AssetImage).assetName == path,
);

Book _book() => const Book(
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

void main() {
  late _MockSearchBooks searchBooks;

  setUp(() {
    searchBooks = _MockSearchBooks();
    when(() => searchBooks.call(any())).thenAnswer(
      (_) async => Right([_book()]),
    );

    getIt.registerFactory<BookSearchBloc>(
      () => BookSearchBloc(searchBooks, _MockImportBookFromGoogle()),
    );
  });

  tearDown(() async => getIt.reset());

  Future<void> pumpSearch(WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        // Pinned to the app's primary locale so the assertions below can name
        // the strings it actually ships with.
        locale: const Locale('id'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: const BookSearchPage(),
      ),
    );
    await tester.pump();
  }

  /// Types a query and waits out the bloc's search debounce.
  Future<void> search(WidgetTester tester, String query) async {
    await tester.enterText(find.byType(TextField), query);
    await tester.pump(const Duration(milliseconds: 500));
    await tester.pump();
  }

  testWidgets('opens on its own title with a chunky search field', (
    tester,
  ) async {
    await pumpSearch(tester);

    expect(find.text('Tambah buku'), findsOneWidget);
    expect(find.text('Cari judul, penulis, atau ISBN'), findsOneWidget);
    expect(find.byTooltip('Scan barcode'), findsOneWidget);
    // Both glyphs are the app's own artwork, not Material icons.
    expect(_assetImage('assets/icons/search-stroke.png'), findsOneWidget);
    expect(
      _assetImage('assets/icons/barcode-scan-stroke.png'),
      findsOneWidget,
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('results render as book cards with an add tile', (tester) async {
    await pumpSearch(tester);
    await search(tester, 'atomic');

    expect(find.byType(BookResultCard), findsOneWidget);
    expect(find.text('Atomic Habits'), findsOneWidget);
    expect(find.byIcon(Icons.add_rounded), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('nothing matched gets a message, not an empty screen', (
    tester,
  ) async {
    when(() => searchBooks.call(any())).thenAnswer(
      (_) async => const Right(<Book>[]),
    );

    await pumpSearch(tester);
    await search(tester, 'zzzz');

    expect(
      find.text('Buku tidak ditemukan. Coba kata kunci lain.'),
      findsOneWidget,
    );
    expect(find.byType(BookResultCard), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('a failed search says so', (tester) async {
    when(() => searchBooks.call(any()))
        .thenAnswer((_) async => const Left(CacheFailure()));

    await pumpSearch(tester);
    await search(tester, 'atomic');

    expect(find.byIcon(Icons.cloud_off), findsOneWidget);
    expect(find.byType(BookResultCard), findsNothing);
    expect(tester.takeException(), isNull);
  });
}
