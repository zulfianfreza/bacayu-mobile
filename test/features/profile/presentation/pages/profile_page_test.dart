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

void main() {
  late _MockAuthRepository authRepository;
  late _MockStatsRepository statsRepository;
  late _MockBadgeRepository badgeRepository;
  late _MockSocialRepository socialRepository;

  setUpAll(() => registerFallbackValue(StatsRange.all));

  setUp(() {
    authRepository = _MockAuthRepository();
    statsRepository = _MockStatsRepository();
    badgeRepository = _MockBadgeRepository();
    socialRepository = _MockSocialRepository();

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

    getIt.registerFactory<ProfileCubit>(
      () => ProfileCubit(
        GetCurrentUser(authRepository),
        GetStatsSummary(statsRepository),
        GetAllBadges(badgeRepository),
        GetFollowCounts(socialRepository),
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
    expect(find.textContaining('Membaca sejak'), findsOneWidget);
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
}
