import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/core/widget/streak_widget_service.dart';
import 'package:mobile/features/auth/domain/entities/user.dart';
import 'package:mobile/features/auth/domain/repositories/auth_repository.dart';
import 'package:mobile/features/auth/domain/usecases/get_current_user.dart';
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

void main() {
  late _MockAuthRepository authRepository;
  late _MockStatsRepository statsRepository;
  late _MockShelfRepository shelfRepository;
  late HomeCubit cubit;

  setUpAll(() {
    registerFallbackValue(ShelfStatus.reading);
  });

  setUp(() {
    authRepository = _MockAuthRepository();
    statsRepository = _MockStatsRepository();
    shelfRepository = _MockShelfRepository();
    cubit = HomeCubit(
      GetCurrentUser(authRepository),
      GetHeatmap(statsRepository),
      ListShelf(shelfRepository),
      StreakWidgetService(),
    );

    when(
      () => authRepository.getCurrentUser(),
    ).thenAnswer((_) async => Right(_user()));
    when(
      () => statsRepository.getHeatmap(any()),
    ).thenAnswer((_) async => const Right(<DailyStat>[]));
    when(
      () => shelfRepository.listShelf(
        status: any(named: 'status'),
        page: any(named: 'page'),
      ),
    ).thenAnswer((_) async => const Right(<UserBook>[]));
  });

  tearDown(() => cubit.close());

  test(
    'load() fires all 3 usecases in parallel, not one after another',
    () async {
      const delay = Duration(milliseconds: 60);
      when(
        () => authRepository.getCurrentUser(),
      ).thenAnswer((_) => Future.delayed(delay, () => Right(_user())));
      when(() => statsRepository.getHeatmap(any())).thenAnswer(
        (_) => Future.delayed(delay, () => const Right(<DailyStat>[])),
      );
      when(
        () => shelfRepository.listShelf(
          status: any(named: 'status'),
          page: any(named: 'page'),
        ),
      ).thenAnswer(
        (_) => Future.delayed(delay, () => const Right(<UserBook>[])),
      );

      final stopwatch = Stopwatch()..start();
      await cubit.load();
      stopwatch.stop();

      // Sequential would take ~3x delay (~180ms); parallel finishes close to
      // a single delay.
      expect(stopwatch.elapsed, lessThan(delay * 2));
    },
  );

  test(
    'load() zero-fills a 7-day strip when the year has no stat rows',
    () async {
      await cubit.load();

      final state = cubit.state as HomeLoaded;
      expect(state.last7Days, hasLength(7));
      expect(state.last7Days.every((d) => d.totalMinutes == 0), isTrue);
      expect(state.continueReading, isEmpty);
      expect(state.userName, 'Reader');
    },
  );
}
