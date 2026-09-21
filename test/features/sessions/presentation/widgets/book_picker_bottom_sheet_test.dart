import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/core/di/injection.dart';
import 'package:mobile/features/books/domain/entities/book.dart';
import 'package:mobile/features/sessions/presentation/widgets/book_picker_bottom_sheet.dart';
import 'package:mobile/features/shelf/domain/entities/user_book.dart';
import 'package:mobile/features/shelf/domain/usecases/list_shelf.dart';
import 'package:mobile/l10n/app_localizations.dart';
import 'package:mocktail/mocktail.dart';

class _MockListShelf extends Mock implements ListShelf {}

Book _book({
  required String title,
  List<String> authors = const ['James Clear'],
  int? totalPages = 320,
}) => Book(
  id: 'book-$title',
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

UserBook _userBook(Book book, {int currentPage = 50}) => UserBook(
  id: 'ub-${book.id}',
  book: book,
  status: ShelfStatus.reading,
  format: null,
  currentPage: currentPage,
  startedAt: null,
  finishedAt: null,
  rating: null,
  isReread: false,
  readCount: 1,
);

void main() {
  late _MockListShelf listShelf;

  setUp(() {
    listShelf = _MockListShelf();
    getIt.registerFactory<ListShelf>(() => listShelf);
  });

  tearDown(() async => getIt.reset());

  /// Opens the sheet the way the shell does, and captures whatever the sheet
  /// pops with.
  Future<void> openSheet(
    WidgetTester tester,
    List<UserBook> books, {
    void Function(UserBook?)? onResult,
  }) async {
    when(
      () => listShelf.call(status: any(named: 'status')),
    ).thenAnswer((_) async => Right(books));

    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(
          body: Builder(
            builder: (context) => TextButton(
              onPressed: () async {
                final picked = await showModalBottomSheet<UserBook>(
                  context: context,
                  // Same call the shell makes — without this the sheet is
                  // capped at 9/16 of the screen and the list gets squeezed.
                  isScrollControlled: true,
                  builder: (_) => const BookPickerBottomSheet(),
                );
                onResult?.call(picked);
              },
              child: const Text('open'),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
  }

  testWidgets('shows the subtitle under the heading', (tester) async {
    await openSheet(tester, [_userBook(_book(title: 'Atomic Habits'))]);

    expect(find.text('What are you reading?'), findsOneWidget);
    expect(
      find.text("Pick the book you're reading now to start a session."),
      findsOneWidget,
    );
  });

  testWidgets('each row carries the author and the page progress', (
    tester,
  ) async {
    await openSheet(tester, [
      _userBook(_book(title: 'Atomic Habits'), currentPage: 50),
      _userBook(
        _book(title: 'Deep Work', authors: const ['Cal Newport']),
        currentPage: 12,
      ),
    ]);

    expect(find.text('Atomic Habits'), findsOneWidget);
    expect(find.text('by James Clear'), findsOneWidget);
    expect(find.text('Page 50 of 320'), findsOneWidget);

    expect(find.text('Deep Work'), findsOneWidget);
    expect(find.text('by Cal Newport'), findsOneWidget);
    expect(find.text('Page 12 of 320'), findsOneWidget);
  });

  testWidgets('a book with no page count shows no progress line', (
    tester,
  ) async {
    await openSheet(tester, [
      _userBook(_book(title: 'Atomic Habits', totalPages: null)),
    ]);

    expect(find.text('by James Clear'), findsOneWidget);
    expect(find.textContaining('Page'), findsNothing);
  });

  testWidgets('a book with no authors still shows its title and progress', (
    tester,
  ) async {
    await openSheet(tester, [
      _userBook(_book(title: 'Anonymous Work', authors: const [])),
    ]);

    expect(find.text('Anonymous Work'), findsOneWidget);
    expect(find.text('Page 50 of 320'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('nothing in progress gets the empty state, not an empty list', (
    tester,
  ) async {
    await openSheet(tester, const []);

    expect(
      find.text('No books in progress. Add one to your shelf first.'),
      findsOneWidget,
    );
    expect(find.byIcon(Icons.menu_book_outlined), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('tapping a row pops with that shelf entry', (tester) async {
    UserBook? picked;
    final first = _userBook(_book(title: 'Atomic Habits'));
    final second = _userBook(_book(title: 'Deep Work'));

    await openSheet(tester, [
      first,
      second,
    ], onResult: (result) => picked = result);

    await tester.tap(find.text('Deep Work'));
    await tester.pumpAndSettle();

    // The sheet is gone, and it was the tapped entry that came back.
    expect(find.byType(BookPickerBottomSheet), findsNothing);
    expect(picked?.id, second.id);
    expect(tester.takeException(), isNull);
  });
}
