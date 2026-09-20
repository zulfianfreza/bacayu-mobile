import 'package:equatable/equatable.dart';

import 'activity.dart';

/// `GET /feed/:activityId` — one activity plus the detail behind its
/// `reference_id`: [session] for a reading session, [badge] for a badge unlock.
/// The other stays null.
class ActivityDetail extends Equatable {
  const ActivityDetail({
    required this.activity,
    required this.visibility,
    this.session,
    this.badge,
  });

  final Activity activity;

  /// `private` | `followers` | `public`. The server has already refused to
  /// return the activity at all if the viewer may not see it, so this is
  /// information rather than a check to perform here.
  final String visibility;

  final SessionDetail? session;
  final SessionBadge? badge;

  @override
  List<Object?> get props => [activity, visibility, session, badge];
}

/// What a reading session adds on top of its activity payload.
///
/// Deliberately not the whole session record: the payload already carries the
/// pages, duration and speed. The pauses are what a feed item cannot know, and
/// [badges] is what that session unlocked.
class SessionDetail extends Equatable {
  const SessionDetail({
    required this.pauseCount,
    required this.pauses,
    required this.badges,
  });

  final int pauseCount;
  final List<SessionPause> pauses;
  final List<SessionBadge> badges;

  /// Every pause added up.
  Duration get pausedFor =>
      pauses.fold(Duration.zero, (total, pause) => total + pause.duration);

  @override
  List<Object?> get props => [pauseCount, pauses, badges];
}

/// One pause: when reading stopped and when it picked back up.
///
/// Named `SessionPause` rather than reusing `sessions`' `PauseInterval` — a
/// feature's domain does not reach into another's, and the two answer to
/// different wire shapes.
class SessionPause extends Equatable {
  const SessionPause({required this.pausedAt, required this.resumedAt});

  final DateTime pausedAt;
  final DateTime resumedAt;

  Duration get duration => resumedAt.difference(pausedAt);

  @override
  List<Object?> get props => [pausedAt, resumedAt];
}

/// A badge a session unlocked.
class SessionBadge extends Equatable {
  const SessionBadge({
    required this.badgeId,
    required this.name,
    required this.description,
    required this.imageUrl,
  });

  final String badgeId;
  final String name;
  final String description;

  /// `image_url` — the badge's artwork, when the backend has one.
  final String? imageUrl;

  @override
  List<Object?> get props => [badgeId, name, description, imageUrl];
}
