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
import 'package:mobile/features/feed/domain/entities/activity_detail.dart';
import 'package:mobile/features/feed/domain/usecases/get_activity_detail.dart';
import 'package:mobile/features/feed/presentation/pages/activity_detail_page.dart';
import 'package:mobile/features/feed/presentation/widgets/activity_author_header.dart';
import 'package:mobile/features/badges/presentation/widgets/badge_artwork.dart';
import 'package:mobile/features/social/domain/entities/activity_comment.dart';
import 'package:mobile/features/social/domain/usecases/add_comment.dart';
import 'package:mobile/features/social/domain/usecases/list_comments.dart';
import 'package:mobile/l10n/app_localizations.dart';
import 'package:mocktail/mocktail.dart';

class _MockListComments extends Mock implements ListComments {}

class _MockAddComment extends Mock implements AddComment {}

class _MockGetCurrentUser extends Mock implements GetCurrentUser {}

class _MockGetBookDetail extends Mock implements GetBookDetail {}

class _MockGetActivityDetail extends Mock implements GetActivityDetail {}

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

User _viewer(String id) => User(
  id: id,
  email: 'reader@bacayu.app',
  name: 'Julian',
  avatarUrl: '',
  timezone: 'UTC',
  favoriteGenres: const [],
  yearlyGoalBooks: null,
  dailyGoalMinutes: null,
  currentStreak: 2,
  longestStreak: 4,
  lastReadDate: null,
  privacyDefault: 'private',
  onboardingCompletedAt: DateTime(2026, 1, 1),
  createdAt: DateTime(2026, 1, 1),
  updatedAt: DateTime(2026, 1, 1),
);

void main() {
  late _MockGetCurrentUser getCurrentUser;
  late _MockGetActivityDetail getActivityDetail;

  setUp(() {
    final listComments = _MockListComments();
    final addComment = _MockAddComment();
    getCurrentUser = _MockGetCurrentUser();
    getActivityDetail = _MockGetActivityDetail();
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
    // The detail fetch is left hanging by default: every test below then
    // exercises the "card copy only" path, exactly as a slow network would.
    when(
      () => getActivityDetail.call(any()),
    ).thenAnswer((_) => Completer<Either<Failure, ActivityDetail>>().future);

    getIt
      ..registerFactory<ListComments>(() => listComments)
      ..registerFactory<AddComment>(() => addComment)
      ..registerFactory<GetCurrentUser>(() => getCurrentUser)
      ..registerFactory<GetBookDetail>(() => getBookDetail)
      ..registerFactory<GetActivityDetail>(() => getActivityDetail);
  });

  tearDown(() async => getIt.reset());

  /// Who the page decides is signed in — the share button turns on this
  /// comparing against the activity's author.
  void stubViewer(String id) {
    when(
      () => getCurrentUser.call(),
    ).thenAnswer((_) async => Right(_viewer(id)));
  }

  /// A detail that arrives straight away.
  void stubDetail(ActivityDetail detail) {
    when(
      () => getActivityDetail.call(any()),
    ).thenAnswer((_) async => Right(detail));
  }

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
    'renders the activity-not-available fallback when there is nothing to show',
    (tester) async {
      // Nothing came with the tap, and the fetch came back empty-handed —
      // which is also what a not-visible activity looks like.
      when(
        () => getActivityDetail.call(any()),
      ).thenAnswer((_) async => const Left(CacheFailure()));

      await tester.pumpWidget(
        wrap(const ActivityDetailPage(activityId: 'act-1', activity: null)),
      );
      await tester.pump();
      await tester.pump();

      expect(find.byType(BookDetailPage), findsNothing);
      expect(find.text("This activity isn't available."), findsOneWidget);
    },
  );

  testWidgets('the card copy renders before the detail has arrived', (
    tester,
  ) async {
    await tester.pumpWidget(
      wrap(
        ActivityDetailPage(
          activityId: _sessionActivity.id,
          activity: _sessionActivity,
        ),
      ),
    );
    await tester.pump();

    // No spinner standing in for the page: the activity the card already had
    // is on screen from the first frame.
    expect(find.text('Atomic Habits'), findsOneWidget);
    expect(find.byType(ActivityAuthorHeader), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('a session shows its pauses and the badges it unlocked', (
    tester,
  ) async {
    stubDetail(
      ActivityDetail(
        activity: _sessionActivity,
        visibility: 'public',
        session: SessionDetail(
          pauseCount: 2,
          pauses: [
            SessionPause(
              pausedAt: DateTime(2026, 1, 1, 13, 30),
              resumedAt: DateTime(2026, 1, 1, 13, 35),
            ),
            SessionPause(
              pausedAt: DateTime(2026, 1, 1, 14, 10),
              resumedAt: DateTime(2026, 1, 1, 14, 13),
            ),
          ],
          badges: const [
            SessionBadge(
              badgeId: 'b-1',
              name: 'Bookworm',
              description: 'Finish 10 books',
              imageUrl: null,
            ),
          ],
        ),
      ),
    );

    // Tall enough that the whole page lays out in one viewport: a detail page
    // is longer than the default test window, and `ListView` only builds what
    // fits (plus its cache).
    tester.view.physicalSize = const Size(800 * 2, 2200 * 2);
    tester.view.devicePixelRatio = 2;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      wrap(
        ActivityDetailPage(
          activityId: _sessionActivity.id,
          activity: _sessionActivity,
        ),
      ),
    );
    await tester.pump();
    await tester.pump();

    // The summary, then each interval with the clock times it spanned.
    expect(find.text('2 pauses'), findsOneWidget);
    expect(find.text('total 08:00'), findsOneWidget);
    expect(find.textContaining('13:30'), findsOneWidget);
    expect(find.text('05:00'), findsOneWidget);

    // And the badges the session earned.
    expect(find.text('Badges from this session'), findsOneWidget);
    expect(find.text('Bookworm'), findsOneWidget);
    expect(find.text('Finish 10 books'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('a badge unlock wears the artwork the detail carries', (
    tester,
  ) async {
    final badgeActivity = Activity(
      id: 'act-2',
      author: const ActivityAuthor(id: 'u1', name: 'Julian', avatarUrl: null),
      occurredAt: DateTime(2026, 1, 1),
      payload: const BadgeActivityPayload(
        badgeName: 'First Step',
        badgeIcon: '🎉',
        badgeDescription: 'Finish your first session',
      ),
      likeCount: 0,
      commentCount: 0,
      isLiked: false,
    );

    stubDetail(
      ActivityDetail(
        activity: badgeActivity,
        visibility: 'public',
        badge: const SessionBadge(
          badgeId: 'b-1',
          name: 'First Step',
          description: 'Finish your first session',
          imageUrl: 'https://cdn.example.com/first.png',
        ),
      ),
    );

    await tester.pumpWidget(
      wrap(
        ActivityDetailPage(
          activityId: badgeActivity.id,
          activity: badgeActivity,
        ),
      ),
    );
    await tester.pump();
    await tester.pump();

    expect(
      tester.widget<BadgeArtwork>(find.byType(BadgeArtwork)).imageUrl,
      'https://cdn.example.com/first.png',
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('a failed detail fetch still shows the card copy', (
    tester,
  ) async {
    when(
      () => getActivityDetail.call(any()),
    ).thenAnswer((_) async => const Left(CacheFailure()));

    await tester.pumpWidget(
      wrap(
        ActivityDetailPage(
          activityId: _sessionActivity.id,
          activity: _sessionActivity,
        ),
      ),
    );
    await tester.pump();
    await tester.pump();

    expect(find.text('Atomic Habits'), findsOneWidget);
    expect(find.text("This activity isn't available."), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('introduces the poster the feed named', (tester) async {
    await tester.pumpWidget(
      wrap(
        ActivityDetailPage(
          activityId: _sessionActivity.id,
          activity: _sessionActivity,
        ),
      ),
    );
    await tester.pump();

    expect(find.byType(ActivityAuthorHeader), findsOneWidget);
    expect(find.text('Julian'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('a badge unlock has nothing to share', (tester) async {
    final badgeActivity = Activity(
      id: 'act-2',
      author: const ActivityAuthor(id: 'u1', name: 'Julian', avatarUrl: null),
      occurredAt: DateTime(2026, 1, 1),
      payload: const BadgeActivityPayload(
        badgeName: 'First Step',
        badgeIcon: '🎉',
        badgeDescription: 'Finish your first session',
      ),
      likeCount: 0,
      commentCount: 0,
      isLiked: false,
    );

    await tester.pumpWidget(
      wrap(
        ActivityDetailPage(
          activityId: badgeActivity.id,
          activity: badgeActivity,
        ),
      ),
    );
    await tester.pump();

    expect(find.text('First Step'), findsOneWidget);
    // Only reading sessions render as a shareable card.
    expect(find.text('Share'), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('your own session offers the share card', (tester) async {
    // The activity is authored by u1, and so is the viewer.
    stubViewer('u1');

    await tester.pumpWidget(
      wrap(
        ActivityDetailPage(
          activityId: _sessionActivity.id,
          activity: _sessionActivity,
        ),
      ),
    );
    await tester.pump();
    await tester.pump();

    expect(find.text('Share'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets("someone else's session is not yours to share", (tester) async {
    stubViewer('u2');

    await tester.pumpWidget(
      wrap(
        ActivityDetailPage(
          activityId: _sessionActivity.id,
          activity: _sessionActivity,
        ),
      ),
    );
    await tester.pump();
    await tester.pump();

    expect(find.text('Atomic Habits'), findsOneWidget);
    expect(find.text('Share'), findsNothing);
    expect(tester.takeException(), isNull);
  });
}
