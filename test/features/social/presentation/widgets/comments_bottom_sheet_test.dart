import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/core/di/injection.dart';
import 'package:mobile/core/theme/app_colors.dart';
import 'package:mobile/core/theme/app_theme.dart';
import 'package:mobile/features/auth/domain/entities/user.dart';
import 'package:mobile/features/auth/domain/usecases/get_current_user.dart';
import 'package:mobile/features/social/domain/entities/activity_comment.dart';
import 'package:mobile/features/social/domain/usecases/add_comment.dart';
import 'package:mobile/features/social/domain/usecases/list_comments.dart';
import 'package:mobile/features/social/presentation/widgets/comment_tile.dart';
import 'package:mobile/features/social/presentation/widgets/comments_bottom_sheet.dart';
import 'package:mobile/l10n/app_localizations.dart';
import 'package:mocktail/mocktail.dart';

class _MockListComments extends Mock implements ListComments {}

class _MockAddComment extends Mock implements AddComment {}

class _MockGetCurrentUser extends Mock implements GetCurrentUser {}

ActivityComment _comment() => ActivityComment(
  id: 'c1',
  userId: 'u2',
  userName: 'Maya',
  userAvatarUrl: null,
  body: 'Semangat!',
  createdAt: DateTime(2026, 1, 1),
);

User _user() => User(
  id: 'u1',
  email: 'reader@bacayu.app',
  name: 'Julian',
  avatarUrl: '',
  timezone: 'UTC',
  favoriteGenres: const [],
  yearlyGoalBooks: null,
  dailyGoalMinutes: null,
  currentStreak: 0,
  longestStreak: 0,
  lastReadDate: null,
  privacyDefault: 'private',
  onboardingCompletedAt: DateTime(2026, 1, 1),
  createdAt: DateTime(2026, 1, 1),
  updatedAt: DateTime(2026, 1, 1),
);

void main() {
  late _MockListComments listComments;

  setUp(() {
    listComments = _MockListComments();
    final addComment = _MockAddComment();
    final getCurrentUser = _MockGetCurrentUser();
    when(() => getCurrentUser.call()).thenAnswer((_) async => Right(_user()));
    when(
      () => addComment.call(
        activityId: any(named: 'activityId'),
        body: any(named: 'body'),
      ),
    ).thenAnswer((_) async => Right(_comment()));

    getIt
      ..registerFactory<ListComments>(() => listComments)
      ..registerFactory<AddComment>(() => addComment)
      ..registerFactory<GetCurrentUser>(() => getCurrentUser);
  });

  tearDown(() async => getIt.reset());

  /// Opens the sheet the way the activity card footer does — note that it does
  /// NOT pass a background colour, which is exactly the case that used to come
  /// out warm from the theme's seeded default.
  Future<void> openSheet(
    WidgetTester tester,
    List<ActivityComment> comments,
  ) async {
    when(() => listComments.call(any())).thenAnswer((_) async => Right(comments));

    await tester.pumpWidget(
      MaterialApp(
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
                onPressed: () =>
                    CommentsBottomSheet.show(context, activityId: 'act-1'),
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

  testWidgets('the sheet is white, not the seeded warm surface', (tester) async {
    await openSheet(tester, const []);

    final sheet = tester.widget<BottomSheet>(find.byType(BottomSheet));
    expect(sheet.backgroundColor, AppColors.surface);
  });

  testWidgets('opens with its own heading and an empty state', (tester) async {
    await openSheet(tester, const []);

    expect(find.text('Komentar'), findsOneWidget);
    expect(find.byType(CommentsEmpty), findsOneWidget);
    expect(find.text('Belum ada komentar'), findsOneWidget);
    expect(find.byType(CommentTile), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('each comment renders as its own card', (tester) async {
    await openSheet(tester, [_comment()]);

    expect(find.byType(CommentTile), findsOneWidget);
    expect(find.text('Maya'), findsOneWidget);
    expect(find.text('Semangat!'), findsOneWidget);
    expect(find.byType(CommentsEmpty), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('opens on the root navigator, not the nested one', (
    tester,
  ) async {
    final rootNavigator = GlobalKey<NavigatorState>();
    when(
      () => listComments.call(any()),
    ).thenAnswer((_) async => const Right(<ActivityComment>[]));

    await tester.pumpWidget(
      MaterialApp(
        navigatorKey: rootNavigator,
        theme: AppTheme.light,
        locale: const Locale('id'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        // Stands in for the shell's per-branch Navigator, which lives inside
        // the shell body: a route pushed on it cannot cover the bottom bar.
        home: Navigator(
          onGenerateRoute: (_) => MaterialPageRoute<void>(
            builder: (context) => Scaffold(
              body: Center(
                child: ElevatedButton(
                  onPressed: () =>
                      CommentsBottomSheet.show(context, activityId: 'act-1'),
                  child: const Text('open'),
                ),
              ),
              bottomNavigationBar: const SizedBox.shrink(),
            ),
          ),
        ),
      ),
    );

    expect(rootNavigator.currentState!.canPop(), isFalse);

    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();

    expect(find.byType(CommentsBottomSheet), findsOneWidget);
    // The sheet route landed on the root navigator, above the shell chrome.
    expect(rootNavigator.currentState!.canPop(), isTrue);
  });
}
