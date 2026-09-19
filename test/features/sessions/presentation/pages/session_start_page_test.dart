import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/core/di/injection.dart';
import 'package:mobile/features/books/domain/entities/book.dart';
import 'package:mobile/features/sessions/domain/entities/reading_session.dart';
import 'package:mobile/features/sessions/domain/usecases/submit_session.dart';
import 'package:mobile/features/sessions/presentation/cubit/manual_session_cubit.dart';
import 'package:mobile/features/sessions/presentation/cubit/session_timer_cubit.dart';
import 'package:mobile/features/sessions/presentation/pages/manual_session_page.dart';
import 'package:mobile/features/sessions/presentation/pages/session_start_page.dart';
import 'package:mobile/features/sessions/presentation/pages/session_timer_page.dart';
import 'package:mobile/features/shelf/domain/entities/user_book.dart';
import 'package:mobile/l10n/app_localizations.dart';
import 'package:mocktail/mocktail.dart';

class _MockSubmitSession extends Mock implements SubmitSession {}

UserBook _userBook() => UserBook(
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
  currentPage: 50,
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

    getIt
      ..registerFactory<ManualSessionCubit>(
        () => ManualSessionCubit(submitSession),
      )
      ..registerFactory<SessionTimerCubit>(
        () => SessionTimerCubit(submitSession),
      );
  });

  tearDown(() async => getIt.reset());

  Future<void> pumpChoice(WidgetTester tester) async {
    tester.view.physicalSize = const Size(700 * 2, 1400 * 2);
    tester.view.devicePixelRatio = 2;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      MaterialApp(
        // Pinned to the app's primary locale so the assertions below can name
        // the strings it actually ships with.
        locale: const Locale('id'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: SessionStartPage(userBook: _userBook()),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('offers both ways to log the book it was opened for', (
    tester,
  ) async {
    await pumpChoice(tester);

    expect(find.text('Atomic Habits'), findsOneWidget);
    expect(find.text('Mau dicatat bagaimana?'), findsOneWidget);
    expect(find.text('Mulai timer'), findsOneWidget);
    expect(find.text('Tambah manual'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('the timer option opens the live timer', (tester) async {
    await pumpChoice(tester);

    await tester.tap(find.text('Mulai timer'));
    // Not pumpAndSettle: a running timer ticks forever.
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.byType(SessionTimerPage), findsOneWidget);
    expect(find.byType(ManualSessionPage), findsNothing);

    // Unmount so the cubit's ticker is disposed before the test ends.
    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('the manual option opens the manual form', (tester) async {
    await pumpChoice(tester);

    await tester.tap(find.text('Tambah manual'));
    await tester.pumpAndSettle();

    expect(find.byType(ManualSessionPage), findsOneWidget);
    expect(find.byType(SessionTimerPage), findsNothing);
  });
}
