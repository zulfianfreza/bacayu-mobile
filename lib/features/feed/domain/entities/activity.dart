import 'package:equatable/equatable.dart';

/// `payload` shape depends on `activity_type` — see
/// `api/internal/features/feed/usecase/record_session_activity.go` and
/// `record_badge_activity.go`. Already denormalized/enriched at write time
/// (PRD Section 6.8), so rendering the feed never needs a join back to
/// `sessions`/`badges`.
sealed class ActivityPayload extends Equatable {
  const ActivityPayload();

  @override
  List<Object?> get props => [];
}

class SessionActivityPayload extends ActivityPayload {
  const SessionActivityPayload({
    required this.bookId,
    required this.bookTitle,
    required this.bookCoverUrl,
    required this.pagesRead,
    required this.speedPpm,
    required this.activeDurationSeconds,
  });

  /// NOT sent by the backend yet — `ActivityResponse`'s reading-session
  /// payload only has the denormalized `book_title`/`book_cover_url`
  /// snapshot fields, no internal book id (see backend CLAUDE.md Section
  /// 6.8/`record_session_activity.go`). Parses to `null` until the backend
  /// adds a `book_id` field; `ActivityDetailPage` only makes the cover/title
  /// tappable (→ `books`' `BookDetailPage`) when this is non-null.
  final String? bookId;
  final String bookTitle;
  final String? bookCoverUrl;
  final int pagesRead;
  final double speedPpm;
  final int activeDurationSeconds;

  @override
  List<Object?> get props => [
        bookId,
        bookTitle,
        bookCoverUrl,
        pagesRead,
        speedPpm,
        activeDurationSeconds,
      ];
}

class BadgeActivityPayload extends ActivityPayload {
  const BadgeActivityPayload({
    required this.badgeName,
    required this.badgeIcon,
    required this.badgeDescription,
  });

  final String badgeName;
  final String badgeIcon;
  final String badgeDescription;

  @override
  List<Object?> get props => [badgeName, badgeIcon, badgeDescription];
}

class Activity extends Equatable {
  const Activity({
    required this.id,
    required this.occurredAt,
    required this.payload,
    required this.likeCount,
    required this.commentCount,
    required this.isLiked,
  });

  final String id;
  final DateTime occurredAt;
  final ActivityPayload payload;

  /// Read fresh per request (not baked into the denormalized snapshot like
  /// [payload]) — see `ActivityResponse`'s docstring on the backend.
  final int likeCount;
  final int commentCount;
  final bool isLiked;

  @override
  List<Object?> get props =>
      [id, occurredAt, payload, likeCount, commentCount, isLiked];
}
