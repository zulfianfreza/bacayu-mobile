import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart' hide Badge;
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/core/di/injection.dart';
import 'package:mobile/core/error/failure.dart';
import 'package:mobile/features/badges/domain/entities/badge.dart';
import 'package:mobile/features/badges/domain/repositories/badge_repository.dart';
import 'package:mobile/features/badges/domain/usecases/get_all_badges.dart';
import 'package:mobile/features/stats/domain/entities/daily_stat.dart';
import 'package:mobile/features/stats/domain/entities/stats_summary.dart';
import 'package:mobile/features/stats/domain/repositories/stats_repository.dart';
import 'package:mobile/features/stats/domain/usecases/get_heatmap.dart';
import 'package:mobile/features/stats/domain/usecases/get_stats_summary.dart';
import 'package:mobile/features/stats/presentation/cubit/stats_cubit.dart';
import 'package:mobile/features/stats/presentation/pages/stats_page.dart';
import 'package:mobile/l10n/app_localizations.dart';
import 'package:mocktail/mocktail.dart';

class _MockStatsRepository extends Mock implements StatsRepository {}

class _MockBadgeRepository extends Mock implements BadgeRepository {}

Badge _unlockedBadge() => Badge(
  id: 'b1',
  name: 'First Step',
  icon: '🎉',
  description: 'Finish your first session',
  imageUrl: null,
  unlocked: true,
  unlockedAt: DateTime(2026, 1, 1),
);

void main() {
  late _MockStatsRepository statsRepository;
  late _MockBadgeRepository badgeRepository;

  setUpAll(() => registerFallbackValue(StatsRange.week));

  setUp(() {
    statsRepository = _MockStatsRepository();
    badgeRepository = _MockBadgeRepository();

    when(() => statsRepository.getSummary(any())).thenAnswer(
      (_) async => const Right(
        StatsSummary(
          booksFinished: 12,
          totalPages: 1200,
          totalMinutes: 600,
          avgSpeedPpm: 1.2,
          genreDistribution: [GenreCount(genre: 'Fiction', count: 3)],
        ),
      ),
    );
    when(() => statsRepository.getHeatmap(any())).thenAnswer(
      (_) async => Right([
        DailyStat(
          date: DateTime.now(),
          totalMinutes: 30,
          totalPages: 5,
          sessionCount: 1,
        ),
      ]),
    );
    when(
      () => badgeRepository.getAllBadges(),
    ).thenAnswer((_) async => Right([_unlockedBadge()]));

    getIt.registerFactory<StatsCubit>(
      () => StatsCubit(
        GetStatsSummary(statsRepository),
        GetHeatmap(statsRepository),
      ),
    );
    getIt.registerFactory<GetAllBadges>(() => GetAllBadges(badgeRepository));
  });

  tearDown(() async => getIt.reset());

  Future<void> pumpStats(WidgetTester tester) async {
    // Wider than a phone: the test font is far wider than Nunito, and the
    // metric grid would otherwise be the thing overflowing.
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
        home: const StatsPage(),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('opens with its own headline and the range control', (
    tester,
  ) async {
    await pumpStats(tester);

    expect(find.text('Statistikmu'), findsOneWidget);
    expect(
      find.descendant(
        of: find.byType(DropdownButton<StatsRange>),
        matching: find.text('Minggu ini'),
      ),
      findsOneWidget,
    );
    expect(find.text('Sepanjang waktu'), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('shows the metric tiles for the loaded summary', (tester) async {
    await pumpStats(tester);

    expect(find.text('12'), findsOneWidget);
    expect(find.text('Buku selesai'), findsOneWidget);
    expect(find.text('1200'), findsOneWidget);
    expect(find.text('10h 0m'), findsOneWidget);
    expect(find.text('1.2'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('selects a range without reloading the already active range', (
    tester,
  ) async {
    await pumpStats(tester);

    await tester.tap(find.byType(DropdownButton<StatsRange>));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Minggu ini').last);
    await tester.pumpAndSettle();
    verify(() => statsRepository.getSummary(StatsRange.week)).called(1);

    await tester.tap(find.byType(DropdownButton<StatsRange>));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Sepanjang waktu').last);
    await tester.pumpAndSettle();
    verify(() => statsRepository.getSummary(StatsRange.all)).called(1);
    expect(
      tester
          .widget<DropdownButton<StatsRange>>(
            find.byType(DropdownButton<StatsRange>),
          )
          .value,
      StatsRange.all,
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('range dropdown fits phones and larger text', (tester) async {
    // Isolate the filter from the charts and metric grid.
    when(
      () => statsRepository.getSummary(any()),
    ).thenAnswer((_) async => const Left(NetworkFailure()));
    await pumpStats(tester);

    tester.view.physicalSize = const Size(360 * 2, 900 * 2);
    await tester.pumpAndSettle();
    await tester.tap(find.byType(DropdownButton<StatsRange>));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Sepanjang waktu').last);
    await tester.pumpAndSettle();
    expect(find.text('Sepanjang waktu'), findsOneWidget);
    expect(tester.takeException(), isNull);

    tester.view.physicalSize = const Size(700 * 2, 1400 * 2);
    await tester.pumpWidget(
      MaterialApp(
        locale: const Locale('id'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        builder: (context, child) => MediaQuery(
          data: MediaQuery.of(
            context,
          ).copyWith(textScaler: const TextScaler.linear(2)),
          child: child!,
        ),
        home: const StatsPage(),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.byType(DropdownButton<StatsRange>), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('puts the heatmap and the genre chart in titled cards', (
    tester,
  ) async {
    await pumpStats(tester);

    expect(find.text('Aktivitas membaca'), findsOneWidget);
    expect(find.text('Genre favorit'), findsOneWidget);
    expect(find.text('Badge kamu'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
