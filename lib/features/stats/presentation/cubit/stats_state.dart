import 'package:equatable/equatable.dart';

import '../../../../core/error/failure.dart';
import '../../domain/entities/daily_stat.dart';
import '../../domain/entities/stats_summary.dart';

sealed class StatsState extends Equatable {
  const StatsState({required this.range});

  final StatsRange range;

  @override
  List<Object?> get props => [range];
}

class StatsInitial extends StatsState {
  const StatsInitial({required super.range});
}

class StatsLoading extends StatsState {
  const StatsLoading({required super.range});
}

class StatsLoaded extends StatsState {
  const StatsLoaded({
    required this.summary,
    required this.heatmap,
    required super.range,
  });

  final StatsSummary summary;
  final List<DailyStat> heatmap;

  @override
  List<Object?> get props => [range, summary, heatmap];
}

class StatsError extends StatsState {
  const StatsError({required this.failure, required super.range});

  final Failure failure;

  @override
  List<Object?> get props => [range, failure];
}
