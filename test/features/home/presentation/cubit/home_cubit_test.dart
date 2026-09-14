import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/features/auth/domain/entities/user.dart';
import 'package:mobile/features/auth/domain/repositories/auth_repository.dart';
import 'package:mobile/features/auth/domain/usecases/get_current_user.dart';
import 'package:mobile/features/feed/domain/entities/activity.dart';
import 'package:mobile/features/feed/domain/repositories/feed_repository.dart';
import 'package:mobile/features/feed/domain/usecases/get_feed.dart';
import 'package:mobile/features/home/presentation/cubit/home_cubit.dart';
import 'package:mobile/features/home/presentation/cubit/home_state.dart';
import 'package:mobile/features/shelf/domain/entities/user_book.dart';
import 'package:mobile/features/shelf/domain/repositories/shelf_repository.dart';
import 'package:mobile/features/shelf/domain/usecases/list_shelf.dart';
import 'package:mobile/features/stats/domain/entities/daily_stat.dart';
import 'package:mobile/features/stats/domain/repositories/stats_repository.dart';
import 'package:mobile/features/stats/domain/usecases/get_heatmap.dart';
import 'package:mocktail/mocktail.dart';

class _MockAuthRepository extends Mock implements AuthRepository {}

class _MockStatsRepository extends Mock implements StatsRepository {}

class _MockShelfRepository extends Mock implements ShelfRepository {}

class _MockFeedRepository extends Mock implements FeedRepository {}

User _user({int currentStreak = 0}) => User(
      id: 'u1',
      email: 'reader@bacayu.app',
      name: 'Reader',
      avatarUrl: '',
      timezone: 'UTC',
      favoriteGenres: const [],
      yearlyGoalBooks: null,
      dailyGoalMinutes: null,
      currentStreak: currentStreak,
      longestStreak: currentStreak,
      lastReadDate: null,
      privacyDefault: 'private',
      onboardingCompletedAt: DateTime(2026, 1, 1),
      createdAt: DateTime(2026, 1, 1),
      updatedAt: DateTime(2026, 1, 1),
    );

Activity _activity() => Activity(
      id: 'a1',
      occurredAt: DateTime(2026, 1, 1),
      payload: const BadgeActivityPayload(
        badgeName: 'First Step',
        badgeIcon: '🎉',
        badgeDescription: 'd',
      ),
    );

void main() {
  late _MockAuthRepository authRepository;
  late _MockStatsRepository statsRepository;
  late _MockShelfRepository shelfRepository;
  late _MockFeedRepository feedRepository;
  late HomeCubit cubit;

  setUpAll(() {
    registerFallbackValue(ShelfStatus.reading);
  });

  setUp(() {
    authRepository = _MockAuthRepository();
    statsRepository = _MockStatsRepository();
    shelfRepository = _MockShelfRepository();
    feedRepository = _MockFeedRepository();
    cubit = HomeCubit(
      GetCurrentUser(authRepository),
      GetHeatmap(statsRepository),
      ListShelf(shelfRepository),
      GetFeed(feedRepository),
    );

    when(() => statsRepository.getHeatmap(any()))
        .thenAnswer((_) async => const Right(<DailyStat>[]));
    when(() => shelfRepository.listShelf(
          status: any(named: 'status'),
          page: any(named: 'page'),
        )).thenAnswer((_) async => const Right(<UserBook>[]));
  });

  tearDown(() => cubit.close());

  test('load() fires all 4 usecases in parallel, not one after another', () async {
    const delay = Duration(milliseconds: 60);
    when(() => authRepository.getCurrentUser())
        .thenAnswer((_) => Future.delayed(delay, () => Right(_user())));
    when(() => statsRepository.getHeatmap(any()))
        .thenAnswer((_) => Future.delayed(delay, () => const Right(<DailyStat>[])));
    when(() => shelfRepository.listShelf(
          status: any(named: 'status'),
          page: any(named: 'page'),
        )).thenAnswer((_) => Future.delayed(delay, () => const Right(<UserBook>[])));
    when(() => feedRepository.getFeed(cursor: any(named: 'cursor')))
        .thenAnswer((_) => Future.delayed(delay, () => const Right(<Activity>[])));

    final stopwatch = Stopwatch()..start();
    await cubit.load();
    stopwatch.stop();

    // Sequential would take ~4x delay (~240ms); parallel finishes close to
    // a single delay.
    expect(stopwatch.elapsed, lessThan(delay * 2));
  });

  test('isEmptyState is true only when feed is empty AND streak is 0',
      () async {
    when(() => authRepository.getCurrentUser())
        .thenAnswer((_) async => Right(_user(currentStreak: 0)));
    when(() => feedRepository.getFeed(cursor: any(named: 'cursor')))
        .thenAnswer((_) async => const Right(<Activity>[]));

    await cubit.load();

    expect((cubit.state as HomeLoaded).isEmptyState, isTrue);
  });

  test('isEmptyState is false when feed is empty but streak is non-zero',
      () async {
    when(() => authRepository.getCurrentUser())
        .thenAnswer((_) async => Right(_user(currentStreak: 5)));
    when(() => feedRepository.getFeed(cursor: any(named: 'cursor')))
        .thenAnswer((_) async => const Right(<Activity>[]));

    await cubit.load();

    expect((cubit.state as HomeLoaded).isEmptyState, isFalse);
  });

  test('isEmptyState is false when streak is 0 but feed has activity',
      () async {
    when(() => authRepository.getCurrentUser())
        .thenAnswer((_) async => Right(_user(currentStreak: 0)));
    when(() => feedRepository.getFeed(cursor: any(named: 'cursor')))
        .thenAnswer((_) async => Right([_activity()]));

    await cubit.load();

    expect((cubit.state as HomeLoaded).isEmptyState, isFalse);
  });

  test('isEmptyState is false when neither condition holds', () async {
    when(() => authRepository.getCurrentUser())
        .thenAnswer((_) async => Right(_user(currentStreak: 5)));
    when(() => feedRepository.getFeed(cursor: any(named: 'cursor')))
        .thenAnswer((_) async => Right([_activity()]));

    await cubit.load();

    expect((cubit.state as HomeLoaded).isEmptyState, isFalse);
  });
}
