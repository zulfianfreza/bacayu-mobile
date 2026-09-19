import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/core/di/injection.dart';
import 'package:mobile/features/auth/domain/entities/user.dart';
import 'package:mobile/features/auth/domain/repositories/auth_repository.dart';
import 'package:mobile/features/auth/domain/usecases/get_current_user.dart';
import 'package:mobile/features/feed/domain/entities/activity.dart';
import 'package:mobile/features/feed/domain/entities/activity_page.dart';
import 'package:mobile/features/feed/domain/repositories/feed_repository.dart';
import 'package:mobile/features/feed/domain/usecases/get_social_feed.dart';
import 'package:mobile/features/feed/presentation/cubit/feed_cubit.dart';
import 'package:mobile/features/feed/presentation/widgets/activity_author_header.dart';
import 'package:mobile/features/home/presentation/cubit/home_cubit.dart';
import 'package:mobile/features/home/presentation/pages/home_page.dart';
import 'package:mobile/features/shelf/domain/entities/user_book.dart';
import 'package:mobile/features/shelf/domain/repositories/shelf_repository.dart';
import 'package:mobile/features/shelf/domain/usecases/list_shelf.dart';
import 'package:mobile/features/social/domain/repositories/social_repository.dart';
import 'package:mobile/features/social/domain/usecases/follow_user.dart';
import 'package:mobile/features/social/domain/usecases/search_users.dart';
import 'package:mobile/features/social/domain/usecases/unfollow_user.dart';
import 'package:mobile/features/social/presentation/cubit/user_search_bloc.dart';
import 'package:mobile/features/social/presentation/pages/user_search_page.dart';
import 'package:mobile/features/stats/domain/entities/daily_stat.dart';
import 'package:mobile/features/stats/domain/repositories/stats_repository.dart';
import 'package:mobile/features/stats/domain/usecases/get_heatmap.dart';
import 'package:mobile/l10n/app_localizations.dart';
import 'package:mocktail/mocktail.dart';

class _MockAuthRepository extends Mock implements AuthRepository {}

class _MockStatsRepository extends Mock implements StatsRepository {}

class _MockShelfRepository extends Mock implements ShelfRepository {}

class _MockFeedRepository extends Mock implements FeedRepository {}

class _MockSocialRepository extends Mock implements SocialRepository {}

/// The signed-in user. Deliberately *not* the author of the activities below —
/// the whole point is that Home shows each poster's own name now.
User _viewer() => User(
  id: 'viewer',
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
  author: const ActivityAuthor(id: 'friend-1', name: 'Maya', avatarUrl: null),
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
  author: const ActivityAuthor(id: 'friend-2', name: 'Budi', avatarUrl: null),
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
  late _MockSocialRepository socialRepository;

  setUpAll(() {
    registerFallbackValue(ShelfStatus.reading);
  });

  setUp(() {
    authRepository = _MockAuthRepository();
    statsRepository = _MockStatsRepository();
    shelfRepository = _MockShelfRepository();
    feedRepository = _MockFeedRepository();
    socialRepository = _MockSocialRepository();

    when(
      () => authRepository.getCurrentUser(),
    ).thenAnswer((_) async => Right(_viewer()));
    when(
      () => statsRepository.getHeatmap(any()),
    ).thenAnswer((_) async => const Right(<DailyStat>[]));
    when(
      () => shelfRepository.listShelf(
        status: any(named: 'status'),
        page: any(named: 'page'),
      ),
    ).thenAnswer((_) async => const Right(<UserBook>[]));

    getIt.registerFactory<HomeCubit>(
      () => HomeCubit(
        GetCurrentUser(authRepository),
        GetHeatmap(statsRepository),
        ListShelf(shelfRepository),
      ),
    );
    getIt.registerFactory<FeedCubit>(
      () => FeedCubit(
        GetSocialFeed(feedRepository),
        GetCurrentUser(authRepository),
      ),
    );
    getIt.registerFactory<UserSearchBloc>(
      () => UserSearchBloc(
        SearchUsers(socialRepository),
        FollowUser(socialRepository),
        UnfollowUser(socialRepository),
      ),
    );
  });

  tearDown(() async => getIt.reset());

  void stubFeed(List<Activity> activities) {
    when(
      () => feedRepository.getSocialFeed(cursor: any(named: 'cursor')),
    ).thenAnswer(
      (_) async => Right(ActivityPage(items: activities, nextCursor: null)),
    );
  }

  Future<void> pumpHome(WidgetTester tester) async {
    // Wider than a phone on purpose: the test font is far wider than Nunito,
    // and at 390 the page's own sections would be the thing overflowing,
    // drowning out anything this test is about.
    tester.view.physicalSize = const Size(700 * 2, 1400 * 2);
    tester.view.devicePixelRatio = 2;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      MaterialApp(
        locale: const Locale('id'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: const HomePage(),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('every activity is introduced by its own author', (tester) async {
    stubFeed([_sessionActivity(), _badgeActivity()]);

    await pumpHome(tester);

    // One header per activity, each naming the poster from the feed.
    expect(find.byType(ActivityAuthorHeader), findsNWidgets(2));
    expect(find.text('Maya'), findsOneWidget);
    expect(find.text('Budi'), findsOneWidget);
    // Never the signed-in user, whose name only appears in the greeting.
    expect(find.text('Julian'), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('the feed has no "see all" link — it pages itself', (
    tester,
  ) async {
    stubFeed([_sessionActivity()]);

    await pumpHome(tester);

    expect(find.text('Lihat semua'), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('an empty feed offers the find-friends call to action', (
    tester,
  ) async {
    stubFeed(const []);

    await pumpHome(tester);

    expect(find.text('Cari teman baca'), findsOneWidget);
    expect(find.text('Cari teman'), findsOneWidget);
    expect(find.byType(ActivityAuthorHeader), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('the header opens user search', (tester) async {
    stubFeed(const []);
    await pumpHome(tester);

    // The search glyph, distinct from the other assets Home loads.
    final searchGlyph = find.byWidgetPredicate(
      (widget) =>
          widget is Image &&
          widget.image is AssetImage &&
          (widget.image as AssetImage).assetName ==
              'assets/icons/search-stroke.png',
    );
    expect(searchGlyph, findsOneWidget);

    await tester.tap(searchGlyph);
    await tester.pumpAndSettle();

    expect(find.byType(UserSearchPage), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
