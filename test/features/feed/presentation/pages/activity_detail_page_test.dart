import 'dart:async';

import 'package:dartz/dartz.dart' hide State;
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/core/di/injection.dart';
import 'package:mobile/core/error/failure.dart';
import 'package:mobile/features/auth/domain/entities/user.dart';
import 'package:mobile/features/auth/domain/usecases/get_current_user.dart';
import 'package:mobile/features/books/domain/entities/book.dart';
import 'package:mobile/features/books/domain/usecases/get_book_detail.dart';
import 'package:mobile/features/books/presentation/pages/book_detail_page.dart';
import 'package:mobile/features/feed/domain/entities/activity.dart';
import 'package:mobile/features/feed/presentation/pages/activity_detail_page.dart';
import 'package:mobile/features/social/domain/entities/activity_comment.dart';
import 'package:mobile/features/social/domain/usecases/add_comment.dart';
import 'package:mobile/features/social/domain/usecases/list_comments.dart';
import 'package:mobile/l10n/app_localizations.dart';
import 'package:mocktail/mocktail.dart';

class _MockListComments extends Mock implements ListComments {}

class _MockAddComment extends Mock implements AddComment {}

class _MockGetCurrentUser extends Mock implements GetCurrentUser {}

class _MockGetBookDetail extends Mock implements GetBookDetail {}

final _sessionActivity = Activity(
  id: 'act-1',
  author: const ActivityAuthor(id: 'u1', name: 'Julian', avatarUrl: null),
  occurredAt: DateTime(2026, 1, 1),
  payload: const SessionActivityPayload(
    bookId: 'book-1',
    bookTitle: 'Atomic Habits',
    bookCoverUrl: null,
    pagesRead: 20,
    speedPpm: 1.2,
    activeDurationSeconds: 600,
  ),
  likeCount: 2,
  commentCount: 0,
  isLiked: false,
);

void main() {
  setUp(() {
    final listComments = _MockListComments();
    final addComment = _MockAddComment();
    final getCurrentUser = _MockGetCurrentUser();
    final getBookDetail = _MockGetBookDetail();
    // Never-resolving futures — these tests only assert on navigation, not
    // on the fetched comments/user/book content.
    when(() => listComments.call(any())).thenAnswer(
      (_) => Completer<Either<Failure, List<ActivityComment>>>().future,
    );
    when(
      () => getCurrentUser.call(),
    ).thenAnswer((_) => Completer<Either<Failure, User>>().future);
    when(
      () => getBookDetail.call(any()),
    ).thenAnswer((_) => Completer<Either<Failure, Book>>().future);

    getIt
      ..registerFactory<ListComments>(() => listComments)
      ..registerFactory<AddComment>(() => addComment)
      ..registerFactory<GetCurrentUser>(() => getCurrentUser)
      ..registerFactory<GetBookDetail>(() => getBookDetail);
  });

  tearDown(() async => getIt.reset());

  Widget wrap(Widget child) {
    return MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: child,
    );
  }

  testWidgets(
    'tapping the book cover/title navigates to BookDetailPage with the '
    "activity's book id",
    (tester) async {
      await tester.pumpWidget(
        wrap(
          ActivityDetailPage(
            activityId: _sessionActivity.id,
            activity: _sessionActivity,
          ),
        ),
      );
      await tester.pump();

      await tester.tap(find.text('Atomic Habits'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.byType(BookDetailPage), findsOneWidget);
      final page = tester.widget<BookDetailPage>(find.byType(BookDetailPage));
      expect(page.bookId, 'book-1');
    },
  );

  testWidgets(
    'renders the activity-not-available fallback when reached without an Activity',
    (tester) async {
      await tester.pumpWidget(
        wrap(const ActivityDetailPage(activityId: 'act-1', activity: null)),
      );
      await tester.pump();

      expect(find.byType(BookDetailPage), findsNothing);
      expect(find.text("This activity isn't available."), findsOneWidget);
    },
  );
}
