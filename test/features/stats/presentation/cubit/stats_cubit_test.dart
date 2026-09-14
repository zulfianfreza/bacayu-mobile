import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/features/stats/domain/entities/daily_stat.dart';
import 'package:mobile/features/stats/domain/entities/stats_summary.dart';
import 'package:mobile/features/stats/domain/repositories/stats_repository.dart';
import 'package:mobile/features/stats/domain/usecases/get_heatmap.dart';
import 'package:mobile/features/stats/domain/usecases/get_stats_summary.dart';
import 'package:mobile/features/stats/presentation/cubit/stats_cubit.dart';
import 'package:mobile/features/stats/presentation/cubit/stats_state.dart';
import 'package:mocktail/mocktail.dart';

class _MockStatsRepository extends Mock implements StatsRepository {}

StatsSummary _summary() => const StatsSummary(
      booksFinished: 3,
      totalPages: 450,
      totalMinutes: 600,
      avgSpeedPpm: 0.75,
      genreDistribution: [GenreCount(genre: 'fiction', count: 2)],
    );

void main() {
  setUpAll(() {
    registerFallbackValue(StatsRange.week);
  });

  late _MockStatsRepository repository;
  late StatsCubit cubit;

  setUp(() {
    repository = _MockStatsRepository();
    cubit = StatsCubit(GetStatsSummary(repository), GetHeatmap(repository));
    when(() => repository.getHeatmap(any())).thenAnswer((_) async => const Right([]));
  });

  tearDown(() => cubit.close());

  test('changeRange re-fetches the summary with the newly selected range',
      () async {
    when(() => repository.getSummary(any()))
        .thenAnswer((_) async => Right(_summary()));

    await cubit.changeRange(StatsRange.month);
    verify(() => repository.getSummary(StatsRange.month)).called(1);
    expect(cubit.state.range, StatsRange.month);

    await cubit.changeRange(StatsRange.year);
    verify(() => repository.getSummary(StatsRange.year)).called(1);
    expect(cubit.state.range, StatsRange.year);

    await cubit.changeRange(StatsRange.all);
    verify(() => repository.getSummary(StatsRange.all)).called(1);
    expect(cubit.state.range, StatsRange.all);
  });

  test('emits [loading, loaded] with summary and heatmap on success',
      () async {
    final summary = _summary();
    final heatmap = [
      DailyStat(date: DateTime(2026, 1, 1), totalMinutes: 30, totalPages: 5, sessionCount: 1),
    ];
    when(() => repository.getSummary(any())).thenAnswer((_) async => Right(summary));
    when(() => repository.getHeatmap(any())).thenAnswer((_) async => Right(heatmap));

    final expectation = expectLater(
      cubit.stream,
      emitsInOrder([
        const StatsLoading(range: StatsRange.week),
        StatsLoaded(summary: summary, heatmap: heatmap, range: StatsRange.week),
      ]),
    );

    await cubit.load();
    await expectation;
  });
}
