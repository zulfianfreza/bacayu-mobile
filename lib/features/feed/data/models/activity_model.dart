import '../../domain/entities/activity.dart';

const _typeReadingSession = 'reading_session';
const _typeBadgeUnlocked = 'badge_unlocked';

/// Mirrors `ActivityResponse` in
/// `api/internal/features/feed/delivery/http/response.go` — `payload`'s
/// shape branches on `activity_type`. Numeric payload fields are read via
/// `num` first: the payload round-trips through Postgres JSONB, so ints
/// aren't guaranteed to come back as JSON integers.
class ActivityModel extends Activity {
  const ActivityModel({
    required super.id,
    required super.author,
    required super.occurredAt,
    required super.payload,
    required super.likeCount,
    required super.commentCount,
    required super.isLiked,
  });

  factory ActivityModel.fromJson(Map<String, dynamic> json) {
    final activityType = json['activity_type'] as String;
    final payloadJson = json['payload'] as Map<String, dynamic>;

    return ActivityModel(
      id: json['id'] as String,
      author: _authorFromJson(json['user'] as Map<String, dynamic>),
      occurredAt: DateTime.parse(json['occurred_at'] as String),
      payload: _payloadFromJson(activityType, payloadJson),
      likeCount: (json['like_count'] as num?)?.toInt() ?? 0,
      commentCount: (json['comment_count'] as num?)?.toInt() ?? 0,
      isLiked: json['is_liked'] as bool? ?? false,
    );
  }

  static ActivityAuthor _authorFromJson(Map<String, dynamic> json) {
    return ActivityAuthor(
      id: json['id'] as String,
      name: json['name'] as String? ?? '',
      avatarUrl: json['avatar_url'] as String?,
    );
  }

  static ActivityPayload _payloadFromJson(
    String activityType,
    Map<String, dynamic> payloadJson,
  ) {
    switch (activityType) {
      case _typeReadingSession:
        return SessionActivityPayload(
          bookId: payloadJson['book_id'] as String?,
          bookTitle: payloadJson['book_title'] as String? ?? '',
          bookCoverUrl: payloadJson['book_cover_url'] as String?,
          pagesRead: (payloadJson['pages_read'] as num?)?.toInt() ?? 0,
          speedPpm: (payloadJson['speed_ppm'] as num?)?.toDouble() ?? 0,
          activeDurationSeconds:
              (payloadJson['active_duration_seconds'] as num?)?.toInt() ?? 0,
        );
      case _typeBadgeUnlocked:
        return BadgeActivityPayload(
          badgeName: payloadJson['badge_name'] as String? ?? '',
          badgeIcon: payloadJson['badge_icon'] as String? ?? '',
          badgeDescription: payloadJson['badge_description'] as String? ?? '',
        );
      default:
        throw ArgumentError(
          'Unknown activity_type from backend: $activityType',
        );
    }
  }
}
