import 'package:equatable/equatable.dart';

class PauseInterval extends Equatable {
  const PauseInterval({required this.pausedAt, required this.resumedAt});

  final DateTime pausedAt;
  final DateTime resumedAt;

  @override
  List<Object?> get props => [pausedAt, resumedAt];
}

/// `activeDurationSeconds` is always derived from timestamp differences
/// (start/end/pause_intervals), never from a UI tick counter — see
/// CLAUDE.md Section 6.1.
class ReadingSession extends Equatable {
  const ReadingSession({
    required this.clientId,
    required this.userBookId,
    required this.inputMode,
    required this.startTime,
    required this.endTime,
    required this.activeDurationSeconds,
    required this.pauseIntervals,
    required this.startPage,
    required this.endPage,
  });

  final String clientId;
  final String userBookId;

  /// `"timer"` or `"manual"` — mobile only produces `"timer"` sessions for
  /// now (no manual-entry UI yet).
  final String inputMode;

  final DateTime startTime;
  final DateTime endTime;
  final int activeDurationSeconds;
  final List<PauseInterval> pauseIntervals;
  final int startPage;
  final int endPage;

  @override
  List<Object?> get props => [
        clientId,
        userBookId,
        inputMode,
        startTime,
        endTime,
        activeDurationSeconds,
        pauseIntervals,
        startPage,
        endPage,
      ];
}
