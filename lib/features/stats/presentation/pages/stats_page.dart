import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/error/failure_localizer.dart';
import '../../../../core/localization/build_context_extension.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/bordered_card.dart';
import '../../../../core/widgets/raised_box.dart';
import '../../domain/entities/stats_summary.dart';
import '../cubit/stats_cubit.dart';
import '../cubit/stats_state.dart';
import '../widgets/badge_preview_row.dart';
import '../widgets/heatmap_calendar.dart';
import '../widgets/metric_card.dart';
import '../../../../core/theme/build_context_extension.dart';

class StatsPage extends StatelessWidget {
  const StatsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<StatsCubit>()..load(),
      child: const _StatsView(),
    );
  }
}

class _StatsView extends StatelessWidget {
  const _StatsView();

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Scaffold(
      // No app bar: the title is the page's own headline, the way Home and
      // Profile open — one visual language across the tabs.
      body: SafeArea(
        child: BlocBuilder<StatsCubit, StatsState>(
          builder: (context, state) {
            return SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(l10n.yourStats, style: AppTypography.displaySm),
                  const SizedBox(height: 20),
                  _RangeSegmentedControl(
                    activeRange: state.range,
                    onChanged: (range) =>
                        context.read<StatsCubit>().changeRange(range),
                  ),
                  const SizedBox(height: 20),
                  switch (state) {
                    StatsLoading() => const Padding(
                      padding: EdgeInsets.symmetric(vertical: 48),
                      child: Center(child: CircularProgressIndicator()),
                    ),
                    StatsError(:final failure) => Padding(
                      padding: const EdgeInsets.symmetric(vertical: 24),
                      child: Text(
                        failure.localizedMessage(context),
                        style: AppTypography.body,
                      ),
                    ),
                    StatsLoaded(:final summary, :final heatmap) => Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _MetricsGrid(summary: summary),
                        const SizedBox(height: 20),
                        _SectionCard(
                          title: l10n.statsHeatmapTitle,
                          child: HeatmapCalendar(
                            year: DateTime.now().year,
                            dailyStats: heatmap,
                          ),
                        ),
                        const SizedBox(height: 20),
                        _GenreDistributionChart(
                          genreDistribution: summary.genreDistribution,
                        ),
                        const SizedBox(height: 24),
                        const BadgePreviewRow(),
                      ],
                    ),
                    StatsInitial() => const SizedBox.shrink(),
                  },
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

/// A titled chunky card — the page's unit of section, so the heatmap and the
/// genre chart read as the same kind of object as the metric tiles rather
/// than as loose widgets on the background.
class _SectionCard extends StatelessWidget {
  const _SectionCard({required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return BorderedCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: AppTypography.heading),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }
}

class _RangeSegmentedControl extends StatelessWidget {
  const _RangeSegmentedControl({
    required this.activeRange,
    required this.onChanged,
  });

  final StatsRange activeRange;
  final ValueChanged<StatsRange> onChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final options = [
      (StatsRange.week, l10n.rangeWeek),
      (StatsRange.month, l10n.rangeMonth),
      (StatsRange.year, l10n.rangeYear),
      (StatsRange.all, l10n.rangeAll),
    ];

    return Row(
      children: [
        for (var i = 0; i < options.length; i++) ...[
          if (i > 0) const SizedBox(width: 8),
          Expanded(
            child: _RangeSegment(
              label: options[i].$2,
              isActive: options[i].$1 == activeRange,
              onTap: () => onChanged(options[i].$1),
            ),
          ),
        ],
      ],
    );
  }
}

/// One range, built like the metric tiles below it: every segment sits on its
/// own edge, and the selected one is simply filled in — so the control belongs
/// to the same system as the numbers it filters.
class _RangeSegment extends StatelessWidget {
  const _RangeSegment({
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  final String label;
  final bool isActive;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: RaisedBox(
        color: isActive ? AppColors.tangerine : context.colors.surface,
        radius: AppRadius.sm,
        edgeHeight: 3,
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
        child: SizedBox(
          width: double.infinity,
          // Shrinks rather than truncates: four labels have to share one row
          // in every language, and "Minggu" is already tight in Indonesian.
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              label,
              style: AppTypography.button.copyWith(
                color: isActive ? Colors.white : context.colors.textSecondary,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _MetricsGrid extends StatelessWidget {
  const _MetricsGrid({required this.summary});

  final StatsSummary summary;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final hours = summary.totalMinutes ~/ 60;
    final minutes = summary.totalMinutes % 60;

    // Step-100 tints rather than the 300s these started on: the tiles carry a
    // step-700 icon, which is where the colour reads from now, and the softer
    // body keeps four of them in one grid from shouting.
    final cards = [
      (
        summary.booksFinished.toString(),
        l10n.metricBooksFinished,
        context.colors.lagoonTint,
        context.colors.lagoonAccent,
        'assets/icons/book-open-02-stroke.png',
      ),
      (
        summary.totalPages.toString(),
        l10n.metricPagesRead,
        context.colors.tangerineTint,
        context.colors.tangerineAccent,
        'assets/icons/document-stroke.png',
      ),
      (
        '${hours}h ${minutes}m',
        l10n.metricTimeReading,
        context.colors.sunshineTint,
        context.colors.sunshineAccent,
        'assets/icons/clock-stroke.png',
      ),
      (
        summary.avgSpeedPpm.toStringAsFixed(1),
        l10n.metricAvgSpeed,
        context.colors.infoTint,
        context.colors.infoAccent,
        'assets/icons/speed-stroke.png',
      ),
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        // Asked of the card rather than a fixed aspect ratio: the tile carries
        // type, and a ratio would clip it as soon as the font size changes.
        mainAxisExtent: MetricCard.heightFor(context),
      ),
      itemCount: cards.length,
      itemBuilder: (context, index) {
        final (value, label, tint, accent, icon) = cards[index];
        return MetricCard(
          value: value,
          label: label,
          tint: tint,
          accent: accent,
          icon: icon,
        );
      },
    );
  }
}

class _GenreDistributionChart extends StatelessWidget {
  const _GenreDistributionChart({required this.genreDistribution});

  final List<GenreCount> genreDistribution;

  static const _colors = [
    AppColors.lagoon500,
    AppColors.sunshine500,
    AppColors.tangerine500,
  ];

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    if (genreDistribution.isEmpty) return const SizedBox.shrink();

    final maxCount = genreDistribution
        .map((g) => g.count)
        .reduce((a, b) => a > b ? a : b)
        .toDouble();

    return _SectionCard(
      title: l10n.statsGenresTitle,
      child: SizedBox(
        height: 180,
        child: BarChart(
          BarChartData(
            maxY: maxCount * 1.2,
            gridData: const FlGridData(show: false),
            borderData: FlBorderData(show: false),
            barGroups: [
              for (var i = 0; i < genreDistribution.length; i++)
                BarChartGroupData(
                  x: i,
                  barRods: [
                    BarChartRodData(
                      toY: genreDistribution[i].count.toDouble(),
                      color: _colors[i % _colors.length],
                      width: 20,
                      // Rounded like everything else that carries the brand —
                      // sharp-topped bars read as a charting library default.
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(AppRadius.sm),
                      ),
                    ),
                  ],
                ),
            ],
            titlesData: FlTitlesData(
              leftTitles: const AxisTitles(
                sideTitles: SideTitles(showTitles: false),
              ),
              rightTitles: const AxisTitles(
                sideTitles: SideTitles(showTitles: false),
              ),
              topTitles: const AxisTitles(
                sideTitles: SideTitles(showTitles: false),
              ),
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  getTitlesWidget: (value, meta) {
                    final index = value.toInt();
                    if (index < 0 || index >= genreDistribution.length) {
                      return const SizedBox.shrink();
                    }
                    return Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(
                        genreDistribution[index].genre,
                        style: AppTypography.caption,
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
