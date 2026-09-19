import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/core/di/injection.dart';
import 'package:mobile/core/theme/app_colors.dart';
import 'package:mobile/core/theme/app_theme.dart';
import 'package:mobile/features/books/domain/entities/book.dart';
import 'package:mobile/features/sessions/domain/entities/reading_session.dart';
import 'package:mobile/features/sessions/domain/usecases/submit_session.dart';
import 'package:mobile/features/sessions/presentation/cubit/manual_session_cubit.dart';
import 'package:mobile/features/sessions/presentation/pages/manual_session_page.dart';
import 'package:mobile/features/shelf/domain/entities/user_book.dart';
import 'package:mobile/l10n/app_localizations.dart';
import 'package:mocktail/mocktail.dart';

class _MockSubmitSession extends Mock implements SubmitSession {}

UserBook _userBook({int currentPage = 50}) => UserBook(
  id: 'ub-1',
  book: const Book(
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
  ),
  status: ShelfStatus.reading,
  format: null,
  currentPage: currentPage,
  startedAt: null,
  finishedAt: null,
  rating: null,
  isReread: false,
);

void main() {
  late _MockSubmitSession submitSession;

  setUpAll(() {
    registerFallbackValue(
      ReadingSession(
        clientId: 'fallback',
        userBookId: 'fallback',
        inputMode: 'manual',
        startTime: DateTime(2026),
        endTime: DateTime(2026),
        activeDurationSeconds: 0,
        pauseIntervals: const [],
        startPage: 0,
        endPage: 1,
      ),
    );
  });

  setUp(() {
    submitSession = _MockSubmitSession();
    when(
      () => submitSession.call(
        any(),
        onSyncedWithBadges: any(named: 'onSyncedWithBadges'),
      ),
    ).thenAnswer((_) async => const Right(unit));
    getIt.registerFactory<ManualSessionCubit>(
      () => ManualSessionCubit(submitSession),
    );
  });

  tearDown(() async => getIt.reset());

  /// Pushed onto a route so the form's "leave on save" pop has somewhere to go.
  Future<void> openForm(WidgetTester tester) async {
    tester.view.physicalSize = const Size(700 * 2, 1600 * 2);
    tester.view.devicePixelRatio = 2;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      MaterialApp(
        // The app's own theme: the picker's surfaces come from it.
        theme: AppTheme.light,
        // Pinned to the app's primary locale so the assertions below can name
        // the strings it actually ships with.
        locale: const Locale('id'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Builder(
          builder: (context) => Scaffold(
            body: Center(
              child: ElevatedButton(
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => ManualSessionPage(userBook: _userBook()),
                  ),
                ),
                child: const Text('open'),
              ),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
  }

  Finder fieldWithLabel(String label) =>
      find.ancestor(of: find.text(label), matching: find.byType(TextFormField));

  testWidgets('defaults the date to today and prefills the start page', (
    tester,
  ) async {
    await openForm(tester);

    expect(find.text('Hari ini'), findsOneWidget);
    expect(find.text('50'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('the date picker is white, not the seeded warm surface', (
    tester,
  ) async {
    await openForm(tester);

    await tester.tap(find.text('Hari ini'));
    await tester.pumpAndSettle();

    expect(find.byType(DatePickerDialog), findsOneWidget);
    expect(
      tester.widget<Dialog>(find.byType(Dialog)).backgroundColor,
      AppColors.surface,
    );
  });

  testWidgets('an end page that is not past the start page never submits', (
    tester,
  ) async {
    await openForm(tester);

    await tester.enterText(fieldWithLabel('Durasi'), '30');
    await tester.enterText(fieldWithLabel('Halaman akhir'), '50');
    await tester.pump();

    await tester.tap(find.text('Simpan sesi'));
    await tester.pump();

    expect(
      find.text('Halaman akhir harus lebih besar dari halaman awal.'),
      findsOneWidget,
    );
    verifyNever(
      () => submitSession.call(
        any(),
        onSyncedWithBadges: any(named: 'onSyncedWithBadges'),
      ),
    );
  });

  testWidgets('a missing duration never submits', (tester) async {
    await openForm(tester);

    await tester.enterText(fieldWithLabel('Halaman akhir'), '80');
    await tester.pump();

    await tester.tap(find.text('Simpan sesi'));
    await tester.pump();

    expect(find.text('Isi berapa lama kamu membaca.'), findsOneWidget);
    verifyNever(
      () => submitSession.call(
        any(),
        onSyncedWithBadges: any(named: 'onSyncedWithBadges'),
      ),
    );
  });

  testWidgets('a filled form submits exactly what was entered', (tester) async {
    await openForm(tester);

    await tester.enterText(fieldWithLabel('Durasi'), '30');
    await tester.enterText(fieldWithLabel('Halaman akhir'), '80');
    await tester.pump();

    await tester.tap(find.text('Simpan sesi'));
    await tester.pumpAndSettle();

    final session =
        verify(
              () => submitSession.call(
                captureAny(),
                onSyncedWithBadges: any(named: 'onSyncedWithBadges'),
              ),
            ).captured.single
            as ReadingSession;

    expect(session.userBookId, 'ub-1');
    expect(session.inputMode, 'manual');
    expect(session.activeDurationSeconds, 30 * 60);
    expect(session.startPage, 50);
    expect(session.endPage, 80);

    // Saved: the form leaves and the confirmation shows.
    expect(find.byType(ManualSessionPage), findsNothing);
    expect(find.text('Sesi tersimpan'), findsOneWidget);
  });
}
