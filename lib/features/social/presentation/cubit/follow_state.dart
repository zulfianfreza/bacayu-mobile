import 'package:equatable/equatable.dart';

import '../../../../core/error/failure.dart';
import '../../domain/entities/followed_user.dart';

sealed class FollowState extends Equatable {
  const FollowState({required this.users, required this.pendingUserIds});

  final List<FollowedUser> users;

  /// User ids currently mid follow/unfollow toggle — so only that one row
  /// shows a spinner, not the whole list.
  final Set<String> pendingUserIds;

  @override
  List<Object?> get props => [users, pendingUserIds];
}

class FollowInitial extends FollowState {
  const FollowInitial() : super(users: const [], pendingUserIds: const {});
}

class FollowLoading extends FollowState {
  const FollowLoading() : super(users: const [], pendingUserIds: const {});
}

class FollowLoaded extends FollowState {
  const FollowLoaded({required super.users, required super.pendingUserIds});

  FollowLoaded copyWith({List<FollowedUser>? users, Set<String>? pendingUserIds}) {
    return FollowLoaded(
      users: users ?? this.users,
      pendingUserIds: pendingUserIds ?? this.pendingUserIds,
    );
  }
}

/// Initial `loadFollowers()`/`loadFollowing()` failed — no data to show at
/// all.
class FollowError extends FollowState {
  const FollowError(this.failure) : super(users: const [], pendingUserIds: const {});

  final Failure failure;

  @override
  List<Object?> get props => [users, pendingUserIds, failure];
}

/// A single `toggleFollow` call failed — [users]/[pendingUserIds] are
/// otherwise unchanged (same shape as [FollowLoaded]) so the list stays on
/// screen; the page just also shows [failure] (e.g. a snackbar) once.
class FollowActionError extends FollowState {
  const FollowActionError({
    required super.users,
    required super.pendingUserIds,
    required this.failure,
  });

  final Failure failure;

  @override
  List<Object?> get props => [users, pendingUserIds, failure];
}
