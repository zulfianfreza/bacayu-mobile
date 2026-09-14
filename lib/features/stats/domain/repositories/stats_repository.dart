import 'package:dartz/dartz.dart';

import '../../../../core/error/failure.dart';
import '../entities/daily_stat.dart';
import '../entities/stats_summary.dart';

abstract class StatsRepository {
  Future<Either<Failure, StatsSummary>> getSummary(StatsRange range);

  Future<Either<Failure, List<DailyStat>>> getHeatmap(int year);
}
