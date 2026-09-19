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
    required this.isFollowedBy,
  });

  final String id;
  final String name;
  final String? avatarUrl;

  /// Whether *you* follow this user — the state the follow button shows.
  ///
  /// Comes from the list response itself, so a followers list paints the
  /// right button on the first frame: someone you already follow back must
  /// not be offered "Follow" again.
  final bool isFollowing;

  /// Whether this user follows *you* — "follows you back".
  ///
  /// Only worth showing on the following list. On a followers list every row
  /// is true by definition (that is what put them there), so the page hides it.
  final bool isFollowedBy;

  FollowedUser copyWith({bool? isFollowing}) {
    return FollowedUser(
      id: id,
      name: name,
      avatarUrl: avatarUrl,
      isFollowing: isFollowing ?? this.isFollowing,
      isFollowedBy: isFollowedBy,
    );
  }

  @override
  List<Object?> get props => [id, name, avatarUrl, isFollowing, isFollowedBy];
}
