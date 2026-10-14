import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/error/failure.dart';
import '../entities/daily_goal_progress.dart';
import '../repositories/stats_repository.dart';

@injectable
class GetDailyGoal {
  GetDailyGoal(this._repository);

  final StatsRepository _repository;

  Future<Either<Failure, DailyGoalProgress>> call() =>
      _repository.getDailyGoal();
}
