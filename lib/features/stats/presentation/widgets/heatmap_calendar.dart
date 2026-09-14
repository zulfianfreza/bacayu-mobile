import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../domain/entities/daily_stat.dart';

const _cellSize = 12.0;
const _cellGap = 3.0;

/// Pure so it's unit-testable without pumping a widget — color intensity
/// scales with [minutes] relative to [maxMinutes] in the dataset (Style
/// Guide Section 6.7: Tangerine ramp, not GitHub's green/sharp squares —
/// note that's about COLOR/SHAPE, the week/day GRID layout below is
/// deliberately GitHub-like).
Color heatmapColorFor({required int minutes, required int maxMinutes}) {
  if (minutes <= 0 || maxMinutes <= 0) return AppColors.line;
  final ratio = minutes / maxMinutes;
  if (ratio <= 0.2) return AppColors.tangerine50;
  if (ratio <= 0.4) return AppColors.tangerine100;
  if (ratio <= 0.6) return AppColors.tangerine300;
  if (ratio <= 0.8) return AppColors.tangerine500;
  return AppColors.tangerine700;
}

/// GitHub-style contribution grid: columns are weeks (Sunday-start, to
/// match GitHub's convention), rows are days of the week, spanning the
/// full year. Cells outside [year] (padding at the very start/end of the
/// grid so every column has 7 rows) render as blank spacers.
List<List<DateTime?>> _weeksOf(int year) {
  final jan1 = DateTime(year);
  final dec31 = DateTime(year, 12, 31);
  // Dart's DateTime.weekday is Mon=1..Sun=7; `% 7` turns that into "days
  // since the most recent Sunday" (Sunday itself -> 0).
  final gridStart = jan1.subtract(Duration(days: jan1.weekday % 7));
  final gridEnd = dec31.add(Duration(days: 6 - (dec31.weekday % 7)));

  final weeks = <List<DateTime?>>[];
  var cursor = gridStart;
  while (!cursor.isAfter(gridEnd)) {
    weeks.add([
      for (var i = 0; i < 7; i++) _dateOrNull(cursor.add(Duration(days: i)), year),
    ]);
    cursor = cursor.add(const Duration(days: 7));
  }
  return weeks;
}

DateTime? _dateOrNull(DateTime date, int year) => date.year == year ? date : null;

/// One label per week-column: the month abbreviation, shown only on the
/// first column where that month appears (so it doesn't repeat every week).
List<String?> _monthLabelsFor(List<List<DateTime?>> weeks, String locale) {
  final labels = <String?>[];
  DateTime? previousMonthAnchor;

  for (final week in weeks) {
    DateTime? firstDate;
    for (final date in week) {
      if (date != null) {
        firstDate = date;
        break;
      }
    }

    if (firstDate != null &&
        (previousMonthAnchor == null || firstDate.month != previousMonthAnchor.month)) {
      labels.add(DateFormat.MMM(locale).format(firstDate));
      previousMonthAnchor = firstDate;
    } else {
      labels.add(null);
    }
  }

  return labels;
}

class HeatmapCalendar extends StatelessWidget {
  const HeatmapCalendar({super.key, required this.year, required this.dailyStats});

  final int year;
  final List<DailyStat> dailyStats;

  @override
  Widget build(BuildContext context) {
    final byDate = <DateTime, int>{
      for (final stat in dailyStats)
        DateTime(stat.date.year, stat.date.month, stat.date.day): stat.totalMinutes,
    };
    final maxMinutes = dailyStats.fold(
      0,
      (max, stat) => stat.totalMinutes > max ? stat.totalMinutes : max,
    );

    final weeks = _weeksOf(year);
    final monthLabels = _monthLabelsFor(weeks, Localizations.localeOf(context).toString());

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              for (final label in monthLabels)
                SizedBox(
                  width: _cellSize + _cellGap,
                  child: Text(
                    label ?? '',
                    style: AppTypography.caption,
                    maxLines: 1,
                    softWrap: false,
                    overflow: TextOverflow.visible,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              for (final week in weeks)
                Padding(
                  padding: const EdgeInsets.only(right: _cellGap),
                  child: Column(
                    children: [
                      for (final date in week)
                        Padding(
                          padding: const EdgeInsets.only(bottom: _cellGap),
                          child: date == null
                              ? const SizedBox(width: _cellSize, height: _cellSize)
                              : _HeatmapCell(
                                  key: ValueKey(date),
                                  minutes: byDate[date] ?? 0,
                                  maxMinutes: maxMinutes,
                                ),
                        ),
                    ],
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _HeatmapCell extends StatelessWidget {
  const _HeatmapCell({super.key, required this.minutes, required this.maxMinutes});

  final int minutes;
  final int maxMinutes;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: _cellSize,
      height: _cellSize,
      decoration: BoxDecoration(
        color: heatmapColorFor(minutes: minutes, maxMinutes: maxMinutes),
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }
}
