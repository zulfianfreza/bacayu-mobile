import '../../domain/entities/activity_detail.dart';
import 'activity_model.dart';

/// Mirrors `ActivityDetailResponse` in
/// `api/internal/features/feed/delivery/http/response.go`: the list item's
/// fields **inlined** (hence [ActivityModel.fromJson] on the same map), plus
/// `visibility` and the type-specific detail.
class ActivityDetailModel extends ActivityDetail {
  const ActivityDetailModel({
    required super.activity,
    required super.visibility,
    super.session,
    super.badge,
  });

  factory ActivityDetailModel.fromJson(Map<String, dynamic> json) {
    final session = json['session'] as Map<String, dynamic>?;
    final badge = json['badge'] as Map<String, dynamic>?;

    return ActivityDetailModel(
      activity: ActivityModel.fromJson(json),
      visibility: json['visibility'] as String? ?? 'private',
      session: session == null ? null : SessionDetailModel.fromJson(session),
      badge: badge == null ? null : SessionBadgeModel.fromJson(badge),
    );
  }
}

class SessionDetailModel extends SessionDetail {
  const SessionDetailModel({
    required super.pauseCount,
    required super.pauses,
    required super.badges,
  });

  factory SessionDetailModel.fromJson(Map<String, dynamic> json) {
    return SessionDetailModel(
      pauseCount: (json['pause_count'] as num?)?.toInt() ?? 0,
      pauses: (json['pause_intervals'] as List<dynamic>? ?? [])
          .cast<Map<String, dynamic>>()
          .map(
            (pause) => SessionPause(
              pausedAt: DateTime.parse(pause['paused_at'] as String),
              resumedAt: DateTime.parse(pause['resumed_at'] as String),
            ),
          )
          .toList(),
      // Always a list server-side, empty when the session unlocked nothing.
      badges: (json['badges'] as List<dynamic>? ?? [])
          .cast<Map<String, dynamic>>()
          .map(SessionBadgeModel.fromJson)
          .toList(),
    );
  }
}

class SessionBadgeModel extends SessionBadge {
  const SessionBadgeModel({
    required super.badgeId,
    required super.name,
    required super.description,
    required super.imageUrl,
  });

  factory SessionBadgeModel.fromJson(Map<String, dynamic> json) {
    return SessionBadgeModel(
      badgeId: json['badge_id'] as String,
      name: json['name'] as String? ?? '',
      description: json['description'] as String? ?? '',
      imageUrl: json['image_url'] as String?,
    );
  }
}
