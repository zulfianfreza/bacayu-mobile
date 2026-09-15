import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../domain/entities/followed_user.dart';
import '../../domain/usecases/follow_user.dart';
import '../../domain/usecases/list_followers.dart';
import '../../domain/usecases/list_following.dart';
import '../../domain/usecases/unfollow_user.dart';
import 'follow_state.dart';

/// Backs both `FollowersPage` and `FollowingPage` — call [loadFollowers]
/// or [loadFollowing] depending on which page created this instance.
@injectable
class FollowCubit extends Cubit<FollowState> {
  FollowCubit(
    this._listFollowers,
    this._listFollowing,
    this._followUser,
    this._unfollowUser,
  ) : super(const FollowInitial());

  final ListFollowers _listFollowers;
  final ListFollowing _listFollowing;
  final FollowUser _followUser;
  final UnfollowUser _unfollowUser;

  Future<void> loadFollowers() async {
    emit(const FollowLoading());
    final result = await _listFollowers();
    result.fold(
      (failure) => emit(FollowError(failure)),
      (users) => emit(FollowLoaded(users: users, pendingUserIds: const {})),
    );
  }

  Future<void> loadFollowing() async {
    emit(const FollowLoading());
    final result = await _listFollowing();
    result.fold(
      (failure) => emit(FollowError(failure)),
      (users) => emit(FollowLoaded(users: users, pendingUserIds: const {})),
    );
  }

  /// Per-item — only [user]'s row goes into `pendingUserIds`, the rest of
  /// the list stays fully interactive. A failed toggle (e.g. the backend
  /// rejecting a self-follow) never gets stuck: the list itself is read
  /// off the current state's base `users`/`pendingUserIds`, not off
  /// `FollowLoaded` specifically, so a later toggle still works even right
  /// after a `FollowActionError`.
  Future<void> toggleFollow(FollowedUser user) async {
    final current = state;
    if (current is FollowInitial || current is FollowLoading || current is FollowError) {
      return;
    }
    if (current.pendingUserIds.contains(user.id)) return;

    emit(FollowLoaded(
      users: current.users,
      pendingUserIds: {...current.pendingUserIds, user.id},
    ));

    final willFollow = !user.isFollowing;
    final result =
        willFollow ? await _followUser(user.id) : await _unfollowUser(user.id);

    final latest = state;
    if (latest is FollowInitial || latest is FollowLoading || latest is FollowError) {
      return;
    }

    result.fold(
      (failure) {
        final pending = {...latest.pendingUserIds}..remove(user.id);
        emit(FollowActionError(
          users: latest.users,
          pendingUserIds: pending,
          failure: failure,
        ));
      },
      (_) {
        final pending = {...latest.pendingUserIds}..remove(user.id);
        final updatedUsers = [
          for (final u in latest.users)
            if (u.id == user.id)
              FollowedUser(
                id: u.id,
                name: u.name,
                avatarUrl: u.avatarUrl,
                isFollowing: willFollow,
              )
            else
              u,
        ];
        emit(FollowLoaded(users: updatedUsers, pendingUserIds: pending));
      },
    );
  }
}
