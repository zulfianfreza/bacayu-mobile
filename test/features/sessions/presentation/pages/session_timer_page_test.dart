import 'dart:async';

import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/core/di/injection.dart';
import 'package:mobile/core/error/failure.dart';
import 'package:mobile/features/books/domain/entities/book.dart';
import 'package:mobile/features/sessions/domain/entities/reading_session.dart';
import 'package:mobile/features/sessions/domain/usecases/submit_session.dart';
import 'package:mobile/features/sessions/presentation/cubit/session_timer_cubit.dart';
import 'package:mobile/features/sessions/presentation/cubit/session_timer_state.dart';
import 'package:mobile/features/sessions/presentation/pages/session_timer_page.dart';
import 'package:mobile/features/shelf/domain/entities/user_book.dart';
import 'package:mobile/l10n/app_localizations.dart';
import 'package:mocktail/mocktail.dart';

class _MockSubmitSession extends Mock implements SubmitSession {}

final _book = UserBook(
  id: 'ub-1',
  book: const Book(
    id: 'book-1',
    source: 'manual',
    googleBooksId: null,
    isbn10: null,
    isbn13: null,
    title:
        'Miralce Morning Mindset: The 5 AM Habit Hack for Radical Personal Transformation',
    authors: [],
    description: null,
    coverUrl: null,
    totalPages: 100,
    language: 'en',
    genres: [],
    publishedDate: '',
  ),
  status: ShelfStatus.reading,
  format: null,
  currentPage: 10,
  startedAt: null,
  finishedAt: null,
  rating: null,
  isReread: false,
  readCount: 1,
);

void main() {
  late _MockSubmitSession submit;
  late SessionTimerCubit cubit;

  setUpAll(() {
    registerFallbackValue(
      ReadingSession(
        clientId: 'fallback',
        userBookId: 'ub-1',
        inputMode: 'timer',
        startTime: DateTime(2026),
        endTime: DateTime(2026),
        activeDurationSeconds: 60,
        pauseIntervals: const [],
        startPage: 10,
        endPage: 20,
      ),
    );
  });

  setUp(() {
    submit = _MockSubmitSession();
    cubit = SessionTimerCubit(submit);
    getIt.registerFactory<SessionTimerCubit>(() => cubit);
  });

  tearDown(() async {
    if (!cubit.isClosed) await cubit.close();
    await getIt.reset();
  });

  Future<void> openSummary(WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        locale: const Locale('en'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: SessionTimerPage(initialUserBook: _book),
      ),
    );
    await tester.pump();
    await tester.ensureVisible(find.byIcon(Icons.stop));
    await tester.tap(find.byIcon(Icons.stop));
    await tester.pumpAndSettle();
    expect(cubit.isClosed, isFalse);
    await tester.enterText(find.byType(TextField).last, '20');
  }

  testWidgets(
    'long title fits small screen without scrolling and stop is icon only',
    (tester) async {
      tester.view.physicalSize = const Size(320, 568);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      await tester.pumpWidget(
        MaterialApp(
          locale: const Locale('en'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: SessionTimerPage(initialUserBook: _book),
        ),
      );
      await tester.pump();
      expect(find.byType(Scrollable), findsNothing);
      expect(find.text('Stop and review'), findsNothing);
      expect(find.byTooltip('Stop and review'), findsOneWidget);
      expect(tester.getRect(find.byIcon(Icons.stop)).bottom, lessThan(568));
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox());
    },
  );

  testWidgets(
    'pause, resume and cancel confirmation work with reduced motion',
    (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          locale: const Locale('en'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          builder: (context, child) => MediaQuery(
            data: MediaQuery.of(context).copyWith(disableAnimations: true),
            child: child!,
          ),
          home: SessionTimerPage(initialUserBook: _book),
        ),
      );
      await tester.pumpAndSettle();
      await tester.ensureVisible(find.byIcon(Icons.pause));
      final pause = tester.getCenter(find.byIcon(Icons.pause));
      final stop = tester.getCenter(find.byIcon(Icons.stop));
      expect(stop.dx, greaterThan(pause.dx));
      expect(stop.dy, closeTo(pause.dy, 1));
      await tester.tap(find.byIcon(Icons.pause));
      await tester.pumpAndSettle();
      expect(find.text('Paused'), findsOneWidget);
      expect(cubit.state, isA<SessionTimerPaused>());
      await tester.tap(find.byIcon(Icons.play_arrow));
      await tester.pumpAndSettle();
      expect(cubit.state, isA<SessionTimerRunning>());
      expect(find.byIcon(Icons.music_note_rounded), findsNothing);
      await tester.ensureVisible(find.byIcon(Icons.close));
      await tester.tap(find.byIcon(Icons.close));
      await tester.pumpAndSettle();
      expect(find.text('Cancel session?'), findsWidgets);
      expect(find.byType(BottomSheet), findsOneWidget);
      expect(cubit.state, isA<SessionTimerRunning>());
      await tester.tap(find.text('Keep session'));
      await tester.pumpAndSettle();
      expect(find.byType(BottomSheet), findsNothing);
      expect(cubit.state, isA<SessionTimerRunning>());
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox());
    },
  );

  testWidgets('stop keeps cubit alive until summary saves and leaves', (
    tester,
  ) async {
    ReadingSession? saved;
    when(() => submit.call(any(), onSynced: any(named: 'onSynced'))).thenAnswer(
      (invocation) async {
        saved = invocation.positionalArguments.first as ReadingSession;
        return const Right(unit);
      },
    );

    await openSummary(tester);
    await tester.tap(find.widgetWithText(ElevatedButton, 'Save session'));
    await tester.pumpAndSettle();

    expect(cubit.state, isA<SessionTimerSubmitted>());
    expect(saved?.userBookId, 'ub-1');
    expect(saved?.startPage, 10);
    expect(saved?.endPage, 20);
    expect(tester.takeException(), isNull);

    await tester.pumpWidget(const SizedBox());
    await tester.pumpAndSettle();
    expect(cubit.isClosed, isTrue);
  });

  testWidgets('leaving during save allows persistence to finish without emit', (
    tester,
  ) async {
    final pending = Completer<Either<Failure, Unit>>();
    when(
      () => submit.call(any(), onSynced: any(named: 'onSynced')),
    ).thenAnswer((_) => pending.future);

    await openSummary(tester);
    await tester.tap(find.widgetWithText(ElevatedButton, 'Save session'));
    await tester.pump();
    expect(cubit.state, isA<SessionTimerSubmitting>());

    await tester.pumpWidget(const SizedBox());
    expect(cubit.isClosed, isTrue);
    pending.complete(const Right(unit));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  });
}
