import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mobile/core/theme/build_context_extension.dart';

import '../../../../core/localization/build_context_extension.dart';
import '../../../../core/theme/app_typography.dart';
import '../../domain/entities/daily_stat.dart';

const _cellSize = 12.0;
const _cellGap = 3.0;
const _gutterWidth = 26.0;

/// Pure so it's unit-testable without pumping a widget — color intensity
/// scales with [minutes] relative to [maxMinutes] in the dataset (Style
/// Guide Section 6.7: Tangerine ramp, not GitHub's green/sharp squares —
/// note that's about COLOR/SHAPE, the week/day GRID layout below is
/// deliberately GitHub-like).
///
/// The shades come from [ramp] — `context.colors.heatmapRamp`, six steps,
/// dimmest first — rather than a constant here: the "nothing read" cell is a
/// surface role and has to follow the theme, and the intensity order flips
/// between modes (see [AppSemanticColors.heatmapRamp]).
Color heatmapColorFor({
  required int minutes,
  required int maxMinutes,
  required List<Color> ramp,
}) {
  if (minutes <= 0 || maxMinutes <= 0) return ramp[0];
  final ratio = minutes / maxMinutes;
  if (ratio <= 0.2) return ramp[1];
  if (ratio <= 0.4) return ramp[2];
  if (ratio <= 0.6) return ramp[3];
  if (ratio <= 0.8) return ramp[4];
  return ramp[5];
}

/// GitHub-style contribution grid: columns are weeks (Sunday-start, to
/// match GitHub's convention), rows are days of the week, spanning the
/// full year. Cells outside [year] (padding at the very start/end of the
/// grid so every column has 7 rows) render as blank spacers.
///
/// A year of cells is a lot to hand someone with no key: the day gutter stays
/// pinned while the weeks scroll past it, today carries a ring, and the ramp
/// is spelled out underneath.
class HeatmapCalendar extends StatelessWidget {
  const HeatmapCalendar({
    super.key,
    required this.year,
    required this.dailyStats,
  });

  /// Marks the legend, so a test can prove it still covers every shade the
  /// grid can paint.
  @visibleForTesting
  static const legendKey = Key('heatmap-legend');

  final int year;
  final List<DailyStat> dailyStats;

  @override
  Widget build(BuildContext context) {
    final byDate = <DateTime, int>{
      for (final stat in dailyStats)
        DateTime(stat.date.year, stat.date.month, stat.date.day):
            stat.totalMinutes,
    };
    final maxMinutes = dailyStats.fold(
      0,
      (max, stat) => stat.totalMinutes > max ? stat.totalMinutes : max,
    );

    final today = DateTime.now();
    final weeks = _weeksOf(year);
    final monthLabels = _monthLabelsFor(
      weeks,
      Localizations.localeOf(context).toLanguageTag(),
    );
    final monthRowHeight = _captionLineHeight(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Pinned: the year scrolls sideways, and which row is which day
            // must not scroll away with it.
            _WeekdayGutter(
              locale: Localizations.localeOf(context).toLanguageTag(),
              topOffset: monthRowHeight + 4,
            ),
            const SizedBox(width: 6),
            Expanded(
              child: SingleChildScrollView(
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
                              style: context.captionStyle,
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
                                    padding: const EdgeInsets.only(
                                      bottom: _cellGap,
                                    ),
                                    child: date == null
                                        ? const SizedBox(
                                            width: _cellSize,
                                            height: _cellSize,
                                          )
                                        : _HeatmapCell(
                                            key: ValueKey(date),
                                            minutes: byDate[date] ?? 0,
                                            maxMinutes: maxMinutes,
                                            isToday: _isSameDay(date, today),
                                          ),
                                  ),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        const _Legend(key: HeatmapCalendar.legendKey),
      ],
    );
  }
}

bool _isSameDay(DateTime a, DateTime b) =>
    a.year == b.year && a.month == b.month && a.day == b.day;

/// Height of one line of caption text, so the day gutter can start exactly
/// where the cells start. Measured from the style rather than guessed at, and
/// scaled the way the text itself is.
double _captionLineHeight(BuildContext context) {
  final caption = AppTypography.caption;
  final height = (caption.fontSize ?? 13) * (caption.height ?? 1.4);
  return MediaQuery.textScalerOf(context).scale(height);
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
      for (var i = 0; i < 7; i++)
        _dateOrNull(cursor.add(Duration(days: i)), year),
    ]);
    cursor = cursor.add(const Duration(days: 7));
  }
  return weeks;
}

DateTime? _dateOrNull(DateTime date, int year) =>
    date.year == year ? date : null;

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
        (previousMonthAnchor == null ||
            firstDate.month != previousMonthAnchor.month)) {
      labels.add(DateFormat.MMM(locale).format(firstDate));
      previousMonthAnchor = firstDate;
    } else {
      labels.add(null);
    }
  }

  return labels;
}

/// The rows' own names, pinned beside the grid.
///
/// Only Monday, Wednesday and Friday are labelled, the way GitHub does it: at
/// this cell size, seven stacked labels would be more noise than orientation.
class _WeekdayGutter extends StatelessWidget {
  const _WeekdayGutter({required this.locale, required this.topOffset});

  final String locale;
  final double topOffset;

  /// Rows run Sunday-first, matching [_weeksOf]. 2024-01-07 was a Sunday.
  static final _sunday = DateTime(2024, 1, 7);
  static const _labelled = {1, 3, 5};

  @override
  Widget build(BuildContext context) {
    final format = DateFormat.E(locale);

    return Padding(
      padding: EdgeInsets.only(top: topOffset),
      child: Column(
        children: [
          for (var i = 0; i < 7; i++)
            Padding(
              padding: const EdgeInsets.only(bottom: _cellGap),
              child: SizedBox(
                width: _gutterWidth,
                height: _cellSize,
                child: _labelled.contains(i)
                    ? Align(
                        alignment: Alignment.centerRight,
                        child: Text(
                          format.format(_sunday.add(Duration(days: i))),
                          style: context.captionStyle.copyWith(fontSize: 10),
                          maxLines: 1,
                        ),
                      )
                    : null,
              ),
            ),
        ],
      ),
    );
  }
}

/// What the shades mean, spelled out: "less … more", with a swatch per step of
/// the ramp the grid actually uses.
class _Legend extends StatelessWidget {
  const _Legend({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Row(
      children: [
        Text(l10n.heatmapLess, style: context.captionStyle),
        const SizedBox(width: 6),
        for (final color in context.colors.heatmapRamp) ...[
          Container(
            width: _cellSize,
            height: _cellSize,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          const SizedBox(width: 4),
        ],
        const SizedBox(width: 2),
        Text(l10n.heatmapMore, style: context.captionStyle),
      ],
    );
  }
}

class _HeatmapCell extends StatelessWidget {
  const _HeatmapCell({
    super.key,
    required this.minutes,
    required this.maxMinutes,
    required this.isToday,
  });

  final int minutes;
  final int maxMinutes;

  /// Ringed, so a year of squares still has a "you are here".
  final bool isToday;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: _cellSize,
      height: _cellSize,
      decoration: BoxDecoration(
        color: heatmapColorFor(
          minutes: minutes,
          maxMinutes: maxMinutes,
          ramp: context.colors.heatmapRamp,
        ),
        borderRadius: BorderRadius.circular(4),
        border: isToday
            ? Border.all(color: context.colors.textFaint, width: 1.5)
            : null,
      ),
    );
  }
}
