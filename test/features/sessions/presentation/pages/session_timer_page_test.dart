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
    title: 'Test Book',
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
    await tester.tap(find.byIcon(Icons.stop));
    await tester.pumpAndSettle();
    expect(cubit.isClosed, isFalse);
    await tester.enterText(find.byType(TextField).last, '20');
  }

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
