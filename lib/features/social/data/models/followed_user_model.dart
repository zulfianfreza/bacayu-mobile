import '../../domain/entities/followed_user.dart';

/// Parses one item of `GET /social/followers` or `GET /social/following`
/// (`api/internal/features/social/delivery/http/response.go`) — same shape
/// either way: the listed user under `user`, plus the caller's own
/// relationship to them as siblings (`is_following`, `is_followed_by`).
class FollowedUserModel extends FollowedUser {
  const FollowedUserModel({
    required super.id,
    required super.name,
    required super.avatarUrl,
    required super.isFollowing,
    required super.isFollowedBy,
  });

  factory FollowedUserModel.fromJson(Map<String, dynamic> json) {
    final user = json['user'] as Map<String, dynamic>;
    return FollowedUserModel(
      id: user['id'] as String,
      name: user['name'] as String,
      avatarUrl: user['avatar_url'] as String?,
      isFollowing: json['is_following'] as bool? ?? false,
      isFollowedBy: json['is_followed_by'] as bool? ?? false,
    );
  }
}
