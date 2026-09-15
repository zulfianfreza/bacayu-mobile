import '../../domain/entities/activity_comment.dart';

class ActivityCommentModel extends ActivityComment {
  const ActivityCommentModel({
    required super.id,
    required super.userId,
    required super.userName,
    required super.userAvatarUrl,
    required super.body,
    required super.createdAt,
  });

  /// `GET /feed/:activityId/comments` — `CommentResponse`, nested `user`.
  factory ActivityCommentModel.fromJson(Map<String, dynamic> json) {
    final user = json['user'] as Map<String, dynamic>;
    return ActivityCommentModel(
      id: json['id'] as String,
      userId: user['id'] as String,
      userName: user['name'] as String,
      userAvatarUrl: user['avatar_url'] as String?,
      body: json['body'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  /// `POST /feed/:activityId/comments` — `AddCommentResponse`, flat
  /// `user_id` only (the backend doesn't re-send the requester's own
  /// name/avatar back to them). `userName`/`userAvatarUrl` are left blank
  /// here — the caller (always the current user, for a just-posted
  /// comment) fills those in from its own already-known profile.
  factory ActivityCommentModel.fromAddCommentJson(Map<String, dynamic> json) {
    return ActivityCommentModel(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      userName: '',
      userAvatarUrl: null,
      body: json['body'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }
}
