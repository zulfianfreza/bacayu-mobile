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
    test('no activity, or an all-zero dataset, is the neutral line color', () {
      expect(heatmapColorFor(minutes: 0, maxMinutes: 100), AppColors.line);
      expect(heatmapColorFor(minutes: 50, maxMinutes: 0), AppColors.line);
    });

    test('intensity increases monotonically with minutes relative to max', () {
      final rank = {
        AppColors.line: 0,
        AppColors.tangerine50: 1,
        AppColors.tangerine100: 2,
        AppColors.tangerine300: 3,
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
    testWidgets(
        'cell color intensity is proportional to that day\'s total_minutes',
        (tester) async {
      final noActivity = DateTime(2026, 3, 1);
      final lightDay = DateTime(2026, 3, 2); // 30 / 120 = 25%
      final busiestDay = DateTime(2026, 3, 3); // 120 / 120 = 100%

      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(
            body: SingleChildScrollView(
              child: HeatmapCalendar(
                year: 2026,
                dailyStats: [
                  DailyStat(date: lightDay, totalMinutes: 30, totalPages: 5, sessionCount: 1),
                  DailyStat(date: busiestDay, totalMinutes: 120, totalPages: 20, sessionCount: 3),
                ],
              ),
            ),
          ),
        ),
      );

      expect(_cellColor(tester, noActivity), AppColors.line);
      expect(_cellColor(tester, lightDay), heatmapColorFor(minutes: 30, maxMinutes: 120));
      expect(_cellColor(tester, busiestDay), AppColors.tangerine700);

      // The day with more minutes must render a strictly more intense cell.
      expect(_cellColor(tester, lightDay), isNot(_cellColor(tester, busiestDay)));
    });
  });
}
