import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/error/failure.dart';
import '../../../../core/network/dio_client.dart';
import '../../domain/entities/activity_comment.dart';
import '../../domain/entities/activity_visibility.dart';
import '../../domain/entities/followed_user.dart';
import '../../domain/entities/leaderboard_entry.dart';
import '../../domain/entities/user_search_results.dart';
import '../../domain/repositories/social_repository.dart';
import '../datasources/social_remote_datasource.dart';
import '../models/activity_comment_model.dart';
import '../models/activity_visibility_wire.dart';
import '../models/followed_user_model.dart';
import '../models/leaderboard_entry_model.dart';

@LazySingleton(as: SocialRepository)
class SocialRepositoryImpl implements SocialRepository {
  SocialRepositoryImpl(this._remote);

  final SocialRemoteDataSource _remote;

  @override
  Future<Either<Failure, Unit>> followUser(String userId) async {
    try {
      await _remote.followUser(userId);
      return const Right(unit);
    } on DioException catch (e) {
      return dioExceptionToEither(e);
    }
  }

  @override
  Future<Either<Failure, Unit>> unfollowUser(String userId) async {
    try {
      await _remote.unfollowUser(userId);
      return const Right(unit);
    } on DioException catch (e) {
      return dioExceptionToEither(e);
    }
  }

  @override
  Future<Either<Failure, List<FollowedUser>>> listFollowers() async {
    try {
      final json = await _remote.listFollowers();
      final users = json
          .cast<Map<String, dynamic>>()
          .map(FollowedUserModel.fromJson)
          .toList();
      return Right(users);
    } on DioException catch (e) {
      return dioExceptionToEither(e);
    }
  }

  @override
  Future<Either<Failure, List<FollowedUser>>> listFollowing() async {
    try {
      final json = await _remote.listFollowing();
      final users = json
          .cast<Map<String, dynamic>>()
          .map(FollowedUserModel.fromJson)
          .toList();
      return Right(users);
    } on DioException catch (e) {
      return dioExceptionToEither(e);
    }
  }

  @override
  Future<Either<Failure, int>> getFollowersCount() async {
    try {
      return Right(await _remote.getFollowersCount());
    } on DioException catch (e) {
      return dioExceptionToEither(e);
    }
  }

  @override
  Future<Either<Failure, int>> getFollowingCount() async {
    try {
      return Right(await _remote.getFollowingCount());
    } on DioException catch (e) {
      return dioExceptionToEither(e);
    }
  }

  @override
  Future<Either<Failure, UserSearchResults>> searchUsers({
    required String query,
    int page = 1,
  }) async {
    try {
      final result = await _remote.searchUsers(q: query, page: page);
      // The search item is the same shape as a followers/following item, so
      // one model parses both; `is_followed_by` is simply absent here and
      // falls back to false.
      final users = result.items
          .cast<Map<String, dynamic>>()
          .map(FollowedUserModel.fromJson)
          .toList();
      return Right(
        UserSearchResults(
          users: users,
          page: page,
          totalPages: result.totalPages,
        ),
      );
    } on DioException catch (e) {
      return dioExceptionToEither(e);
    }
  }

  @override
  Future<Either<Failure, Unit>> likeActivity(String activityId) async {
    try {
      await _remote.likeActivity(activityId);
      return const Right(unit);
    } on DioException catch (e) {
      return dioExceptionToEither(e);
    }
  }

  @override
  Future<Either<Failure, Unit>> unlikeActivity(String activityId) async {
    try {
      await _remote.unlikeActivity(activityId);
      return const Right(unit);
    } on DioException catch (e) {
      return dioExceptionToEither(e);
    }
  }

  @override
  Future<Either<Failure, ActivityComment>> addComment({
    required String activityId,
    required String body,
  }) async {
    try {
      final json = await _remote.addComment(activityId: activityId, body: body);
      return Right(ActivityCommentModel.fromAddCommentJson(json));
    } on DioException catch (e) {
      return dioExceptionToEither(e);
    }
  }

  @override
  Future<Either<Failure, List<ActivityComment>>> listComments(String activityId) async {
    try {
      final json = await _remote.listComments(activityId);
      final comments = json
          .cast<Map<String, dynamic>>()
          .map(ActivityCommentModel.fromJson)
          .toList();
      return Right(comments);
    } on DioException catch (e) {
      return dioExceptionToEither(e);
    }
  }

  @override
  Future<Either<Failure, LeaderboardResult>> getLeaderboard(LeaderboardRange range) async {
    try {
      final json = await _remote.getLeaderboard(range.wireValue);
      return Right(LeaderboardResultModel.fromJson(json));
    } on DioException catch (e) {
      return dioExceptionToEither(e);
    }
  }

  @override
  Future<Either<Failure, Unit>> updateActivityVisibility({
    required String activityId,
    required ActivityVisibility visibility,
  }) async {
    try {
      await _remote.updateActivityVisibility(
        activityId: activityId,
        visibility: visibility.wireValue,
      );
      return const Right(unit);
    } on DioException catch (e) {
      return dioExceptionToEither(e);
    }
  }
}
