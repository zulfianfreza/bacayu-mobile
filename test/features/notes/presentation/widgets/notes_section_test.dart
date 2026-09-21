import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/core/di/injection.dart';
import 'package:mobile/core/error/failure.dart';
import 'package:mobile/core/widgets/chunky_button.dart';
import 'package:mobile/features/books/domain/entities/book.dart';
import 'package:mobile/features/notes/domain/entities/note.dart';
import 'package:mobile/features/notes/domain/repositories/note_repository.dart';
import 'package:mobile/features/notes/domain/usecases/create_note.dart';
import 'package:mobile/features/notes/domain/usecases/delete_note.dart';
import 'package:mobile/features/notes/domain/usecases/list_notes.dart';
import 'package:mobile/features/notes/domain/usecases/update_note.dart';
import 'package:mobile/features/notes/presentation/cubit/notes_cubit.dart';
import 'package:mobile/features/notes/presentation/widgets/notes_section.dart';
import 'package:mobile/features/shelf/domain/entities/user_book.dart';
import 'package:mobile/l10n/app_localizations.dart';
import 'package:mocktail/mocktail.dart';

class _MockNoteRepository extends Mock implements NoteRepository {}

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

UserBook _userBook() => const UserBook(
  id: 'ub-1',
  book: _book,
  status: ShelfStatus.finished,
  format: null,
  currentPage: 320,
  startedAt: null,
  finishedAt: null,
  rating: null,
  isReread: false,
  readCount: 1,
);

Note _note({
  String id = 'n-1',
  String content = 'Catatan isinya',
  int? page,
  String? quote,
}) => Note(
  id: id,
  userBookId: 'ub-1',
  content: content,
  page: page,
  quote: quote,
  createdAt: DateTime.utc(2026, 9, 1),
  updatedAt: DateTime.utc(2026, 9, 1),
);

void main() {
  late _MockNoteRepository repository;

  setUp(() {
    repository = _MockNoteRepository();
    getIt.registerFactory<NotesCubit>(
      () => NotesCubit(
        ListNotes(repository),
        CreateNote(repository),
        UpdateNote(repository),
        DeleteNote(repository),
      ),
    );
  });

  tearDown(() async => getIt.reset());

  Future<void> pumpSection(
    WidgetTester tester, {
    List<Note> notes = const [],
  }) async {
    when(
      () => repository.listNotes(userBookId: 'ub-1', page: 1),
    ).thenAnswer((_) async => Right(notes));

    await tester.pumpWidget(
      MaterialApp(
        locale: const Locale('id'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(
          body: SingleChildScrollView(child: NotesSection(userBook: _userBook())),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('a note row leads with the quote and marks the page', (
    tester,
  ) async {
    await pumpSection(
      tester,
      notes: [_note(page: 42, quote: 'Kutipan panjang')],
    );

    expect(find.text('Catatan'), findsOneWidget);
    expect(find.text('Kutipan panjang'), findsOneWidget);
    expect(find.text('Catatan isinya'), findsOneWidget);
    expect(find.text('hlm. 42'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('an empty read still offers to add a note', (tester) async {
    await pumpSection(tester);

    expect(find.text('Catatan'), findsOneWidget);
    expect(find.text('Tambah catatan'), findsOneWidget);
    expect(find.text('Simpan kutipan dan pikiranmu saat membaca.'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('save stays disabled until the note has content', (tester) async {
    await pumpSection(tester);

    await tester.tap(find.text('Tambah catatan'));
    await tester.pumpAndSettle();

    expect(find.text('Catatan baru'), findsOneWidget);
    expect(
      tester.widget<ChunkyButton>(find.byType(ChunkyButton)).onPressed,
      isNull,
    );

    await tester.enterText(find.byType(TextField).first, 'Baru');
    await tester.pump();

    expect(
      tester.widget<ChunkyButton>(find.byType(ChunkyButton)).onPressed,
      isNotNull,
    );
  });

  testWidgets('saving the editor writes the note, then refreshes the list', (
    tester,
  ) async {
    await pumpSection(tester, notes: [_note()]);

    when(
      () => repository.createNote(
        userBookId: 'ub-1',
        content: 'Catatan baru',
        page: null,
        quote: null,
      ),
    ).thenAnswer((_) async => Right(_note(id: 'n-2', content: 'Catatan baru')));

    await tester.tap(find.text('Tambah catatan'));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField).first, 'Catatan baru');
    // The save button only enables on rebuild; without this pump the tap below
    // lands on a disabled button.
    await tester.pump();

    await tester.tap(find.text('Simpan'));
    await tester.pumpAndSettle();

    verify(
      () => repository.createNote(
        userBookId: 'ub-1',
        content: 'Catatan baru',
        page: null,
        quote: null,
      ),
    ).called(1);
    verify(
      () => repository.listNotes(userBookId: 'ub-1', page: 1),
    ).called(2);
  });

  testWidgets('deleting asks for confirmation before it removes the note', (
    tester,
  ) async {
    await pumpSection(tester, notes: [_note()]);

    when(() => repository.deleteNote('n-1')).thenAnswer(
      (_) async => const Right<Failure, void>(null),
    );

    await tester.tap(find.text('Catatan isinya'));
    await tester.pumpAndSettle();

    expect(find.text('Ubah catatan'), findsOneWidget);

    await tester.tap(find.text('Hapus catatan'));
    await tester.pumpAndSettle();

    // The dialog is up: nothing has been deleted yet.
    expect(find.text('Hapus catatan ini?'), findsOneWidget);
    verifyNever(() => repository.deleteNote(any()));

    await tester.tap(
      find.descendant(
        of: find.byType(AlertDialog),
        matching: find.text('Hapus catatan'),
      ),
    );
    await tester.pumpAndSettle();

    verify(() => repository.deleteNote('n-1')).called(1);
    verify(
      () => repository.listNotes(userBookId: 'ub-1', page: 1),
    ).called(2);
  });
}
