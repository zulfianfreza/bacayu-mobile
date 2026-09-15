import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/core/error/failure.dart';
import 'package:mobile/features/auth/domain/entities/user.dart';
import 'package:mobile/features/auth/domain/repositories/auth_repository.dart';
import 'package:mobile/features/auth/domain/usecases/get_current_user.dart';
import 'package:mobile/features/badges/domain/entities/badge.dart';
import 'package:mobile/features/badges/domain/repositories/badge_repository.dart';
import 'package:mobile/features/badges/domain/usecases/get_all_badges.dart';
import 'package:mobile/features/profile/presentation/cubit/profile_cubit.dart';
import 'package:mobile/features/profile/presentation/cubit/profile_state.dart';
import 'package:mobile/features/social/domain/repositories/social_repository.dart';
import 'package:mobile/features/social/domain/usecases/get_follow_counts.dart';
import 'package:mobile/features/stats/domain/entities/stats_summary.dart';
import 'package:mobile/features/stats/domain/repositories/stats_repository.dart';
import 'package:mobile/features/stats/domain/usecases/get_stats_summary.dart';
import 'package:mocktail/mocktail.dart';

class _MockAuthRepository extends Mock implements AuthRepository {}

class _MockStatsRepository extends Mock implements StatsRepository {}

class _MockBadgeRepository extends Mock implements BadgeRepository {}

class _MockSocialRepository extends Mock implements SocialRepository {}

User _user({int currentStreak = 3}) => User(
      id: 'u1',
      email: 'reader@bacayu.app',
      name: 'Reader',
      avatarUrl: '',
      timezone: 'UTC',
      favoriteGenres: const [],
      yearlyGoalBooks: 12,
      dailyGoalMinutes: 20,
      currentStreak: currentStreak,
      longestStreak: currentStreak,
      lastReadDate: null,
      privacyDefault: 'private',
      onboardingCompletedAt: DateTime(2026, 1, 1),
      createdAt: DateTime(2026, 1, 1),
      updatedAt: DateTime(2026, 1, 1),
    );

List<Badge> _badges() => const [
      Badge(
        id: 'b1',
        name: 'First Step',
        icon: '🎉',
        description: 'd',
        imageUrl: null,
        unlocked: true,
        unlockedAt: null,
      ),
      Badge(
        id: 'b2',
        name: 'Streak Master',
        icon: '🔥',
        description: 'd',
        imageUrl: null,
        unlocked: false,
        unlockedAt: null,
      ),
      Badge(
        id: 'b3',
        name: 'Bookworm',
        icon: '📚',
        description: 'd',
        imageUrl: null,
        unlocked: true,
        unlockedAt: null,
      ),
    ];

void main() {
  late _MockAuthRepository authRepository;
  late _MockStatsRepository statsRepository;
  late _MockBadgeRepository badgeRepository;
  late _MockSocialRepository socialRepository;
  late ProfileCubit cubit;

  setUpAll(() {
    registerFallbackValue(StatsRange.week);
  });

  setUp(() {
    authRepository = _MockAuthRepository();
    statsRepository = _MockStatsRepository();
    badgeRepository = _MockBadgeRepository();
    socialRepository = _MockSocialRepository();
    cubit = ProfileCubit(
      GetCurrentUser(authRepository),
      GetStatsSummary(statsRepository),
      GetAllBadges(badgeRepository),
      GetFollowCounts(socialRepository),
    );

    when(() => authRepository.getCurrentUser()).thenAnswer((_) async => Right(_user()));
    when(() => statsRepository.getSummary(any())).thenAnswer(
      (_) async => const Right(
        StatsSummary(
          booksFinished: 7,
          totalPages: 1000,
          totalMinutes: 500,
          avgSpeedPpm: 2.0,
          genreDistribution: [],
        ),
      ),
    );
    when(() => badgeRepository.getAllBadges()).thenAnswer((_) async => Right(_badges()));
    when(() => socialRepository.getFollowersCount()).thenAnswer((_) async => const Right(120));
    when(() => socialRepository.getFollowingCount()).thenAnswer((_) async => const Right(45));
  });

  tearDown(() => cubit.close());

  test('load() fires all 4 usecases in parallel, not one after another', () async {
    const delay = Duration(milliseconds: 60);
    when(() => authRepository.getCurrentUser())
        .thenAnswer((_) => Future.delayed(delay, () => Right(_user())));
    when(() => statsRepository.getSummary(any())).thenAnswer(
      (_) => Future.delayed(
        delay,
        () => const Right(
          StatsSummary(
            booksFinished: 7,
            totalPages: 1000,
            totalMinutes: 500,
            avgSpeedPpm: 2.0,
            genreDistribution: [],
          ),
        ),
      ),
    );
    when(() => badgeRepository.getAllBadges())
        .thenAnswer((_) => Future.delayed(delay, () => Right(_badges())));
    when(() => socialRepository.getFollowersCount())
        .thenAnswer((_) => Future.delayed(delay, () => const Right(120)));
    when(() => socialRepository.getFollowingCount())
        .thenAnswer((_) => Future.delayed(delay, () => const Right(45)));

    final stopwatch = Stopwatch()..start();
    await cubit.load();
    stopwatch.stop();

    // Sequential would take ~4x delay (~240ms); parallel finishes close to
    // a single delay.
    expect(stopwatch.elapsed, lessThan(delay * 2));
  });

  test('aggregates books finished, badge unlock count, and follow counts',
      () async {
    await cubit.load();

    final state = cubit.state as ProfileLoaded;
    expect(state.booksFinished, 7);
    expect(state.badgesUnlocked, 2); // b1 and b3 are unlocked, b2 isn't
    expect(state.totalBadges, 3);
    expect(state.followersCount, 120);
    expect(state.followingCount, 45);
    expect(state.user.currentStreak, 3);
  });

  test('any single failing usecase surfaces as ProfileError, not a partial load',
      () async {
    when(() => socialRepository.getFollowersCount())
        .thenAnswer((_) async => const Left(NetworkFailure()));

    await cubit.load();

    expect(cubit.state, isA<ProfileError>());
  });
}
