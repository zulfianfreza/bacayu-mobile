import 'dart:async';

import 'package:dartz/dartz.dart' hide State;
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile/core/di/injection.dart';
import 'package:mobile/core/error/failure.dart';
import 'package:mobile/core/router/app_router.dart';
import 'package:mobile/features/auth/domain/entities/user.dart';
import 'package:mobile/features/auth/domain/usecases/get_current_user.dart';
import 'package:mobile/features/feed/domain/entities/activity.dart';
import 'package:mobile/features/feed/presentation/widgets/badge_activity_card.dart';
import 'package:mobile/features/feed/presentation/widgets/session_activity_card.dart';
import 'package:mobile/features/social/domain/entities/activity_comment.dart';
import 'package:mobile/features/social/domain/usecases/add_comment.dart';
import 'package:mobile/features/social/domain/usecases/list_comments.dart';
import 'package:mobile/features/social/presentation/widgets/comments_bottom_sheet.dart';
import 'package:mobile/l10n/app_localizations.dart';
import 'package:mocktail/mocktail.dart';

class _MockListComments extends Mock implements ListComments {}

class _MockAddComment extends Mock implements AddComment {}

class _MockGetCurrentUser extends Mock implements GetCurrentUser {}

final _sessionActivity = Activity(
  id: 'act-1',
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
  commentCount: 3,
  isLiked: false,
);

final _badgeActivity = Activity(
  id: 'act-2',
  occurredAt: DateTime(2026, 1, 1),
  payload: const BadgeActivityPayload(
    badgeName: 'First Step',
    badgeIcon: '🎉',
    badgeDescription: 'Finish your first session',
  ),
  likeCount: 1,
  commentCount: 4,
  isLiked: false,
);

void main() {
  setUp(() {
    final listComments = _MockListComments();
    final addComment = _MockAddComment();
    final getCurrentUser = _MockGetCurrentUser();
    // These are only exercised if CommentsBottomSheet actually opens — a
    // Future that never resolves is enough since the tests only assert on
    // whether the sheet/route appeared, not on its fetched content.
    when(() => listComments.call(any())).thenAnswer(
        (_) => Completer<Either<Failure, List<ActivityComment>>>().future);
    when(() => getCurrentUser.call())
        .thenAnswer((_) => Completer<Either<Failure, User>>().future);

    getIt
      ..registerFactory<ListComments>(() => listComments)
      ..registerFactory<AddComment>(() => addComment)
      ..registerFactory<GetCurrentUser>(() => getCurrentUser);
  });

  tearDown(() async => getIt.reset());

  GoRouter testRouter(Widget home) {
    return GoRouter(
      initialLocation: '/home',
      routes: [
        GoRoute(
          path: '/home',
          builder: (context, state) => Scaffold(body: home),
        ),
        GoRoute(
          path: AppRoutes.feedActivityDetail,
          builder: (context, state) => Scaffold(
            body: Text('detail:${state.pathParameters['activityId']}'),
          ),
        ),
      ],
    );
  }

  Widget wrap(Widget home) {
    return MaterialApp.router(
      routerConfig: testRouter(home),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
    );
  }

  group('SessionActivityCard', () {
    testWidgets(
        'tapping the comment icon still opens CommentsBottomSheet, unchanged',
        (tester) async {
      await tester.pumpWidget(wrap(SessionActivityCard(activity: _sessionActivity)));
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.mode_comment_outlined));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.byType(CommentsBottomSheet), findsOneWidget);
      expect(find.text('detail:act-1'), findsNothing);
    });

    testWidgets(
        'tapping the cover/title area (not the comment icon) navigates to '
        'ActivityDetailPage', (tester) async {
      await tester.pumpWidget(wrap(SessionActivityCard(activity: _sessionActivity)));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Atomic Habits'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.text('detail:act-1'), findsOneWidget);
      expect(find.byType(CommentsBottomSheet), findsNothing);
    });
  });

  group('BadgeActivityCard', () {
    testWidgets(
        'tapping the comment icon still opens CommentsBottomSheet, unchanged',
        (tester) async {
      await tester.pumpWidget(wrap(BadgeActivityCard(activity: _badgeActivity)));
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.mode_comment_outlined));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.byType(CommentsBottomSheet), findsOneWidget);
      expect(find.text('detail:act-2'), findsNothing);
    });

    testWidgets(
        'tapping the medal/text area (not the comment icon) navigates to '
        'ActivityDetailPage', (tester) async {
      await tester.pumpWidget(wrap(BadgeActivityCard(activity: _badgeActivity)));
      await tester.pumpAndSettle();

      await tester.tap(find.text('First Step'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.text('detail:act-2'), findsOneWidget);
      expect(find.byType(CommentsBottomSheet), findsNothing);
    });
  });
}
