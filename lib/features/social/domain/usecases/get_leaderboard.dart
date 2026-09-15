import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/error/failure.dart';
import '../entities/leaderboard_entry.dart';
import '../repositories/social_repository.dart';

@injectable
class GetLeaderboard {
  GetLeaderboard(this._repository);

  final SocialRepository _repository;

  Future<Either<Failure, LeaderboardResult>> call(LeaderboardRange range) =>
      _repository.getLeaderboard(range);
}
