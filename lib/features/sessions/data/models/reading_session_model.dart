import '../../domain/entities/reading_session.dart';

/// `toJson()` doubles as both the `POST /sessions` request body AND the
/// payload stored in the `PendingSessions` Drift row — one wire shape, one
/// place it's built. `fromJson()` mirrors `SessionResponse` in
/// `api/internal/features/sessions/delivery/http/response.go` (used for
/// `GET /sessions` history; server-computed fields like `pages_read`/
/// `speed_ppm` are simply ignored here, this app doesn't display them yet).
class ReadingSessionModel extends ReadingSession {
  const ReadingSessionModel({
    required super.clientId,
    required super.userBookId,
    required super.inputMode,
    required super.startTime,
    required super.endTime,
    required super.activeDurationSeconds,
    required super.pauseIntervals,
    required super.startPage,
    required super.endPage,
  });

  factory ReadingSessionModel.fromEntity(ReadingSession session) {
    return ReadingSessionModel(
      clientId: session.clientId,
      userBookId: session.userBookId,
      inputMode: session.inputMode,
      startTime: session.startTime,
      endTime: session.endTime,
      activeDurationSeconds: session.activeDurationSeconds,
      pauseIntervals: session.pauseIntervals,
      startPage: session.startPage,
      endPage: session.endPage,
    );
  }

  factory ReadingSessionModel.fromJson(Map<String, dynamic> json) {
    return ReadingSessionModel(
      clientId: json['client_id'] as String,
      userBookId: json['user_book_id'] as String,
      inputMode: json['input_mode'] as String,
      startTime: DateTime.parse(json['start_time'] as String),
      endTime: DateTime.parse(json['end_time'] as String),
      activeDurationSeconds: json['active_duration_seconds'] as int,
      pauseIntervals: (json['pause_intervals'] as List<dynamic>? ?? [])
          .cast<Map<String, dynamic>>()
          .map(
            (p) => PauseInterval(
              pausedAt: DateTime.parse(p['paused_at'] as String),
              resumedAt: DateTime.parse(p['resumed_at'] as String),
            ),
          )
          .toList(),
      startPage: json['start_page'] as int,
      endPage: json['end_page'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'client_id': clientId,
      'user_book_id': userBookId,
      'input_mode': inputMode,
      'start_time': startTime.toUtc().toIso8601String(),
      'end_time': endTime.toUtc().toIso8601String(),
      'active_duration_seconds': activeDurationSeconds,
      'pause_intervals': [
        for (final p in pauseIntervals)
          {
            'paused_at': p.pausedAt.toUtc().toIso8601String(),
            'resumed_at': p.resumedAt.toUtc().toIso8601String(),
          },
      ],
      'start_page': startPage,
      'end_page': endPage,
    };
  }
}
