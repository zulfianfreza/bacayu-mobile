import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/error/failure.dart';
import '../entities/daily_stat.dart';
import '../repositories/stats_repository.dart';

@injectable
class GetHeatmap {
  GetHeatmap(this._repository);

  final StatsRepository _repository;

  Future<Either<Failure, List<DailyStat>>> call(int year) =>
      _repository.getHeatmap(year);
}
