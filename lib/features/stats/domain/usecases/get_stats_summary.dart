import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/error/failure.dart';
import '../entities/stats_summary.dart';
import '../repositories/stats_repository.dart';

@injectable
class GetStatsSummary {
  GetStatsSummary(this._repository);

  final StatsRepository _repository;

  Future<Either<Failure, StatsSummary>> call(StatsRange range) =>
      _repository.getSummary(range);
}
