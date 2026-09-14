import 'package:equatable/equatable.dart';

import '../../../../core/error/failure.dart';
import '../../domain/entities/unlocked_badge.dart';

sealed class SessionTimerState extends Equatable {
  const SessionTimerState();

  @override
  List<Object?> get props => [];
}

class SessionTimerIdle extends SessionTimerState {
  const SessionTimerIdle();
}

/// [elapsed] is cosmetic display only, recomputed from timestamps on every
/// tick (and on app resume) — never an incremented counter. CLAUDE.md
/// Section 6.1.
class SessionTimerRunning extends SessionTimerState {
  const SessionTimerRunning({required this.elapsed, required this.pauseCount});

  final Duration elapsed;
  final int pauseCount;

  @override
  List<Object?> get props => [elapsed, pauseCount];
}

class SessionTimerPaused extends SessionTimerState {
  const SessionTimerPaused({required this.elapsed, required this.pauseCount});

  final Duration elapsed;
  final int pauseCount;

  @override
  List<Object?> get props => [elapsed, pauseCount];
}

/// `Stop` was tapped — [activeDurationSeconds]/[pauseCount] are final at
/// this point. Waiting on the summary page for start/end page before
/// `submit()`.
class SessionTimerStopped extends SessionTimerState {
  const SessionTimerStopped({
    required this.activeDurationSeconds,
    required this.pauseCount,
  });

  final int activeDurationSeconds;
  final int pauseCount;

  @override
  List<Object?> get props => [activeDurationSeconds, pauseCount];
}

class SessionTimerSubmitting extends SessionTimerState {
  const SessionTimerSubmitting();
}

class SessionTimerSubmitted extends SessionTimerState {
  const SessionTimerSubmitted({required this.badgesUnlocked});

  final List<UnlockedBadge> badgesUnlocked;

  @override
  List<Object?> get props => [badgesUnlocked];
}

class SessionTimerError extends SessionTimerState {
  const SessionTimerError(this.failure);

  final Failure failure;

  @override
  List<Object?> get props => [failure];
}
