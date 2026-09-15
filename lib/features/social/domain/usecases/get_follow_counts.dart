import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/error/failure.dart';
import '../entities/follow_counts.dart';
import '../repositories/social_repository.dart';

/// Fires the followers/following counts in parallel — the counts are used
/// together everywhere (profile header), so one usecase, not two, keeps
/// callers from forgetting to parallelize.
@injectable
class GetFollowCounts {
  GetFollowCounts(this._repository);

  final SocialRepository _repository;

  Future<Either<Failure, FollowCounts>> call() async {
    final results = await Future.wait([
      _repository.getFollowersCount(),
      _repository.getFollowingCount(),
    ]);

    final followersResult = results[0];
    final followingResult = results[1];

    return followersResult.flatMap(
      (followers) => followingResult.map(
        (following) => FollowCounts(followers: followers, following: following),
      ),
    );
  }
}
