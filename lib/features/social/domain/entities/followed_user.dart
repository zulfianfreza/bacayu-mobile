import 'package:equatable/equatable.dart';

/// Named `FollowedUser`, not `FollowUser` as CLAUDE.md's entity list says —
/// that name collides with the `FollowUser` usecase (the "follow this
/// user" action) the same list also asks for, and `FollowCubit` needs both
/// types in scope at once.
class FollowedUser extends Equatable {
  const FollowedUser({
    required this.id,
    required this.name,
    required this.avatarUrl,
    required this.isFollowing,
  });

  final String id;
  final String name;
  final String? avatarUrl;

  /// For the "following" list this is trivially always true. For
  /// "followers", the backend doesn't report whether you follow them back
  /// (`GET /social/followers` has no reciprocal-follow flag), so this
  /// starts `false` there and only reflects what's changed locally this
  /// session via `FollowCubit.toggleFollow`.
  final bool isFollowing;

  @override
  List<Object?> get props => [id, name, avatarUrl, isFollowing];
}
