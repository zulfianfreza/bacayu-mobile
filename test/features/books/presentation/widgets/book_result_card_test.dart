import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/features/books/domain/entities/book.dart';
import 'package:mobile/features/books/presentation/widgets/book_result_card.dart';
import 'package:mobile/l10n/app_localizations.dart';

Book _book({
  String title = 'Atomic Habits',
  List<String> authors = const ['James Clear'],
  int? totalPages = 320,
}) => Book(
  id: 'book-1',
  source: 'google_books',
  googleBooksId: 'g1',
  isbn10: null,
  isbn13: null,
  title: title,
  authors: authors,
  description: null,
  coverUrl: null,
  totalPages: totalPages,
  language: 'en',
  genres: const [],
  publishedDate: '2018',
);

void main() {
  Future<void> pumpCard(WidgetTester tester, BookResultCard card) async {
    await tester.pumpWidget(
      MaterialApp(
        // Pinned to the app's primary locale so the assertions below can name
        // the strings it actually ships with.
        locale: const Locale('id'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(body: card),
      ),
    );
  }

  testWidgets('carries the title, author and page count', (tester) async {
    await pumpCard(tester, BookResultCard(book: _book()));

    expect(find.text('Atomic Habits'), findsOneWidget);
    expect(find.text('oleh James Clear'), findsOneWidget);
    expect(find.text('320 halaman'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('a long title wraps in full rather than being cut off', (
    tester,
  ) async {
    const long = 'The 100-Year-Old Man Who Climbed Out the Window';
    await pumpCard(tester, BookResultCard(book: _book(title: long)));

    final title = tester.widget<Text>(find.text(long));
    expect(title.maxLines, isNull);
    expect(title.overflow, isNot(TextOverflow.ellipsis));
    expect(tester.takeException(), isNull);
  });

  testWidgets('the add tile only exists when there is something to add to', (
    tester,
  ) async {
    await pumpCard(tester, BookResultCard(book: _book()));
    expect(find.byIcon(Icons.add_rounded), findsNothing);

    await pumpCard(tester, BookResultCard(book: _book(), onAdd: () {}));
    expect(find.byIcon(Icons.add_rounded), findsOneWidget);
  });

  testWidgets('tapping the add tile fires the handler', (tester) async {
    var added = false;
    await pumpCard(
      tester,
      BookResultCard(book: _book(), onAdd: () => added = true),
    );

    await tester.tap(find.byIcon(Icons.add_rounded));
    await tester.pump();

    expect(added, isTrue);
  });
}
