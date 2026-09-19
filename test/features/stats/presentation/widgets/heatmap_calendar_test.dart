import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/core/theme/app_colors.dart';
import 'package:mobile/features/stats/domain/entities/daily_stat.dart';
import 'package:mobile/features/stats/presentation/widgets/heatmap_calendar.dart';
import 'package:mobile/l10n/app_localizations.dart';

Color _cellColor(WidgetTester tester, DateTime date) {
  final container = tester.widget<Container>(
    find.descendant(
      of: find.byKey(ValueKey(date)),
      matching: find.byType(Container),
    ),
  );
  return (container.decoration! as BoxDecoration).color!;
}

void main() {
  group('heatmapColorFor (pure)', () {
    test('no activity, or an all-zero dataset, is the slate neutral', () {
      expect(heatmapColorFor(minutes: 0, maxMinutes: 100), AppColors.slate200);
      expect(heatmapColorFor(minutes: 50, maxMinutes: 0), AppColors.slate200);
    });

    test('intensity increases monotonically with minutes relative to max', () {
      final rank = {
        AppColors.slate200: 0,
        AppColors.tangerine200: 1,
        AppColors.tangerine300: 2,
        AppColors.tangerine400: 3,
        AppColors.tangerine500: 4,
        AppColors.tangerine700: 5,
      };

      final colors = [0, 10, 30, 50, 70, 100]
          .map((m) => heatmapColorFor(minutes: m, maxMinutes: 100))
          .map((c) => rank[c]!)
          .toList();

      for (var i = 1; i < colors.length; i++) {
        expect(colors[i], greaterThanOrEqualTo(colors[i - 1]));
      }
      // The maximum-minutes day must be the darkest step.
      expect(colors.last, rank[AppColors.tangerine700]);
    });
  });

  group('HeatmapCalendar widget', () {
    Future<void> pumpCalendar(
      WidgetTester tester, {
      required int year,
      List<DailyStat> stats = const [],
    }) async {
      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(
            body: SingleChildScrollView(
              child: HeatmapCalendar(year: year, dailyStats: stats),
            ),
          ),
        ),
      );
    }

    BoxDecoration decorationOf(WidgetTester tester, DateTime date) {
      final container = tester.widget<Container>(
        find.descendant(
          of: find.byKey(ValueKey(date)),
          matching: find.byType(Container),
        ),
      );
      return container.decoration! as BoxDecoration;
    }

    testWidgets(
      'cell color intensity is proportional to that day\'s total_minutes',
      (tester) async {
        final noActivity = DateTime(2026, 3, 1);
        final lightDay = DateTime(2026, 3, 2); // 30 / 120 = 25%
        final busiestDay = DateTime(2026, 3, 3); // 120 / 120 = 100%

        await pumpCalendar(
          tester,
          year: 2026,
          stats: [
            DailyStat(
              date: lightDay,
              totalMinutes: 30,
              totalPages: 5,
              sessionCount: 1,
            ),
            DailyStat(
              date: busiestDay,
              totalMinutes: 120,
              totalPages: 20,
              sessionCount: 3,
            ),
          ],
        );

        expect(_cellColor(tester, noActivity), AppColors.slate200);
        expect(
          _cellColor(tester, lightDay),
          heatmapColorFor(minutes: 30, maxMinutes: 120),
        );
        expect(_cellColor(tester, busiestDay), AppColors.tangerine700);

        // The day with more minutes must render a strictly more intense cell.
        expect(
          _cellColor(tester, lightDay),
          isNot(_cellColor(tester, busiestDay)),
        );
      },
    );

    testWidgets('the legend spells out every shade the grid can paint', (
      tester,
    ) async {
      await pumpCalendar(tester, year: 2026);

      final swatches = tester
          .widgetList<Container>(
            find.descendant(
              of: find.byKey(HeatmapCalendar.legendKey),
              matching: find.byType(Container),
            ),
          )
          .map((container) => (container.decoration! as BoxDecoration).color)
          .toSet();

      // Every colour the ramp can produce has to appear in the key — this is
      // what stops the legend and the grid drifting apart.
      final producible = {
        for (var minutes = 0; minutes <= 100; minutes++)
          heatmapColorFor(minutes: minutes, maxMinutes: 100),
      };
      expect(swatches, producible);
    });

    testWidgets('today carries a ring, other days do not', (tester) async {
      final now = DateTime.now();
      await pumpCalendar(tester, year: now.year);

      final today = DateTime(now.year, now.month, now.day);
      final ringed = decorationOf(tester, today);
      expect(ringed.border, isNotNull);

      // A neighbour day is left plain.
      final yesterday = today.subtract(const Duration(days: 1));
      if (yesterday.year == now.year) {
        expect(decorationOf(tester, yesterday).border, isNull);
      }
    });

    testWidgets('the day gutter names its rows', (tester) async {
      await pumpCalendar(tester, year: 2026);

      expect(find.text('Mon'), findsOneWidget);
      expect(find.text('Wed'), findsOneWidget);
      expect(find.text('Fri'), findsOneWidget);
    });

    testWidgets('the legend is labelled at both ends', (tester) async {
      await pumpCalendar(tester, year: 2026);

      expect(find.text('Less'), findsOneWidget);
      expect(find.text('More'), findsOneWidget);
    });
  });
}
