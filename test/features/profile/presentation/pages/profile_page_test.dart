import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart' hide Badge;
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/core/di/injection.dart';
import 'package:mobile/features/auth/domain/entities/user.dart';
import 'package:mobile/features/auth/domain/repositories/auth_repository.dart';
import 'package:mobile/features/auth/domain/usecases/get_current_user.dart';
import 'package:mobile/features/badges/domain/entities/badge.dart';
import 'package:mobile/features/badges/domain/repositories/badge_repository.dart';
import 'package:mobile/features/badges/domain/usecases/get_all_badges.dart';
import 'package:mobile/features/feed/domain/entities/activity.dart';
import 'package:mobile/features/feed/domain/entities/activity_page.dart';
import 'package:mobile/features/feed/domain/repositories/feed_repository.dart';
import 'package:mobile/features/feed/domain/usecases/get_feed.dart';
import 'package:mobile/features/feed/presentation/cubit/feed_cubit.dart';
import 'package:mobile/features/feed/presentation/widgets/session_activity_card.dart';
import 'package:mobile/features/profile/presentation/cubit/profile_cubit.dart';
import 'package:mobile/features/profile/presentation/pages/profile_page.dart';
import 'package:mobile/features/social/domain/repositories/social_repository.dart';
import 'package:mobile/features/social/domain/usecases/get_follow_counts.dart';
import 'package:mobile/features/stats/domain/entities/stats_summary.dart';
import 'package:mobile/features/stats/domain/repositories/stats_repository.dart';
import 'package:mobile/features/stats/domain/usecases/get_stats_summary.dart';
import 'package:mobile/l10n/app_localizations.dart';
import 'package:mocktail/mocktail.dart';

class _MockAuthRepository extends Mock implements AuthRepository {}

class _MockStatsRepository extends Mock implements StatsRepository {}

class _MockBadgeRepository extends Mock implements BadgeRepository {}

class _MockSocialRepository extends Mock implements SocialRepository {}

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

Badge _badge(String id, {required bool unlocked}) => Badge(
      id: id,
      name: 'Badge $id',
      icon: '🏅',
      description: 'A badge',
      imageUrl: null,
      unlocked: unlocked,
      unlockedAt: unlocked ? DateTime(2026, 1, 1) : null,
    );

Activity _activity(String bookTitle) => Activity(
      id: 'act-1',
      author: const ActivityAuthor(id: 'u1', name: 'Julian', avatarUrl: null),
      occurredAt: DateTime(2026, 1, 1),
      payload: SessionActivityPayload(
        bookId: 'book-1',
        bookTitle: bookTitle,
        bookCoverUrl: null,
        pagesRead: 20,
        speedPpm: 1.2,
        activeDurationSeconds: 600,
      ),
      likeCount: 2,
      commentCount: 3,
      isLiked: false,
    );

void main() {
  late _MockAuthRepository authRepository;
  late _MockStatsRepository statsRepository;
  late _MockBadgeRepository badgeRepository;
  late _MockSocialRepository socialRepository;
  late _MockFeedRepository feedRepository;

  setUpAll(() => registerFallbackValue(StatsRange.all));

  setUp(() {
    authRepository = _MockAuthRepository();
    statsRepository = _MockStatsRepository();
    badgeRepository = _MockBadgeRepository();
    socialRepository = _MockSocialRepository();
    feedRepository = _MockFeedRepository();

    when(() => authRepository.getCurrentUser())
        .thenAnswer((_) async => Right(_user()));
    when(() => statsRepository.getSummary(any())).thenAnswer(
      (_) async => const Right(
        StatsSummary(
          booksFinished: 12,
          totalPages: 1200,
          totalMinutes: 600,
          avgSpeedPpm: 1.2,
          genreDistribution: [],
        ),
      ),
    );
    when(() => badgeRepository.getAllBadges()).thenAnswer(
      (_) async => Right([
        _badge('b1', unlocked: true),
        _badge('b2', unlocked: true),
        _badge('b3', unlocked: false),
      ]),
    );
    when(() => socialRepository.getFollowersCount())
        .thenAnswer((_) async => const Right(21));
    when(() => socialRepository.getFollowingCount())
        .thenAnswer((_) async => const Right(30));
    // The activity tab opens with the profile, so this has to answer from the
    // start — empty is the quiet default.
    when(
      () => feedRepository.getFeed(cursor: any(named: 'cursor')),
    ).thenAnswer(
      (_) async => const Right(ActivityPage(items: [], nextCursor: null)),
    );

    getIt.registerFactory<ProfileCubit>(
      () => ProfileCubit(
        GetCurrentUser(authRepository),
        GetStatsSummary(statsRepository),
        GetAllBadges(badgeRepository),
        GetFollowCounts(socialRepository),
      ),
    );
    getIt.registerFactory<MyActivityCubit>(
      () => MyActivityCubit(
        GetFeed(feedRepository),
        GetCurrentUser(authRepository),
      ),
    );
  });

  tearDown(() async => getIt.reset());

  Future<void> pumpProfile(WidgetTester tester) async {
    // Wider than a phone: the test font is far wider than Nunito, and the
    // three stat tiles would otherwise be the thing overflowing, drowning out
    // whatever this test is about.
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
        home: const ProfilePage(),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('the header carries the name, the join line and both counts', (
    tester,
  ) async {
    await pumpProfile(tester);

    expect(find.text('Julian'), findsOneWidget);
    // Each count is its own number and word, so they can be set as a pair of
    // stacked figures rather than one run of text.
    expect(find.text('21'), findsOneWidget);
    expect(find.text('Pengikut'), findsOneWidget);
    expect(find.text('30'), findsOneWidget);
    expect(find.text('Mengikuti'), findsOneWidget);
    // From the account's createdAt, month and year only.
    expect(find.textContaining('Bergabung sejak'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('the stat tiles show books, streak and badges', (tester) async {
    await pumpProfile(tester);

    expect(find.text('12'), findsOneWidget);
    expect(find.text('Buku'), findsOneWidget);
    expect(find.text('3'), findsOneWidget);
    expect(find.text('Streak'), findsOneWidget);
    // Two of three badges unlocked.
    expect(find.text('2/3'), findsOneWidget);
    expect(find.text('Lencana'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('the identity block carries the two tabs', (tester) async {
    await pumpProfile(tester);

    expect(find.text('Aktivitas'), findsOneWidget);
    expect(find.text('Pengaturan'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('the activity tab lists what the reader read', (tester) async {
    when(() => feedRepository.getFeed(cursor: any(named: 'cursor'))).thenAnswer(
      (_) async => Right(
        ActivityPage(items: [_activity('Atomic Habits')], nextCursor: null),
      ),
    );

    await pumpProfile(tester);

    expect(find.byType(SessionActivityCard), findsOneWidget);
    expect(find.text('Atomic Habits'), findsOneWidget);
  });

  testWidgets('an empty activity list says so', (tester) async {
    await pumpProfile(tester);

    expect(find.textContaining('Belum ada aktivitas'), findsOneWidget);
  });

  testWidgets('settings live behind their own tab', (tester) async {
    await pumpProfile(tester);

    // Nothing of the settings list shows on the activity tab.
    expect(find.text('Target membaca'), findsNothing);

    await tester.tap(find.text('Pengaturan'));
    await tester.pumpAndSettle();

    expect(find.text('Target membaca'), findsOneWidget);
    expect(find.text('Bahasa'), findsOneWidget);
    expect(find.text('Privasi'), findsOneWidget);
    expect(find.text('Bantuan'), findsOneWidget);
    expect(find.text('Keluar'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('scrolling the activity takes the identity block with it', (
    tester,
  ) async {
    when(() => feedRepository.getFeed(cursor: any(named: 'cursor'))).thenAnswer(
      (_) async => Right(
        ActivityPage(
          items: [for (var i = 0; i < 10; i++) _activity('Buku $i')],
          nextCursor: null,
        ),
      ),
    );

    await pumpProfile(tester);
    expect(find.textContaining('Bergabung sejak'), findsOneWidget);

    await tester.drag(
      find.byType(SessionActivityCard).first,
      const Offset(0, -600),
    );
    await tester.pumpAndSettle();

    // The header is gone, but the tab bar stayed put.
    expect(find.textContaining('Bergabung sejak'), findsNothing);
    expect(find.text('Aktivitas'), findsOneWidget);
  });
}
