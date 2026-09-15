import 'package:dartz/dartz.dart';

import '../../../../core/error/failure.dart';
import '../entities/activity_comment.dart';
import '../entities/activity_visibility.dart';
import '../entities/followed_user.dart';
import '../entities/leaderboard_entry.dart';

abstract class SocialRepository {
  Future<Either<Failure, Unit>> followUser(String userId);
  Future<Either<Failure, Unit>> unfollowUser(String userId);
  Future<Either<Failure, List<FollowedUser>>> listFollowers();
  Future<Either<Failure, List<FollowedUser>>> listFollowing();

  /// Reads the list endpoint's `meta.total` with `limit=1` — never fetches
  /// the full list just to count it.
  Future<Either<Failure, int>> getFollowersCount();
  Future<Either<Failure, int>> getFollowingCount();

  Future<Either<Failure, Unit>> likeActivity(String activityId);
  Future<Either<Failure, Unit>> unlikeActivity(String activityId);

  Future<Either<Failure, ActivityComment>> addComment({
    required String activityId,
    required String body,
  });
  Future<Either<Failure, List<ActivityComment>>> listComments(String activityId);

  Future<Either<Failure, LeaderboardResult>> getLeaderboard(LeaderboardRange range);

  Future<Either<Failure, Unit>> updateActivityVisibility({
    required String activityId,
    required ActivityVisibility visibility,
  });
}
