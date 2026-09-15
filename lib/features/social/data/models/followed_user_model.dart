import '../../domain/entities/followed_user.dart';

/// Parses the `user` object nested in both `FollowerResponse` and
/// `FollowingResponse` (`api/internal/features/social/delivery/http/response.go`)
/// — same shape either way. `isFollowing` isn't in the wire data; the
/// repository passes it in based on which list this came from.
class FollowedUserModel extends FollowedUser {
  const FollowedUserModel({
    required super.id,
    required super.name,
    required super.avatarUrl,
    required super.isFollowing,
  });

  factory FollowedUserModel.fromJson(
    Map<String, dynamic> json, {
    required bool isFollowing,
  }) {
    final user = json['user'] as Map<String, dynamic>;
    return FollowedUserModel(
      id: user['id'] as String,
      name: user['name'] as String,
      avatarUrl: user['avatar_url'] as String?,
      isFollowing: isFollowing,
    );
  }
}
