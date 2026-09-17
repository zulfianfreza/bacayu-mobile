import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/core/di/injection.dart';
import 'package:mobile/features/auth/domain/entities/user.dart';
import 'package:mobile/features/auth/domain/repositories/auth_repository.dart';
import 'package:mobile/features/auth/domain/usecases/get_current_user.dart';
import 'package:mobile/features/feed/domain/entities/activity.dart';
import 'package:mobile/features/feed/domain/repositories/feed_repository.dart';
import 'package:mobile/features/feed/domain/usecases/get_feed.dart';
import 'package:mobile/features/feed/presentation/widgets/activity_author_header.dart';
import 'package:mobile/features/home/presentation/cubit/home_cubit.dart';
import 'package:mobile/features/home/presentation/pages/home_page.dart';
import 'package:mobile/features/shelf/domain/entities/user_book.dart';
import 'package:mobile/features/shelf/domain/repositories/shelf_repository.dart';
import 'package:mobile/features/shelf/domain/usecases/list_shelf.dart';
import 'package:mobile/features/stats/domain/entities/daily_stat.dart';
import 'package:mobile/features/stats/domain/repositories/stats_repository.dart';
import 'package:mobile/features/stats/domain/usecases/get_heatmap.dart';
import 'package:mobile/l10n/app_localizations.dart';
import 'package:mocktail/mocktail.dart';

class _MockAuthRepository extends Mock implements AuthRepository {}

class _MockStatsRepository extends Mock implements StatsRepository {}

class _MockShelfRepository extends Mock implements ShelfRepository {}

class _MockFeedRepository extends Mock implements FeedRepository {}

User _user() => User(
      id: 'u1',
      email: 'reader@bacayu.app',
      name: 'Julian',
      avatarUrl: '',
      timezone: 'UTC',
      favoriteGenres: const [],
      yearlyGoalBooks: null,
      dailyGoalMinutes: null,
      currentStreak: 3,
      longestStreak: 5,
      lastReadDate: null,
      privacyDefault: 'private',
      onboardingCompletedAt: DateTime(2026, 1, 1),
      createdAt: DateTime(2026, 1, 1),
      updatedAt: DateTime(2026, 1, 1),
    );

Activity _sessionActivity() => Activity(
      id: 'a1',
      occurredAt: DateTime(2026, 1, 1),
      payload: const SessionActivityPayload(
        bookId: 'book-1',
        bookTitle: 'Atomic Habits',
        bookCoverUrl: null,
        pagesRead: 20,
        speedPpm: 1.2,
        activeDurationSeconds: 600,
      ),
      likeCount: 0,
      commentCount: 0,
      isLiked: false,
    );

Activity _badgeActivity() => Activity(
      id: 'a2',
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

void main() {
  late _MockAuthRepository authRepository;
  late _MockStatsRepository statsRepository;
  late _MockShelfRepository shelfRepository;
  late _MockFeedRepository feedRepository;

  setUpAll(() {
    registerFallbackValue(ShelfStatus.reading);
  });

  setUp(() {
    authRepository = _MockAuthRepository();
    statsRepository = _MockStatsRepository();
    shelfRepository = _MockShelfRepository();
    feedRepository = _MockFeedRepository();

    when(() => authRepository.getCurrentUser())
        .thenAnswer((_) async => Right(_user()));
    when(() => statsRepository.getHeatmap(any()))
        .thenAnswer((_) async => const Right(<DailyStat>[]));
    when(() => shelfRepository.listShelf(
          status: any(named: 'status'),
          page: any(named: 'page'),
        )).thenAnswer((_) async => const Right(<UserBook>[]));
    when(() => feedRepository.getFeed(cursor: any(named: 'cursor')))
        .thenAnswer((_) async => Right([_sessionActivity(), _badgeActivity()]));

    getIt.registerFactory<HomeCubit>(
      () => HomeCubit(
        GetCurrentUser(authRepository),
        GetHeatmap(statsRepository),
        ListShelf(shelfRepository),
        GetFeed(feedRepository),
      ),
    );
  });

  tearDown(() async => getIt.reset());

  Future<void> pumpHome(WidgetTester tester) async {
    // Wider than a phone on purpose: the test font is far wider than Nunito,
    // and at 390 the page's own "section title + view all" row would be the
    // thing overflowing, drowning out anything this test is about.
    tester.view.physicalSize = const Size(700 * 2, 1000 * 2);
    tester.view.devicePixelRatio = 2;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: const HomePage(),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('every recent activity is introduced by the user profile',
      (tester) async {
    await pumpHome(tester);

    // One header per activity — a reading session and a badge unlock.
    expect(find.byType(ActivityAuthorHeader), findsNWidgets(2));
    expect(find.text('Julian'), findsNWidgets(2));
    expect(tester.takeException(), isNull);
  });
}
