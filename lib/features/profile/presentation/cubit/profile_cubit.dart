import 'package:dartz/dartz.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/error/failure.dart';
import '../../../auth/domain/entities/user.dart';
import '../../../auth/domain/usecases/get_current_user.dart';
import '../../../badges/domain/entities/badge.dart';
import '../../../badges/domain/usecases/get_all_badges.dart';
import '../../../social/domain/entities/follow_counts.dart';
import '../../../social/domain/usecases/get_follow_counts.dart';
import '../../../stats/domain/entities/stats_summary.dart';
import '../../../stats/domain/usecases/get_stats_summary.dart';
import 'profile_state.dart';

/// Profile has no domain/data of its own — presentation-only orchestration
/// over `auth`/`stats`/`badges`/`social` usecases that already exist, same
/// spirit as `home`/`onboarding`.
@injectable
class ProfileCubit extends Cubit<ProfileState> {
  ProfileCubit(
    this._getCurrentUser,
    this._getStatsSummary,
    this._getAllBadges,
    this._getFollowCounts,
  ) : super(const ProfileInitial());

  final GetCurrentUser _getCurrentUser;
  final GetStatsSummary _getStatsSummary;
  final GetAllBadges _getAllBadges;
  final GetFollowCounts _getFollowCounts;

  Future<void> load() async {
    emit(const ProfileLoading());

    // All 4 fired together — never awaited one at a time.
    final results = await Future.wait<dynamic>([
      _getCurrentUser(),
      _getStatsSummary(StatsRange.all),
      _getAllBadges(),
      _getFollowCounts(),
    ]);

    final userResult = results[0] as Either<Failure, User>;
    final statsResult = results[1] as Either<Failure, StatsSummary>;
    final badgesResult = results[2] as Either<Failure, List<Badge>>;
    final followCountsResult = results[3] as Either<Failure, FollowCounts>;

    Failure? firstFailure;
    User? user;
    StatsSummary? stats;
    List<Badge>? badges;
    FollowCounts? followCounts;

    userResult.fold((f) => firstFailure ??= f, (v) => user = v);
    statsResult.fold((f) => firstFailure ??= f, (v) => stats = v);
    badgesResult.fold((f) => firstFailure ??= f, (v) => badges = v);
    followCountsResult.fold((f) => firstFailure ??= f, (v) => followCounts = v);

    final failure = firstFailure;
    if (failure != null) {
      emit(ProfileError(failure));
      return;
    }

    emit(ProfileLoaded(
      user: user!,
      booksFinished: stats!.booksFinished,
      badgesUnlocked: badges!.where((b) => b.unlocked).length,
      totalBadges: badges!.length,
      followersCount: followCounts!.followers,
      followingCount: followCounts!.following,
    ));
  }
}
