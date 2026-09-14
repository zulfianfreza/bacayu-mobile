import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/error/failure_localizer.dart';
import '../../../../core/localization/build_context_extension.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_typography.dart';
import '../../domain/entities/stats_summary.dart';
import '../cubit/stats_cubit.dart';
import '../cubit/stats_state.dart';
import '../widgets/badge_preview_row.dart';
import '../widgets/heatmap_calendar.dart';
import '../widgets/metric_card.dart';

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
      appBar: AppBar(title: Text(l10n.yourStats)),
      body: BlocBuilder<StatsCubit, StatsState>(
        builder: (context, state) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
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
                        const SizedBox(height: 24),
                        HeatmapCalendar(
                          year: DateTime.now().year,
                          dailyStats: heatmap,
                        ),
                        const SizedBox(height: 24),
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
    );
  }
}

class _RangeSegmentedControl extends StatelessWidget {
  const _RangeSegmentedControl({required this.activeRange, required this.onChanged});

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

    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColors.line,
        borderRadius: BorderRadius.circular(AppRadius.pill),
      ),
      child: Row(
        children: [
          for (final (range, label) in options)
            Expanded(
              child: GestureDetector(
                onTap: () => onChanged(range),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: range == activeRange
                        ? AppColors.tangerine500
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(AppRadius.pill),
                  ),
                  child: Text(
                    label,
                    style: AppTypography.button.copyWith(
                      color: range == activeRange
                          ? Colors.white
                          : AppColors.inkSoft,
                    ),
                  ),
                ),
              ),
            ),
        ],
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

    final cards = [
      (summary.booksFinished.toString(), l10n.metricBooksFinished, AppColors.tangerine50),
      (summary.totalPages.toString(), l10n.metricPagesRead, AppColors.lagoon50),
      ('${hours}h ${minutes}m', l10n.metricTimeReading, AppColors.sunshine50),
      (summary.avgSpeedPpm.toStringAsFixed(1), l10n.metricAvgSpeed, AppColors.tangerine50),
    ];

    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      childAspectRatio: 1.6,
      children: [
        for (final (value, label, tint) in cards)
          MetricCard(value: value, label: label, tint: tint),
      ],
    );
  }
}

class _GenreDistributionChart extends StatelessWidget {
  const _GenreDistributionChart({required this.genreDistribution});

  final List<GenreCount> genreDistribution;

  static const _colors = [AppColors.lagoon500, AppColors.sunshine500, AppColors.tangerine500];

  @override
  Widget build(BuildContext context) {
    if (genreDistribution.isEmpty) return const SizedBox.shrink();

    final maxCount = genreDistribution
        .map((g) => g.count)
        .reduce((a, b) => a > b ? a : b)
        .toDouble();

    return SizedBox(
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
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(6)),
                  ),
                ],
              ),
          ],
          titlesData: FlTitlesData(
            leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
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
    );
  }
}
